# 🎯 Riverpod v2 Learning Summary

## 🏗️ App Architecture Overview

Our Smart Todo app demonstrates **separation of concerns** with Riverpod:

```
lib/
├── models/          # Data classes (Task, TaskFilter)
├── providers/       # All Riverpod providers
├── services/        # External services (Storage)
├── screens/         # Full-screen widgets
└── widgets/         # Reusable UI components
```

## 📚 Provider Types Used

### 1. **StateProvider** - Simple State Management
```dart
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final isDarkModeProvider = StateProvider<bool>((ref) => false);
```
- **When to use**: Simple values that change (booleans, enums, primitives)
- **How to update**: `ref.read(provider.notifier).state = newValue`
- **How to watch**: `ref.watch(provider)`

### 2. **StateNotifierProvider** - Complex State Management
```dart
final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});
```
- **When to use**: Complex state with business logic (lists, objects with methods)
- **How to update**: Call methods on the notifier: `ref.read(provider.notifier).addTask(title)`
- **How to watch**: `ref.watch(provider)` for state, `ref.read(provider.notifier)` for methods

### 3. **Provider** - Computed/Derived State
```dart
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final filter = ref.watch(taskFilterProvider);
  // computation logic...
});
```
- **When to use**: Derived state that depends on other providers
- **Automatically recalculates** when dependencies change
- **Pure functions** - no side effects

### 4. **FutureProvider** - Async Operations
```dart
final taskLoaderProvider = FutureProvider<List<Task>>((ref) async {
  return await StorageService.loadTasks();
});
```
- **When to use**: One-time async operations (loading data, API calls)
- **Returns AsyncValue** with loading/error/data states
- **Handle with**: `asyncValue.when(data: ..., loading: ..., error: ...)`

## 🔄 Key Riverpod Patterns

### **ref.watch vs ref.read vs ref.listen**

```dart
// ✅ ref.watch - In build methods, listen to changes
Widget build(BuildContext context, WidgetRef ref) {
  final tasks = ref.watch(taskProvider); // Rebuilds when tasks change
  return ListView(...);
}

// ✅ ref.read - In event handlers, call methods
onPressed: () {
  ref.read(taskProvider.notifier).addTask(title); // One-time call
}

// ✅ ref.listen - Side effects (snackbars, navigation)
ref.listen(taskProvider, (previous, next) {
  if (next.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
});
```

### **State Immutability Pattern**
```dart
// ❌ Don't mutate existing state
state.add(newTask); // Wrong!

// ✅ Create new state instances
state = [...state, newTask]; // Correct!
state = state.map((task) => task.id == id ? task.copyWith(isDone: true) : task).toList();
```

### **Provider Initialization Pattern** 
```dart
// ❌ WRONG: Don't modify providers during initialization
final badInitializer = Provider<void>((ref) {
  ref.read(taskProvider.notifier).loadTasks([]); // ERROR!
});

// ✅ CORRECT: Use ref.listen for initialization side effects
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen(taskLoaderProvider, (previous, next) {
    next.when(
      data: (tasks) => ref.read(taskProvider.notifier).loadTasks(tasks),
      loading: () {}, 
      error: (error, stack) {},
    );
  });
}
```

## 🎨 UI Reactive Patterns

### **ConsumerWidget vs ConsumerStatefulWidget**
```dart
// For stateless widgets that need ref
class TaskItem extends ConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) { ... }
}

// For stateful widgets that need ref
class AddTaskWidget extends ConsumerStatefulWidget {
  ConsumerState<AddTaskWidget> createState() => _AddTaskWidgetState();
}
```

### **Conditional UI Updates**
```dart
// UI automatically updates when filteredTasksProvider changes
final filteredTasks = ref.watch(filteredTasksProvider);
return filteredTasks.isEmpty ? _buildEmptyState() : _buildTaskList();
```

## 💾 Persistence Patterns

### **Automatic Saving After State Changes**
```dart
class TaskNotifier extends StateNotifier<List<Task>> {
  void addTask(String title) {
    state = [...state, newTask];
    _saveToStorage(); // Save after every modification
  }
  
  Future<void> _saveToStorage() async {
    await StorageService.saveTasks(state);
  }
}
```

### **Loading State on App Start**
```dart
// FutureProvider loads data
final taskLoaderProvider = FutureProvider<List<Task>>((ref) async {
  return await StorageService.loadTasks();
});

// Initializer provider watches and loads into state
final taskInitializerProvider = Provider<void>((ref) {
  // Watches FutureProvider and loads data when ready
});
```

## 🚀 Performance Tips

1. **Use ref.read() for one-time operations** (button presses)
2. **Use ref.watch() only in build methods** for reactive updates
3. **Create specific providers** instead of watching large objects
4. **Provider composition** for derived state instead of complex computations in widgets

## 🧪 Testing Riverpod

```dart
// Easy to test providers in isolation
void main() {
  test('TaskNotifier adds task correctly', () {
    final container = ProviderContainer();
    final notifier = container.read(taskProvider.notifier);
    
    notifier.addTask('Test Task');
    
    expect(container.read(taskProvider), hasLength(1));
    expect(container.read(taskProvider).first.title, 'Test Task');
  });
}
```

## 🎯 When to Use Each Provider Type

| Provider Type | Use Case | Example |
|---------------|----------|---------|
| `StateProvider` | Simple toggles, filters, settings | Theme mode, filter selection |
| `StateNotifierProvider` | Complex state with business logic | Task list, user profile |
| `Provider` | Computed/derived state | Filtered lists, formatted data |
| `FutureProvider` | One-time async operations | API calls, file loading |

## 🔧 Common Pitfalls to Avoid

❌ **Using ref.watch in event handlers**
❌ **Mutating state directly**
❌ **Creating providers inside widgets**
❌ **Forgetting to use Consumer widgets**
❌ **Not handling async states properly**
❌ **🚨 Modifying providers during initialization (NEW!)**

✅ **Use ref.read for events, ref.watch for UI**
✅ **Always create new state instances**
✅ **Define providers at top level**
✅ **Use Consumer widgets for reactive UI**
✅ **Handle loading/error states in AsyncValue**
✅ **🎯 Use ref.listen for initialization side effects (NEW!)**

### 🚨 **Critical Error Pattern to Avoid**
```dart
// ❌ This will crash with "Providers cannot modify other providers during initialization"
final badProvider = Provider<void>((ref) {
  ref.read(someOtherProvider.notifier).doSomething(); // ERROR!
});

// ✅ Use ref.listen in widgets instead
ref.listen(sourceProvider, (previous, next) {
  ref.read(targetProvider.notifier).doSomething(); // CORRECT!
});
```

---

## 🎉 Congratulations!

You've successfully learned:
- ✅ All 4 main Riverpod provider types
- ✅ Reactive UI patterns
- ✅ State persistence with FutureProvider  
- ✅ Provider composition and derived state
- ✅ Best practices for ref.watch/read/listen
- ✅ Clean architecture with separation of concerns 
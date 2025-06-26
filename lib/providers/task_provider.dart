import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/task_filter.dart';
import '../services/storage_service.dart';


class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  Future<void> _saveToStorage() async {
    await StorageService.saveTasks(state);
  }
  void addTask(Task task) {
    state = [...state, task];
    _saveToStorage();
  }

  void toggleTask(String taskId) {
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isDone: !task.isDone);
      }
      return task;
    }).toList();
    _saveToStorage();
  }

  void deleteTask(String taskId) {
    state = state.where((task) => task.id != taskId).toList();
    _saveToStorage();
  }

  void restoreTask(Task task, int index) {
    final newList = List<Task>.from(state);
    final insertIndex = index.clamp(0, newList.length);
    newList.insert(insertIndex, task);
    state = newList;
    _saveToStorage();
  }

  void updateTask(String taskId, String newTitle) {
    if (newTitle.trim().isEmpty) return;
    
    state = state.map((task) {
      if (task.id == taskId) {
        return task.copyWith(title: newTitle.trim());
      }
      return task;
    }).toList();
    _saveToStorage();
  }

  void loadTasks(List<Task> tasks) {
    state = tasks;
  }

  void clearAllTasks() {
    state = [];
    _saveToStorage();
  }

  void clearCompletedTasks() {
    state = state.where((task) => !task.isDone).toList();
    _saveToStorage();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter.all;
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskProvider);
  final filter = ref.watch(taskFilterProvider);

  switch (filter) {
    case TaskFilter.all:
      return tasks;
    case TaskFilter.done:
      return tasks.where((task) => task.isDone).toList();
    case TaskFilter.notDone:
      return tasks.where((task) => !task.isDone).toList();
  }
});

final taskCountProvider = Provider<int>((ref) {
  return ref.watch(taskProvider).length;
});

final completedTaskCountProvider = Provider<int>((ref) {
  return ref.watch(taskProvider).where((task) => task.isDone).length;
});

final pendingTaskCountProvider = Provider<int>((ref) {
  return ref.watch(taskProvider).where((task) => !task.isDone).length;
});

final recentlyDeletedTaskProvider = StateProvider<Task?>((ref) {
  return null;
});

final taskLoaderProvider = FutureProvider<List<Task>>((ref) async {
  return await StorageService.loadTasks();
}); 
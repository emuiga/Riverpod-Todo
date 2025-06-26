import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/task_item.dart';
import '../widgets/add_task_widget.dart';
import '../widgets/filter_chips.dart';

/// Main screen displaying the todo list
/// 
/// ConsumerWidget gives us access to WidgetRef (ref) in the build method.
/// This lets us use ref.watch() to listen to provider changes.
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ CORRECT: Use ref.listen for initialization side effects
    // This loads tasks from storage when the FutureProvider completes
    ref.listen(taskLoaderProvider, (previous, next) {
      next.when(
        data: (tasks) {
          // Load tasks into our StateNotifier when data is ready
          ref.read(taskProvider.notifier).loadTasks(tasks);
        },
        loading: () {}, // Do nothing while loading
        error: (error, stack) {
          // Handle error state - for learning purposes, we'll just use empty list
          // In a real app, you might show an error dialog
        },
      );
    });
    
    // Watch filtered tasks - UI updates automatically when this changes!
    final filteredTasks = ref.watch(filteredTasksProvider);
    final taskCount = ref.watch(taskCountProvider);
    final completedCount = ref.watch(completedTaskCountProvider);

    // ref.listen for side effects - congratulate when all tasks completed!
    // This demonstrates ref.listen usage for side effects
    ref.listen(taskProvider, (previous, current) {
      // Only show message if we have tasks and they're all completed
      if (current.isNotEmpty && current.every((task) => task.isDone)) {
        // Previous state had incomplete tasks, now all are done
        final hadIncomplete = previous?.any((task) => !task.isDone) ?? false;
        if (hadIncomplete) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Congratulations! All tasks completed!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Todo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Theme toggle button
          IconButton(
            onPressed: () {
              // Toggle theme using ref.read()
              final currentMode = ref.read(isDarkModeProvider);
              ref.read(isDarkModeProvider.notifier).state = !currentMode;
            },
            icon: Icon(
              ref.watch(isDarkModeProvider) 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            tooltip: 'Toggle theme',
          ),
          
          // Show task counts in app bar
          if (taskCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '$completedCount/$taskCount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips at the top
          const FilterChips(),
          
          // Task list
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskItem(
                        key: ValueKey(task.id),
                        task: task,
                      );
                    },
                  ),
          ),
          
          // Add task widget at bottom
          const AddTaskWidget(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No tasks yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a task to get started',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 
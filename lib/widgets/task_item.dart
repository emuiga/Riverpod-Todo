import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';

class TaskItem extends ConsumerWidget {
  const TaskItem({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectProvider);
    final project = task.projectId != null 
        ? projects.where((p) => p.id == task.projectId).firstOrNull
        : null;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (value) {
            ref.read(taskProvider.notifier).toggleTask(task.id);
          },
        ),
        
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : null,
          ),
        ),
        
        subtitle: project != null || task.priority > 1
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (project != null) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(project.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(project.name, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                  ],
                  if (task.priority > 1) ...[
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: task.priority == 3 ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      task.priority == 3 ? 'High' : 'Medium',
                      style: TextStyle(
                        color: task.priority == 3 ? Colors.red : Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              )
            : null,
        
        // Actions menu
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDialog(context, ref);
                break;
              case 'delete':
                _deleteTask(context, ref);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        
        // Tap to toggle (alternative to checkbox)
        onTap: () {
          ref.read(taskProvider.notifier).toggleTask(task.id);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: task.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Task title',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(taskProvider.notifier).updateTask(
                  task.id,
                  controller.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, WidgetRef ref) {
    // Find the current position of the task for better undo
    final currentTasks = ref.read(taskProvider);
    final originalIndex = currentTasks.indexOf(task);
    
    // Store task and its position for undo
    final deletedTask = task;
    ref.read(recentlyDeletedTaskProvider.notifier).state = deletedTask;
    
    // Delete the task
    ref.read(taskProvider.notifier).deleteTask(task.id);
    
    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${task.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore task at original position
            ref.read(taskProvider.notifier).restoreTask(deletedTask, originalIndex);
            // Clear the recently deleted task
            ref.read(recentlyDeletedTaskProvider.notifier).state = null;
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
} 
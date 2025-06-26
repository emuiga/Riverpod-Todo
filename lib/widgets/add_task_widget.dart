import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/project_provider.dart';
import '../models/task.dart';

class AddTaskWidget extends ConsumerStatefulWidget {
  const AddTaskWidget({super.key});

  @override
  ConsumerState<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends ConsumerState<AddTaskWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedProjectId;
  int _selectedPriority = 1;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isNotEmpty) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        projectId: _selectedProjectId,
        priority: _selectedPriority,
      );
      ref.read(taskProvider.notifier).addTask(task);
      _controller.clear();
      _focusNode.unfocus();
      setState(() {
        _selectedProjectId = null;
        _selectedPriority = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Add a new task...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _addTask(),
                ),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: _addTask,
                child: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Project',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No Project'),
                    ),
                    ...projects.map((project) => DropdownMenuItem<String?>(
                      value: project.id,
                      child: Text(project.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Low')),
                    DropdownMenuItem(value: 2, child: Text('Medium')),
                    DropdownMenuItem(value: 3, child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
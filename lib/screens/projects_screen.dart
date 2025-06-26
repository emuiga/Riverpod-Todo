import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import '../widgets/project_card.dart';
import '../widgets/add_project_dialog.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(projectLoaderProvider, (previous, next) {
      next.when(
        data: (projects) => ref.read(projectProvider.notifier).loadProjects(projects),
        loading: () {},
        error: (error, stack) {},
      );
    });

    final projects = ref.watch(projectProvider);
    final activeProjects = ref.watch(activeProjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.folder, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Total Projects: ${projects.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(Icons.play_arrow, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'Active: ${activeProjects.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: projects.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No projects yet!', 
                             style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Create your first project to get organized',
                             style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return ProjectCard(
                        key: ValueKey(project.id),
                        project: project,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProjectDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProjectDialog(),
    );
  }
} 
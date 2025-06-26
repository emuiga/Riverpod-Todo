import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';
import '../services/storage_service.dart';

class ProjectNotifier extends StateNotifier<List<Project>> {
  ProjectNotifier() : super([]);

  void addProject(Project project) {
    state = [...state, project];
    _saveToStorage();
  }

  void updateProject(String id, Project updatedProject) {
    state = state.map((project) {
      return project.id == id ? updatedProject : project;
    }).toList();
    _saveToStorage();
  }

  void deleteProject(String id) {
    state = state.where((project) => project.id != id).toList();
    _saveToStorage();
  }

  void loadProjects(List<Project> projects) {
    state = projects;
  }

  Future<void> _saveToStorage() async {
    await StorageService.saveProjects(state);
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, List<Project>>((ref) {
  return ProjectNotifier();
});

final projectLoaderProvider = FutureProvider<List<Project>>((ref) async {
  return await StorageService.loadProjects();
});

final activeProjectsProvider = Provider<List<Project>>((ref) {
  final projects = ref.watch(projectProvider);
  return projects.where((project) => project.status == ProjectStatus.active).toList();
});

final projectProgressProvider = Provider.family<double, String>((ref, projectId) {
  final tasks = ref.watch(taskProvider);
  final projectTasks = tasks.where((task) => task.projectId == projectId).toList();
  
  if (projectTasks.isEmpty) return 0.0;
  
  final completedTasks = projectTasks.where((task) => task.isDone).length;
  return completedTasks / projectTasks.length;
});

final tasksForProjectProvider = Provider.family<List<dynamic>, String>((ref, projectId) {
  final tasks = ref.watch(taskProvider);
  return tasks.where((task) => task.projectId == projectId).toList();
}); 
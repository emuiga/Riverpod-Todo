import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/journal_entry.dart';
import '../models/project.dart';

/// Service to handle local persistence of tasks
/// 
/// This service encapsulates SharedPreferences operations.
/// We'll use this with FutureProvider to load tasks asynchronously.
class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _journalKey = 'journal_entries';
  static const String _projectsKey = 'projects';

  /// Load tasks from SharedPreferences
  static Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson == null) {
        return [];
      }
      
      return Task.tasksFromJsonString(tasksJson);
    } catch (e) {
      // If there's any error loading, return empty list
      return [];
    }
  }

  /// Save tasks to SharedPreferences
  static Future<void> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = Task.tasksToJsonString(tasks);
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      // In a real app, you might want to show an error to the user
      // For this learning example, we'll silently fail
    }
  }

  /// Clear all saved tasks
  static Future<void> clearTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
    } catch (e) {
    }
  }

  static Future<List<JournalEntry>> loadJournalEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getString(_journalKey);
      
      if (entriesJson == null) {
        return [];
      }
      
      return JournalEntry.entriesFromJsonString(entriesJson);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = JournalEntry.entriesToJsonString(entries);
      await prefs.setString(_journalKey, entriesJson);
    } catch (e) {
    }
  }

  static Future<List<Project>> loadProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = prefs.getString(_projectsKey);
      
      if (projectsJson == null) {
        return [];
      }
      
      return Project.projectsFromJsonString(projectsJson);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveProjects(List<Project> projects) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final projectsJson = Project.projectsToJsonString(projects);
      await prefs.setString(_projectsKey, projectsJson);
    } catch (e) {
    }
  }
} 
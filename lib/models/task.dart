import 'dart:convert';

/// Task model for our todo app
/// 
/// This is a simple data class that represents a single task.
/// It's immutable (all fields are final) which is important for Riverpod's
/// state management - we'll create new instances rather than mutating existing ones.
class Task {
  const Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.projectId,
    this.priority = 1,
  });

  final String id;
  final String title;
  final bool isDone;
  final String? projectId;
  final int priority;

  /// Create a copy of this task with some fields updated
  /// This is the pattern we'll use to "modify" tasks in our StateNotifier
  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? projectId,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      projectId: projectId ?? this.projectId,
      priority: priority ?? this.priority,
    );
  }

  /// Convert Task to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'projectId': projectId,
      'priority': priority,
    };
  }

  /// Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: json['isDone'] as bool,
      projectId: json['projectId'] as String?,
      priority: json['priority'] as int? ?? 1,
    );
  }

  /// Convert list of tasks to JSON string
  static String tasksToJsonString(List<Task> tasks) {
    final List<Map<String, dynamic>> jsonList = 
        tasks.map((task) => task.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Create list of tasks from JSON string
  static List<Task> tasksFromJsonString(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.isDone == isDone;
  }

  @override
  int get hashCode => Object.hash(id, title, isDone);
} 
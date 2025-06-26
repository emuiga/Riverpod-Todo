import 'dart:convert';

enum ProjectStatus { planning, active, paused, completed }

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    this.status = ProjectStatus.planning,
    this.color = 0xFF2196F3,
    this.deadline,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final int color;
  final DateTime? deadline;
  final DateTime? createdAt;

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    int? color,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      color: color ?? this.color,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'color': color,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: ProjectStatus.values.firstWhere((e) => e.name == json['status']),
      color: json['color'] as int,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  static String projectsToJsonString(List<Project> projects) {
    final List<Map<String, dynamic>> jsonList = 
        projects.map((project) => project.toJson()).toList();
    return jsonEncode(jsonList);
  }

  static List<Project> projectsFromJsonString(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => Project.fromJson(json as Map<String, dynamic>))
        .toList();
  }
} 
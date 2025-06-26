import 'dart:convert';

enum JournalType { personal, nugget }

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.date,
    this.source,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String content;
  final JournalType type;
  final DateTime date;
  final String? source;
  final List<String> tags;

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    JournalType? type,
    DateTime? date,
    String? source,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      date: date ?? this.date,
      source: source ?? this.source,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'date': date.toIso8601String(),
      'source': source,
      'tags': tags,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: JournalType.values.firstWhere((e) => e.name == json['type']),
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String?,
      tags: List<String>.from(json['tags'] as List),
    );
  }

  static String entriesToJsonString(List<JournalEntry> entries) {
    final List<Map<String, dynamic>> jsonList = 
        entries.map((entry) => entry.toJson()).toList();
    return jsonEncode(jsonList);
  }

  static List<JournalEntry> entriesFromJsonString(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
        .toList();
  }
} 
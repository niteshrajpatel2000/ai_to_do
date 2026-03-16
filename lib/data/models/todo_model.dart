import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String? id;
  final String title;
  final String description;
  final String priority; // 'high', 'medium', 'low'
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;

  TodoModel({
    this.id,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // From Firestore map
  factory TodoModel.fromMap(Map<String, dynamic> map, String id) {
    return TodoModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: map['priority'] ?? 'medium',
      isCompleted: map['isCompleted'] ?? false,
      dueDate: map['dueDate'] != null
          ? (map['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // To Firestore map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

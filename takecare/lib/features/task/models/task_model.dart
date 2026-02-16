import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';

class Task {
  final String taskId;
  final String createdBy;
  final String familyId;
  final String title;
  final TaskType type;
  final Map<String, dynamic> details;
  final TimeOfDay time;
  final List<int> repeatDays;
  final bool? requiredPhotos;
  final DateTime createdAt;

  const Task({
    required this.taskId,
    required this.createdBy,
    required this.familyId,
    required this.title,
    required this.type,
    required this.details,
    required this.time,
    required this.repeatDays,
    this.requiredPhotos,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['id'] as String,
      createdBy: json['createdBy'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      type: TaskType.values.firstWhere(
            (e) => e.name == json['type']?.toString(),
      ),
      details: json['details'] as Map<String, dynamic>,
      time: TimeOfDay(
        hour: json['time']['hour'] as int,
        minute: json['time']['minute'] as int
      ),
      repeatDays: List<int>.from(json['repeatDays']),
        createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

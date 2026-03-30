import 'package:flutter/material.dart';

class Task {
  final String? taskId;
  final String createdBy;
  final String familyId;
  final String title;
  final String icon;
  final String? date;
  final String? note;
  final TimeOfDay time;
  final List<int>? repeatDays;
  final bool? isRequirePhoto; // Firestore field "requirePhoto"
  final bool? isRepeatByDate;
  final DateTime createdAt;

  const Task({
    this.taskId,
    required this.createdBy,
    required this.familyId,
    required this.title,
    required this.time,
    this.repeatDays,
    this.isRequirePhoto,
    this.isRepeatByDate,
    required this.createdAt,
    this.date,
    this.note,
    required this.icon,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['id'] as String? ?? '',
      createdBy: json['createdBy'] as String? ?? '',
      familyId: json['familyId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      icon: json['icons'] as String? ?? 'assets/task.svg',
      isRequirePhoto:
          (json['requirePhoto'] ?? json['isRequiredPhoto']) as bool? ?? false,
      isRepeatByDate: json['isRepeatByDate'] as bool? ?? false,
      time: TimeOfDay(
        hour: json['time']?['hour'] as int? ?? 0,
        minute: json['time']?['minute'] as int? ?? 0,
      ),
      repeatDays: json['repeatDays'] != null
          ? List<int>.from(json['repeatDays'])
          : [],
      note: json['note'] as String? ?? '',
      date: json['date'] as String? ?? '',
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(
              (json['createdAt']?['_seconds'] as int? ?? 0) * 1000,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': taskId,
      'createdBy': createdBy,
      'familyId': familyId,
      'title': title,
      'icons': icon,
      'date': date,
      'note': note,
      'time': {'hour': time.hour, 'minute': time.minute},
      'repeatDays': repeatDays,
      // 'requirePhoto': requirePhoto, delete feild
      'isRequiredPhoto': isRequirePhoto,
      'isRepeatByDate': isRepeatByDate,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

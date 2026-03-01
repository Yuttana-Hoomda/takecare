import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';

class Task {
  final String taskId;
  final String createdBy;
  final String familyId;
  final String title;
  final String icon;
  final String? date;
  final String? note;
  final TimeOfDay time;
  final List<int>? repeatDays;
  final bool? isRequiredPhoto;
  final bool? isRepeatByDate;
  final DateTime createdAt;
  final String? photoProofUrl; // ✅ URL รูปถ่ายยืนยันจาก Cloudinary

  const Task({
    required this.taskId,
    required this.createdBy,
    required this.familyId,
    required this.title,
    required this.time,
    this.repeatDays,
    this.isRequiredPhoto,
    required this.createdAt,
    this.date,
    this.note,
    this.isRepeatByDate,
    required this.icon,
    this.photoProofUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['id'] as String? ?? '',
      createdBy: json['createdBy'] as String,
      familyId: json['familyId'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? 'assets/task.svg',
      isRepeatByDate: json['isRepeatByDate'] as bool? ?? false,
      isRequiredPhoto: json['isRequiredPhoto'] as bool? ?? false,
      time: TimeOfDay(
        hour: json['time']['hour'] as int,
        minute: json['time']['minute'] as int,
      ),
      repeatDays: json['repeatDays'] != null
          ? List<int>.from(json['repeatDays'])
          : [],
      note: json['note'] as String? ?? '',
      date: json['date'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      photoProofUrl:
          json['photoProofUrl'] as String?, // ✅ optional ถ้ายังไม่มีรูป
    );
  }
}

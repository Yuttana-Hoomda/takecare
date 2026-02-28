// TODO Implement this library.import 'package:flutter/material.dart';
import 'package:takecare/features/task/models/task_model.dart';

enum DayStatus { complete, missed, partial }

/// Task + สถานะว่าทำเสร็จหรือยัง (wrapper ของ Task model เดิม)
class EventTask {
  final Task task;
  final bool isDone;
  final String? completedAt; // เช่น "Taken at 8:05 AM"

  const EventTask({
    required this.task,
    required this.isDone,
    this.completedAt,
  });

  factory EventTask.fromJson(Map<String, dynamic> json) {
    return EventTask(
      task: Task.fromJson(json['task']),
      isDone: json['isDone'] as bool? ?? false,
      completedAt: json['completedAt'] as String?,
    );
  }
}

/// ข้อมูลรวมของแต่ละวัน
class DayData {
  final DayStatus status;
  final List<EventTask> tasks;

  const DayData({required this.status, required this.tasks});

  factory DayData.fromEventTasks(List<EventTask> tasks) {
    if (tasks.isEmpty) return DayData(status: DayStatus.missed, tasks: tasks);

    final doneCount = tasks.where((t) => t.isDone).length;
    late DayStatus status;
    if (doneCount == tasks.length) {
      status = DayStatus.complete;
    } else if (doneCount == 0) {
      status = DayStatus.missed;
    } else {
      status = DayStatus.partial;
    }

    return DayData(status: status, tasks: tasks);
  }

  factory DayData.fromJson(List<dynamic> jsonList) {
    final tasks = jsonList.map((j) => EventTask.fromJson(j)).toList();
    return DayData.fromEventTasks(tasks);
  }
}
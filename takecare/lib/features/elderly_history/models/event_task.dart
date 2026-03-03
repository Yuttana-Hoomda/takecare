// TODO Implement this library.// TODO Implement this library.import 'package:flutter/material.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:flutter/material.dart';

enum DayStatus { complete, missed, partial }

/// Task + สถานะว่าทำเสร็จ
class EventTask {
  final Task task;
  final bool isDone;
  final String? completedAt;

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

// ข้อมูลรวมของแต่ละวัน
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
// เพิ่ม Helper ใน EventTask
extension EventTaskUI on EventTask {
  Color get statusColor {
    if (isDone) return const Color(0xFF4DB887); // สีเขียว Completed

    final now = TimeOfDay.now();
    final isPast = (task.time.hour < now.hour) ||
        (task.time.hour == now.hour && task.time.minute < now.minute);

    return isPast ? Colors.redAccent : Colors.blueAccent;
  }

  String get statusLabel {
    if (isDone) return 'COMPLETED';
    final now = TimeOfDay.now();
    final isPast = (task.time.hour < now.hour) ||
        (task.time.hour == now.hour && task.time.minute < now.minute);
    return isPast ? 'MISSED' : 'UNCOMPLETED';
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/task_timeline_tile.dart';
import '/features/task/providers/task_provider.dart';
import '/features/task/models/task_model.dart';

Widget buildTimelineSection(DateTime selectedDate) {
  return Consumer<TaskProvider>(
    builder: (context, taskProvider, child) {
      final allTasks = taskProvider.tasks ?? [];
      // กรองให้เหลือเฉพาะ Task ที่ตรงกับวัน
      List<Task> displayTasks = allTasks.where((task) {
        return task.createdAt.year == selectedDate.year &&
            task.createdAt.month == selectedDate.month &&
            task.createdAt.day == selectedDate.day;
      }).toList();
      // ถ้าไม่มีกิจกรรม ให้แสดงข้อความแจ้งเตือน
      if (displayTasks.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              children: [
                Icon(Icons.event_note, color: Colors.grey.shade400, size: 48),
                const SizedBox(height: 12),
                Text(
                  'ไม่มีกิจกรรมในวันนี้',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // ถ้ามีกิจกรรม ให้ Sort เรียงเวลา
      displayTasks.sort((a, b) {
        final minutesA = a.time.hour * 60 + a.time.minute;
        final minutesB = b.time.hour * 60 + b.time.minute;
        return minutesA.compareTo(minutesB);
      });

      // แสดงผลรายการกิจกรรมเป็งลิส
      return Column(
        children: displayTasks.map((task) {
          bool isLast = displayTasks.indexOf(task) == displayTasks.length - 1;
          return TaskTimelineTile(task: task, isLast: isLast);
        }).toList(),
      );
    },
  );
}
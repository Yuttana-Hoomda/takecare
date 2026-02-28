import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/task_timeline_tile.dart';
import '/features/task/providers/task_provider.dart';
import '/features/task/models/task_model.dart';

Widget buildTimelineSection(List<Task> mockTasks) {
  return Consumer<TaskProvider>(
    builder: (context, taskProvider, child) {
      // Logic การเลือกข้อมูลเหมือนเดิมที่เบียร์เขียนเลยครับ
      final displayTasks = (taskProvider.tasks != null && taskProvider.tasks!.isNotEmpty)
          ? taskProvider.tasks!
          : mockTasks;

      return Column(
        children: displayTasks.take(3).map((task) {
          return TaskTimelineTile(
            task: task,
            isLast: displayTasks.indexOf(task) == displayTasks.length - 1 ||
                displayTasks.indexOf(task) == 2,
          );
        }).toList(),
      );
    },
  );
}
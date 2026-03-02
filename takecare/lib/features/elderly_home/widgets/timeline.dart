import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/task_timeline_tile.dart';
import '/features/task/providers/task_provider.dart';
import '/features/task/models/task_model.dart';

Widget buildTimelineSection(List<Task> tasks) {
  return Consumer<TaskProvider>(
    builder: (context, taskProvider, child) {
      List<Task> displayTasks = tasks;

      if (taskProvider.tasks != null && taskProvider.tasks!.isNotEmpty) {
        displayTasks = taskProvider.tasks!;
      }

      return Column(
        children: displayTasks.map((task) {
          bool isLast = displayTasks.indexOf(task) == displayTasks.length - 1;
          return TaskTimelineTile(task: task, isLast: isLast);
        }).toList(),
      );
    },
  );
}

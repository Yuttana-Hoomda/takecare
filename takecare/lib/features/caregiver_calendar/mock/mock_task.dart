import 'package:flutter/material.dart';
import 'package:takecare/features/elderly_history/models/event_task.dart';
import 'package:takecare/features/task/models/task_model.dart';

class MockEventData {
  static final Map<String, DayData> data = {
    '2026-03-03': DayData.fromEventTasks([
      EventTask(
        task: Task(
          taskId: '1',
          createdBy: 'u1',
          familyId: 'f1',
          title: 'Morning Meds',
          icon: 'assets/medicine.svg',
          time: const TimeOfDay(hour: 8, minute: 0),
          createdAt: DateTime.now(),
        ),
        isDone: true,
        completedAt: 'Taken at 8:05 AM',
      ),
      EventTask(
        task: Task(
          taskId: '2',
          createdBy: 'u1',
          familyId: 'f1',
          title: 'Lunch',
          icon: 'assets/doctor.svg',
          time: const TimeOfDay(hour: 12, minute: 0), 
          createdAt: DateTime.now(),
        ),
        isDone: false,
      ),
      EventTask(
        task: Task(
          taskId: '3',
          createdBy: 'u1',
          familyId: 'f1',
          title: 'Afternoon Doctor',
          icon: 'assets/doctor.svg',
          time: const TimeOfDay(hour: 15, minute: 50),
          createdAt: DateTime.now(),
        ),
        isDone: false,
      ),
    ]),
    '2026-03-04': DayData.fromEventTasks([
    ]),
  };
}
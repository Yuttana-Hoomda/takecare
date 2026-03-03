import 'package:flutter/material.dart';
import 'package:takecare/features/elderly_history/models/event_task.dart';
import 'package:takecare/features/task/models/task_model.dart';

final Map<String, DayData> mockEventData = {
  '2024-01-01': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '1', createdBy: 'u1', familyId: 'f1',
        title: 'กินยาตอนกลางวัน', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'บันทึกเมื่อ 8:05 AM',
    ),

  ]),
  '2024-01-03': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '3', createdBy: 'u1', familyId: 'f1',
        title: 'ทานยาตอนเช้า', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
      completedAt: 'บันทึกเมื่อ 10:05 AM',
    ),
    EventTask(
      task: Task(
        taskId: '4', createdBy: 'u1', familyId: 'f1',
        title: 'ทานอาหารกลางวัน', icon: '🍽️',
        time: const TimeOfDay(hour: 12, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'บันทึกเมื่อ 12:45 PM',
    ),
  ]),
  '2024-01-05': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '5', createdBy: 'u1', familyId: 'f1',
        title: 'ทานยาตอนเช้า', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
    ),
    EventTask(
      task: Task(
        taskId: '6', createdBy: 'u1', familyId: 'f1',
        title: 'ทานอาหารตอนเย็น', icon: '🍽️',
        time: const TimeOfDay(hour: 12, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
    ),
  ]),
  '2024-01-07': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '7', createdBy: 'u1', familyId: 'f1',
        title: 'ทานยาตอนเช้า', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'บันทึกเมื่อ 7:58 AM',
    ),
    EventTask(
      task: Task(
        taskId: '8', createdBy: 'u1', familyId: 'f1',
        title: 'ออกกำลังกาย', icon: '🏃',
        time: const TimeOfDay(hour: 9, minute: 0),
        createdAt: DateTime.now(),
        note: 'เดิน 30 นาที',
      ),
      isDone: true,
      completedAt: 'บันทึกเมื่อ 9:30 AM',
    ),
    EventTask(
      task: Task(
        taskId: '9', createdBy: 'u1', familyId: 'f1',
        title: 'อาหารเย็น', icon: '🍽️',
        time: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
    ),
  ]),
};
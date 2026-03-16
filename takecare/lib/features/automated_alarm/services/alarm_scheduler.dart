import 'dart:async';
import 'package:flutter/material.dart';
import 'package:takecare/features/automated_alarm/models/automated_alarm_model.dart';
import 'package:takecare/features/automated_alarm/screens/automated_alarm_screen.dart';
import 'package:takecare/features/task/models/task_model.dart';

class AlarmScheduler {
  static AlarmScheduler? _instance;
  static AlarmScheduler get instance => _instance ??= AlarmScheduler._();
  AlarmScheduler._();

  Timer? _timer;
  final Set<String> _firedToday = {};
  GlobalKey<NavigatorState>? _navigatorKey;

  // ✅ เก็บ user info สำหรับ submission
  String _elderlyId = '';
  String _familyId  = '';

  String get elderlyId => _elderlyId;
  String get familyId  => _familyId;

  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    debugPrint('⏰ AlarmScheduler init done');
  }

  // ✅ รับ elderlyId และ familyId ด้วย
  void scheduleTasks(List<Task> tasks, {required String elderlyId, required String familyId}) {
    _elderlyId = elderlyId;
    _familyId  = familyId;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAlarms(tasks);
    });
    _checkAlarms(tasks);

    final alarmTasks = tasks.where((t) => t.requirePhoto == true).toList();
    debugPrint('⏰ AlarmScheduler started: ${tasks.length} tasks, ${alarmTasks.length} require photo');
    for (final t in alarmTasks) {
      debugPrint('   → ${t.title} | ${t.time.hour}:${t.time.minute.toString().padLeft(2, '0')} | days:${t.repeatDays}');
    }
  }

  void _checkAlarms(List<Task> tasks) {
    final now = TimeOfDay.now();
    final dartWeekday = DateTime.now().weekday;
    final jsWeekday = dartWeekday == 7 ? 0 : dartWeekday;

    debugPrint('⏰ tick ${now.hour}:${now.minute.toString().padLeft(2, '0')} jsDay=$jsWeekday');

    for (final task in tasks) {
      if (task.requirePhoto != true) continue;
      if (task.time.hour != now.hour || task.time.minute != now.minute) continue;

      final repeatDays = task.repeatDays;
      if (repeatDays != null && repeatDays.isNotEmpty) {
        if (!repeatDays.contains(jsWeekday)) continue;
      }

      final fireKey = '${task.taskId}_${DateTime.now().day}_${now.hour}_${now.minute}';
      if (_firedToday.contains(fireKey)) continue;

      _firedToday.add(fireKey);
      debugPrint('🔔 Alarm triggered: ${task.title} at ${now.hour}:${now.minute}');
      _showAlarm(task);
    }
  }

  void _showAlarm(Task task) {
    final context = _navigatorKey?.currentContext;
    if (context == null) {
      debugPrint('❌ AlarmScheduler: no context');
      return;
    }

    final alarm = AutomatedAlarmModel(
      id:            task.taskId ?? '',
      title:         task.title,
      scheduledTime: '${task.time.hour.toString().padLeft(2, '0')}:${task.time.minute.toString().padLeft(2, '0')}',
      notes:         task.note,
      elderlyId:     _elderlyId,
      familyId:      _familyId,
    );

    _navigatorKey!.currentState?.push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AutomatedAlarmScreen(alarm: alarm),
      ),
    );
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    debugPrint('⏰ AlarmScheduler disposed');
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:takecare/features/automated_alarm/models/automated_alarm_model.dart';
import 'package:takecare/features/automated_alarm/screens/automated_alarm_screen.dart';
import 'package:takecare/features/automated_alarm/services/notification_service.dart';
import 'package:takecare/features/task/models/task_model.dart';

class AlarmScheduler {
  static AlarmScheduler? _instance;
  static AlarmScheduler get instance => _instance ??= AlarmScheduler._();
  AlarmScheduler._();

  GlobalKey<NavigatorState>? _navigatorKey;

  String _elderlyId = '';
  String _familyId = '';
  bool _scheduled = false;

  String get elderlyId => _elderlyId;
  String get familyId => _familyId;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    NotificationService.instance.onNotificationTap = _handleNotificationTap;
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermissions();
    _checkInitialNotification();
    debugPrint('AlarmScheduler init done');
  }

  Future<void> _checkInitialNotification() async {
    final payload = await NotificationService.instance.getInitialPayload();
    if (payload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(payload);
      });
    }
  }

  // ─────────────────────────────────────────
  // SCHEDULE TASKS — เรียกจาก elder เท่านั้น
  // ─────────────────────────────────────────

  Future<void> scheduleTasks(
    List<Task> tasks, {
    required String elderlyId,
    required String familyId,
    bool forceReschedule = false,
  }) async {
    // ✅ ถ้า elderlyId ว่าง = caregiver เรียก → ไม่ schedule alarm
    if (elderlyId.isEmpty) {
      debugPrint('AlarmScheduler: skip (no elderlyId — caregiver caller)');
      return;
    }

    _elderlyId = elderlyId;
    _familyId = familyId;

    if (_scheduled && !forceReschedule) {
      debugPrint('AlarmScheduler: already scheduled, skip');
      return;
    }
    _scheduled = true;

    int scheduled = 0;
    int skipped = 0;

    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    for (final task in tasks) {
      if (task.taskId == null || task.taskId!.isEmpty) continue;

      final taskMinutes = task.time.hour * 60 + task.time.minute;
      final isOneTime = task.repeatDays == null || task.repeatDays!.isEmpty;

      if (isOneTime && taskMinutes <= nowMinutes) {
        skipped++;
        continue;
      }

      // ✅ ไม่ cancel ก่อน schedule — zonedSchedule ด้วย id เดิมจะ overwrite อัตโนมัติ
      // การ cancel ก่อนทำให้ alarm ที่กำลังจะ fire ถูก cancel ด้วย (pi_cancelled)
      await NotificationService.instance.scheduleTaskNotification(
        taskId: task.taskId!,
        taskTitle: task.title,
        time: task.time,
        repeatDays: task.repeatDays ?? [],
        requirePhoto: task.requirePhoto ?? false,
        elderlyId: elderlyId,
        familyId: familyId,
        note: task.note,
      );
      scheduled++;
    }

    debugPrint('AlarmScheduler: scheduled=$scheduled skipped=$skipped');
  }

  Future<void> rescheduleAll(
    List<Task> tasks, {
    required String elderlyId,
    required String familyId,
  }) async {
    if (elderlyId.isEmpty) return;
    _scheduled = false;
    await scheduleTasks(
      tasks,
      elderlyId: elderlyId,
      familyId: familyId,
      forceReschedule: true,
    );
  }

  Future<void> cancelTask(String taskId) async {
    await NotificationService.instance.cancelTaskNotification(taskId);
  }

  // ─────────────────────────────────────────
  // HANDLE NOTIFICATION TAP
  // ─────────────────────────────────────────

  void _handleNotificationTap(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final alarm = AutomatedAlarmModel(
        id: data[kPayloadTaskId] as String,
        title: data[kPayloadTaskTitle] as String,
        scheduledTime: data[kPayloadTime] as String,
        notes: data[kPayloadNote] as String?,
        elderlyId: data[kPayloadElderlyId] as String,
        familyId: data[kPayloadFamilyId] as String,
        requirePhoto: data[kPayloadRequirePhoto] as bool? ?? false,
      );

      final navigator = _navigatorKey?.currentState;
      if (navigator == null) {
        debugPrint('AlarmScheduler: navigator not ready, retry in 500ms');
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(payload);
        });
        return;
      }

      navigator.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => AutomatedAlarmScreen(alarm: alarm),
        ),
      );
    } catch (e) {
      debugPrint('AlarmScheduler._handleNotificationTap error: $e');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String kAlarmChannelId = 'takecare_alarm';
const String kAlarmChannelName = 'Task Alarms';
const String kReminderChannelId = 'takecare_reminder';
const String kReminderChannelName = 'Task Reminders';

const String kPayloadTaskId = 'taskId';
const String kPayloadTaskTitle = 'taskTitle';
const String kPayloadRequirePhoto = 'requirePhoto';
const String kPayloadElderlyId = 'elderlyId';
const String kPayloadFamilyId = 'familyId';
const String kPayloadTime = 'scheduledTime';
const String kPayloadNote = 'note';
const String kPayloadRepeatDays = 'repeatDays'; // ✅ เพิ่ม

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  void Function(String payload)? onNotificationTap;

  // ─────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    await _createChannels();
    debugPrint('NotificationService initialized (Asia/Bangkok)');
  }

  Future<void> _createChannels() async {
    const alarm = AndroidNotificationChannel(
      kAlarmChannelId,
      kAlarmChannelName,
      description: 'Alarms for tasks that require photo proof',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    const reminder = AndroidNotificationChannel(
      kReminderChannelId,
      kReminderChannelName,
      description: 'Reminders for regular tasks',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(alarm);
    await androidPlugin?.createNotificationChannel(reminder);
  }

  // ─────────────────────────────────────────
  // PERMISSIONS
  // ─────────────────────────────────────────

  Future<bool> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notifGranted =
        await androidPlugin?.requestNotificationsPermission() ?? false;
    final fullScreenGranted =
        await androidPlugin?.requestFullScreenIntentPermission() ?? false;
    await androidPlugin?.requestExactAlarmsPermission();
    debugPrint(
      'Permissions: notification=$notifGranted fullScreen=$fullScreenGranted',
    );
    return notifGranted;
  }

  // ─────────────────────────────────────────
  // SCHEDULE
  // ─────────────────────────────────────────

  Future<void> scheduleTaskNotification({
    required String taskId,
    required String taskTitle,
    required TimeOfDay time,
    required List<int> repeatDays, // JS weekday: 0=Sun..6=Sat
    required bool requirePhoto,
    required String elderlyId,
    required String familyId,
    String? note,
  }) async {
    final id = taskId.hashCode.abs() % 100000;
    final payload = _buildPayload(
      taskId: taskId,
      taskTitle: taskTitle,
      requirePhoto: requirePhoto,
      elderlyId: elderlyId,
      familyId: familyId,
      time:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      note: note,
      repeatDays: repeatDays,
    );

    final androidDetails = AndroidNotificationDetails(
      requirePhoto ? kAlarmChannelId : kReminderChannelId,
      requirePhoto ? kAlarmChannelName : kReminderChannelName,
      channelDescription: requirePhoto
          ? 'ถึงเวลาทำรายการ (ต้องถ่ายรูปยืนยัน)'
          : 'ถึงเวลาทำรายการ',
      importance: requirePhoto ? Importance.max : Importance.high,
      priority: requirePhoto ? Priority.max : Priority.high,
      fullScreenIntent: true, // ขึ้นเต็มหน้าจอทุก task
      category: requirePhoto
          ? AndroidNotificationCategory.alarm
          : AndroidNotificationCategory.reminder,
      actions: requirePhoto
          ? null
          : [
              const AndroidNotificationAction(
                'done',
                'เสร็จสิ้น',
                showsUserInterface: false,
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                'snooze',
                'เลื่อน 15 นาที',
                showsUserInterface: false,
                cancelNotification: false,
              ),
            ],
      ticker: taskTitle,
      styleInformation: BigTextStyleInformation(
        note != null && note.isNotEmpty ? note : 'กดเพื่อดูรายละเอียด',
        summaryText: taskTitle,
      ),
    );

    final scheduledDate = _nextInstanceOfTime(time, repeatDays);

    try {
      await _plugin.zonedSchedule(
        id,
        taskTitle,
        requirePhoto
            ? 'ถึงเวลา! กรุณาถ่ายรูปยืนยัน'
            : (note ?? 'ถึงเวลาทำรายการ'),
        scheduledDate,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint(
        'Scheduled: "$taskTitle" id=$id at ${scheduledDate.toLocal()} repeat=$repeatDays',
      );

      // verify pending
      final pending = await _plugin.pendingNotificationRequests();
      debugPrint('Pending after schedule: ${pending.length} notifications');
      for (final p in pending) {
        debugPrint('  pending id=${p.id} title="${p.title}"');
      }
    } catch (e, stack) {
      debugPrint('❌ zonedSchedule FAILED: $e');
      debugPrint('Stack: $stack');
    }
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time, List<int> repeatDays) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final buffer = now.add(const Duration(seconds: 30));

    debugPrint(
      'nextInstanceOfTime | now=${now.toLocal()} | '
      'task=${time.hour}:${time.minute.toString().padLeft(2, '0')} | '
      'scheduled(today)=${scheduled.toLocal()} | buffer=${buffer.toLocal()}',
    );

    if (repeatDays.isEmpty) {
      // one-time: ถ้าผ่านไปแล้ววันนี้ → วันพรุ่งนี้
      if (scheduled.isBefore(buffer)) {
        scheduled = scheduled.add(const Duration(days: 1));
        debugPrint('  one-time: past buffer -> ${scheduled.toLocal()}');
      } else {
        debugPrint('  one-time: still future -> keep today');
      }
      return scheduled;
    }

    // repeat: เช็ควันนี้ก่อน (JS weekday)
    final todayJsDay = now.weekday % 7; // dart: 1=Mon..7=Sun → js: 0=Sun..6=Sat
    final stillTodayTime = scheduled.isAfter(buffer);

    debugPrint(
      '  repeat: todayJsDay=$todayJsDay repeatDays=$repeatDays stillTodayTime=$stillTodayTime',
    );

    if (repeatDays.contains(todayJsDay) && stillTodayTime) {
      debugPrint('  repeat: schedule today ${scheduled.toLocal()}');
      return scheduled;
    }

    // หาวันถัดไปใน repeatDays
    scheduled = scheduled.add(const Duration(days: 1));
    for (var i = 0; i < 7; i++) {
      final jsDay = scheduled.weekday % 7;
      if (repeatDays.contains(jsDay)) {
        debugPrint('  repeat: next day found -> ${scheduled.toLocal()}');
        return scheduled;
      }
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  String _buildPayload({
    required String taskId,
    required String taskTitle,
    required bool requirePhoto,
    required String elderlyId,
    required String familyId,
    required String time,
    required List<int> repeatDays,
    String? note,
  }) {
    return jsonEncode({
      kPayloadTaskId: taskId,
      kPayloadTaskTitle: taskTitle,
      kPayloadRequirePhoto: requirePhoto,
      kPayloadElderlyId: elderlyId,
      kPayloadFamilyId: familyId,
      kPayloadTime: time,
      kPayloadNote: note ?? '',
      kPayloadRepeatDays: repeatDays, // ✅ เก็บไว้ใช้ reschedule
    });
  }

  // ─────────────────────────────────────────
  // TAP HANDLERS
  // ─────────────────────────────────────────

  void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final actionId = response.actionId;
    if (actionId == 'done') {
      _handleDoneAction(payload);
      return;
    }
    if (actionId == 'snooze') {
      _handleSnoozeAction(payload);
      return;
    }

    // ✅ [FIX] หลัง user tap → reschedule ครั้งต่อไปทันที (one-shot pattern)
    _rescheduleAfterFire(payload);

    onNotificationTap?.call(payload);
  }

  /// Reschedule notification ครั้งถัดไปหลัง fire แล้ว (สำหรับ repeat tasks)
  void _rescheduleAfterFire(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final repeatDays = List<int>.from(
        data[kPayloadRepeatDays] as List? ?? [],
      );
      if (repeatDays.isEmpty) return; // one-time → ไม่ต้อง reschedule

      final timeStr = data[kPayloadTime] as String;
      final parts = timeStr.split(':');
      final time = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );

      // schedule ครั้งถัดไปใน repeatDays (จะข้ามไปวันพรุ่งนี้เป็น minimum)
      final nextDate = _nextOccurrenceAfterToday(time, repeatDays);

      final id = (data[kPayloadTaskId] as String).hashCode.abs() % 100000;
      final taskTitle = data[kPayloadTaskTitle] as String;
      final requirePhoto = data[kPayloadRequirePhoto] as bool? ?? false;
      final note = data[kPayloadNote] as String?;

      final androidDetails = AndroidNotificationDetails(
        requirePhoto ? kAlarmChannelId : kReminderChannelId,
        requirePhoto ? kAlarmChannelName : kReminderChannelName,
        importance: requirePhoto ? Importance.max : Importance.high,
        priority: requirePhoto ? Priority.max : Priority.high,
        fullScreenIntent: true, // ขึ้นเต็มหน้าจอทุก task
        category: requirePhoto
            ? AndroidNotificationCategory.alarm
            : AndroidNotificationCategory.reminder,
        actions: requirePhoto
            ? null
            : [
                const AndroidNotificationAction(
                  'done',
                  'เสร็จสิ้น',
                  showsUserInterface: false,
                  cancelNotification: true,
                ),
                const AndroidNotificationAction(
                  'snooze',
                  'เลื่อน 15 นาที',
                  showsUserInterface: false,
                  cancelNotification: false,
                ),
              ],
      );

      _plugin.zonedSchedule(
        id,
        taskTitle,
        requirePhoto
            ? 'ถึงเวลา! กรุณาถ่ายรูปยืนยัน'
            : (note ?? 'ถึงเวลาทำรายการ'),
        nextDate,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint(
        'Rescheduled after fire: "$taskTitle" at ${nextDate.toLocal()}',
      );
    } catch (e) {
      debugPrint('_rescheduleAfterFire error: $e');
    }
  }

  /// หาวันที่ถัดไปใน repeatDays โดยเริ่มจากพรุ่งนี้เสมอ
  tz.TZDateTime _nextOccurrenceAfterToday(
    TimeOfDay time,
    List<int> repeatDays,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(const Duration(days: 1)); // เริ่มจากพรุ่งนี้เสมอ

    for (var i = 0; i < 7; i++) {
      final jsDay = next.weekday % 7;
      if (repeatDays.contains(jsDay)) return next;
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  void _handleDoneAction(String payload) {
    _rescheduleAfterFire(payload); // reschedule ด้วยแม้ done จาก action button
    debugPrint('Done action tapped');
  }

  void _handleSnoozeAction(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final timeStr = data[kPayloadTime] as String;
      final parts = timeStr.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final total = h * 60 + m + 15;

      scheduleTaskNotification(
        taskId: '${data[kPayloadTaskId]}_snooze',
        taskTitle: data[kPayloadTaskTitle] as String,
        time: TimeOfDay(hour: total ~/ 60 % 24, minute: total % 60),
        repeatDays: [], // snooze = one-shot
        requirePhoto: data[kPayloadRequirePhoto] as bool? ?? false,
        elderlyId: data[kPayloadElderlyId] as String,
        familyId: data[kPayloadFamilyId] as String,
        note: data[kPayloadNote] as String?,
      );

      // reschedule ครั้งถัดไปปกติด้วย
      _rescheduleAfterFire(payload);
      debugPrint('Snoozed 15 min: ${data[kPayloadTaskTitle]}');
    } catch (e) {
      debugPrint('Snooze error: $e');
    }
  }

  Future<String?> getInitialPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      return details?.notificationResponse?.payload;
    }
    return null;
  }

  Future<void> cancelTaskNotification(String taskId) async {
    final id = taskId.hashCode.abs() % 100000;
    await _plugin.cancel(id);
    debugPrint('Cancelled notification id=$id ($taskId)');
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('All notifications cancelled');
  }
}

@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse response) {
  debugPrint('Background tap: ${response.actionId}');
}

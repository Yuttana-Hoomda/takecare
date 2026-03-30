import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/features/task_submission/providers/task_submission_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/next_task_card.dart';
import '../widgets/action_card.dart';
import '../widgets/schedule_item.dart';
import '/constants/app_theme.dart';

final RouteObserver<ModalRoute> elderlyHomeRouteObserver = RouteObserver<ModalRoute>();

class ElderlyHomeScreen extends StatefulWidget {
  const ElderlyHomeScreen({super.key});

  @override
  State<ElderlyHomeScreen> createState() => _ElderlyHomeScreenState();
}

class _ElderlyHomeScreenState extends State<ElderlyHomeScreen> with RouteAware {
  static final RouteObserver<ModalRoute> routeObserver = elderlyHomeRouteObserver;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    log('กลับมาที่หน้า Home: รีโหลดข้อมูล');
    _init();
  }

  Future<void> _init() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final familyId = user?.familyId;
    final elderlyId = user?.uid ?? '';
    final token = auth.firebaseToken ?? '';

    if (familyId == null) return;
    // โหลดข้อมูล Task และ Submission
    await Provider.of<TaskProvider>(context, listen: false)
        .getTasks(familyId, elderlyId: elderlyId);
    await Provider.of<TaskSubmissionProvider>(context, listen: false)
        .loadByFamily(familyId: familyId, token: token);
  }
  // ✅ ฟังก์ชันเช็กว่าทำเสร็จหรือยัง (ส่งค่าไปให้ ScheduleItem)
  bool _isTaskCompletedToday(Task task) {
    final submissionProvider = Provider.of<TaskSubmissionProvider>(context, listen: false);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 🔴 เพิ่ม Print เพื่อ Debug
    print("--- กำลังเช็ก Task: ${task.title} (ID: ${task.taskId}) ---");
    print("จำนวน Submission ทั้งหมดที่โหลดมา: ${submissionProvider.submissions.length}");

    return submissionProvider.submissions.any((s) {
      final sDate = s.createdAt.toLocal();
      final submissionDay = DateTime(sDate.year, sDate.month, sDate.day);

      bool isMatch = s.taskId == task.taskId && submissionDay.isAtSameMomentAs(today);

      if (s.taskId == task.taskId) {
        print("เจอ ID ตรงกัน! แต่วันที่ตรงไหม? -> ${submissionDay.isAtSameMomentAs(today)} (Submission Date: $submissionDay | Today: $today)");
      }

      return isMatch;
    });
  }
  // ✅ กรองเฉพาะ Task ที่ต้องแสดงวันนี้ (โชว์ทั้งหมด ไม่ตัดอันที่ทำแล้วทิ้ง)
  List<Task> _filterTasksForToday(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayWeekday = now.weekday;
    final todayDateStr = now.toIso8601String().substring(0, 10);

    final filtered = tasks.where((task) {
      if (task.date != null && task.date!.isNotEmpty) {
        return task.date!.startsWith(todayDateStr);
      }
      if (task.repeatDays != null && task.repeatDays!.isNotEmpty) {
        return task.repeatDays!.contains(todayWeekday);
      }
      return false;
    }).toList();

    filtered.sort((a, b) {
      final aMin = a.time.hour * 60 + a.time.minute;
      final bMin = b.time.hour * 60 + b.time.minute;
      return aMin.compareTo(bMin);
    });

    return filtered;
  }

  // ✅ Next Task: เอาอันถัดไปที่ "ยังไม่ได้ทำ"
  Task? _getNextTask(List<Task> tasks) {
    final remainingTasks = tasks.where((t) => !_isTaskCompletedToday(t)).toList();
    if (remainingTasks.isEmpty) return null;
    return remainingTasks.first;
  }

  bool _isNow(Task task) {
    final now = TimeOfDay.now();
    final taskMin = task.time.hour * 60 + task.time.minute;
    final nowMin = now.hour * 60 + now.minute;
    return (taskMin - nowMin).abs() <= 30;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks ?? [];
    final todayTasks = _filterTasksForToday(allTasks);
    final nextTask = _getNextTask(todayTasks);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.bgColorDark : AppTheme.bgColorLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.bgColorDark : Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        title: const HomeHeader(),
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async => _init(),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          children: [
            const Text('กิจกรรมที่กำลังจะมาถึง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            NextTaskCard(
              task: nextTask,
              onComplete: () async => _init(),
            ),
            const SizedBox(height: 20),
            const ActionButtons(),
            const SizedBox(height: 24),
            _ScheduleHeader(),
            const SizedBox(height: 12),
            if (todayTasks.isEmpty)
              const Center(child: Text("ไม่มีกิจกรรมวันนี้"))
            else
              ...todayTasks.asMap().entries.map((e) {
                final task = e.value;
                return ScheduleItem(
                  task: task,
                  isNow: _isNow(task),
                  isLast: e.key == todayTasks.length - 1,
                  isCompleted: _isTaskCompletedToday(task), // 🔥 ส่งค่าไปที่นี่
                );
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ตารางวันนี้',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'ดูทั้งหมด',
            style: TextStyle(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
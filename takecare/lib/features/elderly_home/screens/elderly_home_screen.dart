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

final RouteObserver<ModalRoute> elderlyHomeRouteObserver =
RouteObserver<ModalRoute>();

class ElderlyHomeScreen extends StatefulWidget {
  const ElderlyHomeScreen({super.key});

  @override
  State<ElderlyHomeScreen> createState() => _ElderlyHomeScreenState();
}

class _ElderlyHomeScreenState extends State<ElderlyHomeScreen>
    with RouteAware {

  static final RouteObserver<ModalRoute> routeObserver =
      elderlyHomeRouteObserver;

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
    log('didPopNext called');
    _init();
  }

  Future<void> _init() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final familyId = user?.familyId;
    final elderlyId = user?.uid ?? '';
    final token = auth.firebaseToken ?? '';

    if (familyId == null) return;

    // โหลด tasks
    await Provider.of<TaskProvider>(context, listen: false)
        .getTasks(familyId, elderlyId: elderlyId);

    // โหลด submissions วันนี้
    await Provider.of<TaskSubmissionProvider>(context, listen: false)
        .loadByFamily(familyId: familyId, token: token);
  }

  // ✅ helper: เช็คว่า task นี้ "ทำแล้ววันนี้"
  bool _isTaskCompletedToday(Task task) {
    final submissionProvider =
    Provider.of<TaskSubmissionProvider>(context, listen: false);

    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    return submissionProvider.submissions.any((s) =>
    s.taskId == task.taskId &&
        s.createdAt.toIso8601String().startsWith(todayStr));
  }

  List<Task> _filterTasksForToday(List<Task> tasks) {
    final today = DateTime.now();
    final todayWeekday = today.weekday;
    final todayDateStr = today.toIso8601String().substring(0, 10);

    final filtered = tasks.where((task) {
      // fixed date
      if (task.date != null && task.date!.isNotEmpty) {
        return task.date!.startsWith(todayDateStr);
      }

      // repeat
      if (task.repeatDays == null || task.repeatDays!.isEmpty) {
        return false;
      }

      return task.repeatDays!.contains(todayWeekday);
    }).toList();

    filtered.sort((a, b) {
      final aMin = a.time.hour * 60 + a.time.minute;
      final bMin = b.time.hour * 60 + b.time.minute;
      return aMin.compareTo(bMin);
    });

    return filtered;
  }

  Task? _getNextTask(List<Task> tasks) {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;

    final upcoming = tasks.where((t) {
      // ✅ ข้ามถ้าทำแล้ว "วันนี้"
      if (_isTaskCompletedToday(t)) return false;

      final taskMin = t.time.hour * 60 + t.time.minute;

      // ❌ ข้ามถ้าเลยเวลาแล้ว (ถือว่า miss)
      return taskMin >= nowMin;
    }).toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) {
      final aMin = a.time.hour * 60 + a.time.minute;
      final bMin = b.time.hour * 60 + b.time.minute;
      return aMin.compareTo(bMin);
    });

    return upcoming.first;
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
    final submissionProvider = Provider.of<TaskSubmissionProvider>(context);

    final allTasks = taskProvider.tasks ?? [];
    final todayTasks = _filterTasksForToday(allTasks);
    final nextTask = _getNextTask(todayTasks);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDarkMode ? AppTheme.bgColorDark : AppTheme.bgColorLight,
      appBar: AppBar(
        backgroundColor:
        isDarkMode ? AppTheme.bgColorDark : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        titleSpacing: 20,
        title: const HomeHeader(),
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async => _init(),
        child: ListView(
          padding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          children: [
            Text(
              'กิจกรรมที่กำลังจะมาถึง',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            NextTaskCard(
              task: nextTask,
              onComplete: () async {
                await _init();
              },
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
                  isCompleted: _isTaskCompletedToday(task), // ✅ เพิ่ม
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
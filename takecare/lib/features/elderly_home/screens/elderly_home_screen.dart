import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/next_task_card.dart';
import '../widgets/action_card.dart';
import '../widgets/schedule_item.dart';
import '/constants/app_theme.dart';

class ElderlyHomeScreen extends StatefulWidget {
  const ElderlyHomeScreen({super.key});

  @override
  State<ElderlyHomeScreen> createState() => _ElderlyHomeScreenState();
}

class _ElderlyHomeScreenState extends State<ElderlyHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchTasks());
  }

  void _fetchTasks() {
    final familyId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).user?.familyId;
    if (familyId != null) {
      Provider.of<TaskProvider>(context, listen: false).getTasks(familyId);
    }
  }

  List<Task> _filterTasksForToday(List<Task> tasks) {
    final today = DateTime.now();
    // backend ใช้ 0=อาทิตย์ ... 6=เสาร์
    // Flutter weekday: 1=จันทร์ ... 7=อาทิตย์ → แปลงเป็น 0-6
    final todayWeekday = today.weekday % 7; // จันทร์=1→1, อาทิตย์=7→0
    final todayDateStr = today.toIso8601String().substring(0, 10);

    final filtered = tasks.where((task) {
      // เช็ค date ตรงวันนี้ก่อนเสมอ ไม่ว่า isRepeatByDate จะเป็นอะไร
      if (task.date != null && task.date!.isNotEmpty) {
        final match = task.date!.startsWith(todayDateStr);
        log(
          '[date] ${task.title} | date="${task.date}" | today="$todayDateStr" | match=$match',
        );
        return match;
      }
      // ถ้าไม่มี date ค่อยเช็ค repeatDays
      if (task.repeatDays == null || task.repeatDays!.isEmpty) {
        log('[repeat] ${task.title} | repeatDays=[] → skip');
        return false;
      }
      final match = task.repeatDays!.contains(todayWeekday);
      log(
        '[repeat] ${task.title} | repeatDays=${task.repeatDays} | weekday=$todayWeekday | match=$match',
      );
      return match;
    }).toList();

    log('→ filtered ${filtered.length}/${tasks.length} tasks for today');

    // เรียงตามเวลา
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
      final taskMin = t.time.hour * 60 + t.time.minute;
      return taskMin >= nowMin - 30;
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
    final allTasks = taskProvider.tasks ?? [];
    final todayTasks = _filterTasksForToday(allTasks);
    final nextTask = _getNextTask(todayTasks);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? AppTheme.bgColorDark
          : AppTheme.bgColorLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppTheme.bgColorDark : Colors.white,
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
              onRefresh: () async => _fetchTasks(),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
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
                  NextTaskCard(task: nextTask),
                  const SizedBox(height: 20),
                  const ActionButtons(),
                  const SizedBox(height: 24),
                  _ScheduleHeader(),
                  const SizedBox(height: 12),
                  if (todayTasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'ไม่มีกิจกรรมสำหรับวันนี้',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...todayTasks.asMap().entries.map(
                      (e) => ScheduleItem(
                        task: e.value,
                        isNow: _isNow(e.value),
                        isLast: e.key == todayTasks.length - 1,
                      ),
                    ),
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
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          child: Text(
            'ดูทั้งหมด',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/features/elderly_home/provider/history_provider.dart';
import 'features/elderly_home/models/event_task.dart';
import 'features/elderly_home/screens/elderly_history_screen.dart';



/// รันด้วย: flutter run -t lib/main_test.dart

void main() {
  runApp(const TestApp());
}

// ---------------------------------------------------------------------------
// Mock Data — ครบทั้ง complete / partial / missed
// ---------------------------------------------------------------------------

final _mockEventData = <String, DayData>{
  '2024-01-01': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '1', createdBy: 'u1', familyId: 'f1',
        title: 'Morning Meds', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'Taken at 8:05 AM',
    ),
    EventTask(
      task: Task(
        taskId: '2', createdBy: 'u1', familyId: 'f1',
        title: 'Lunch', icon: '🍽️',
        time: const TimeOfDay(hour: 12, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'Logged at 12:30 PM',
    ),
  ]),
  '2024-01-03': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '3', createdBy: 'u1', familyId: 'f1',
        title: 'Morning Meds', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
    ),
    EventTask(
      task: Task(
        taskId: '4', createdBy: 'u1', familyId: 'f1',
        title: 'Lunch', icon: '🍽️',
        time: const TimeOfDay(hour: 12, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'Logged at 12:45 PM',
    ),
  ]),
  '2024-01-05': DayData.fromEventTasks([
    EventTask(
      task: Task(
        taskId: '5', createdBy: 'u1', familyId: 'f1',
        title: 'Morning Meds', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
    ),
    EventTask(
      task: Task(
        taskId: '6', createdBy: 'u1', familyId: 'f1',
        title: 'Lunch', icon: '🍽️',
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
        title: 'Morning Meds', icon: '💊',
        time: const TimeOfDay(hour: 8, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: true,
      completedAt: 'Taken at 7:58 AM',
    ),
    EventTask(
      task: Task(
        taskId: '8', createdBy: 'u1', familyId: 'f1',
        title: 'Exercise', icon: '🏃',
        time: const TimeOfDay(hour: 9, minute: 0),
        createdAt: DateTime.now(),
        note: '30 min walk',
      ),
      isDone: true,
      completedAt: 'Done at 9:30 AM',
    ),
    EventTask(
      task: Task(
        taskId: '9', createdBy: 'u1', familyId: 'f1',
        title: 'Dinner', icon: '🍽️',
        time: const TimeOfDay(hour: 18, minute: 0),
        createdAt: DateTime.now(),
      ),
      isDone: false,
    ),
  ]),
};

// ---------------------------------------------------------------------------

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _MockWrapper(),
      ),
    );
  }
}

class _MockWrapper extends StatefulWidget {
  const _MockWrapper();

  @override
  State<_MockWrapper> createState() => _MockWrapperState();
}

class _MockWrapperState extends State<_MockWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false)
          .loadMockData(_mockEventData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ElderlyCalendarScreen();
  }
}
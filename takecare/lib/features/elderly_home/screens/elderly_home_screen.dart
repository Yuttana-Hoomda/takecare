import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/greeting.dart';
import '/constants/app_theme.dart';
import '/features/auth/providers/auth_provider.dart';
import '/features/task/models/task_model.dart';
import '../widgets/action_card.dart';
import '../widgets/header.dart';
import '../widgets/scheduleHeader.dart';
import '../widgets/timeline.dart';

class ElderlyHomeScreen extends StatelessWidget {
  const ElderlyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //mockData------------------------
    final List<Task> mockTasks = [
      Task(
        taskId: '1',
        title: 'Blood Pressure Meds',
        time: const TimeOfDay(hour: 8, minute: 0),
        note: 'with food',
        icon: 'assets/doctor.svg',
        familyId: 'f1',
        createdBy: 'u1',
        createdAt: DateTime.now(),
      ),
      Task(
        taskId: '2',
        title: 'Lunch Reminder',
        time: const TimeOfDay(hour: 12, minute: 0),
        note: 'mamamiaaa',
        icon: 'assets/doctor.svg',
        familyId: 'f1',
        createdBy: 'u1',
        createdAt: DateTime.now(),
      ),
      Task(
        taskId: '3',
        createdBy: 'cat',
        familyId: '2',
        title: 'กินข้าว',
        time: const TimeOfDay(hour: 12, minute: 0),
        createdAt: DateTime.now(),
        icon: 'assets/medicine.svg',
        note: 'มะนาว',
      ),
    ];
    //-------------------------------------------------------------------
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            buildHeader(),
            const SizedBox(height: 20),
            Text(
              GreetingHelper.getGreeting(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, child) => Text(
                auth.user?.displayName ?? "Beer",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              'Ready for a great day?',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppTheme.subtitle),
            ),
            const SizedBox(height: 20),
            buildActionCards(),
            const SizedBox(height: 20),
            buildScheduleHeader(context),
            const SizedBox(height: 16),
            buildTimelineSection(mockTasks),
          ],
        ),
      ),
    );
  }
}

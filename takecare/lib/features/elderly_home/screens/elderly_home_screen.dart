import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/utils/greeting.dart';
import '/constants/app_theme.dart';
import '/features/auth/providers/auth_provider.dart';
import '/features/task/providers/task_provider.dart';
import '../widgets/action_card.dart';
import '../widgets/header.dart';
import '../widgets/scheduleHeader.dart';
import '../widgets/timeline.dart';

class ElderlyHomeScreen extends StatefulWidget {
  const ElderlyHomeScreen({super.key});

  @override
  State<ElderlyHomeScreen> createState() => _ElderlyHomeScreenState();
}

class _ElderlyHomeScreenState extends State<ElderlyHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user?.familyId != null) {
        Provider.of<TaskProvider>(context, listen: false).getTasks(
          user!.familyId!,
          elderlyId: user.uid, // ✅ ส่ง elderlyId
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            buildHeader(context),
            const SizedBox(height: 20),
            Text(
              GreetingHelper.getGreeting(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
            ),
            Consumer<AuthProvider>(
              builder: (context, auth, child) => Text(
                auth.user?.displayName ?? '',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'พร้อมสำหรับวันดี ๆ หรือยัง?',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: AppTheme.subtitle),
            ),
            const SizedBox(height: 20),
            buildActionCards(),
            const SizedBox(height: 20),
            buildScheduleHeader(context),
            const SizedBox(height: 16),
            buildTimelineSection(DateTime.now()),
          ],
        ),
      ),
    );
  }
}

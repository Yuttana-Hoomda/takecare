import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';

import 'package:takecare/features/caregiver_home/screens/caregiver_home_screen.dart';
import 'package:takecare/features/caregiver_home/providers/caregiver_home_provider.dart';
import 'package:takecare/features/elderly_home/screens/elderly_home_screen.dart';

import 'package:takecare/features/task/screens/task_screen.dart';
import 'package:takecare/features/history/screens/history_screen.dart';

import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/features/automated_alarm/services/alarm_scheduler.dart';
import 'package:takecare/features/auth/models/user_model.dart';
import 'package:takecare/test_task_alarm.dart';

import '../../../test_food_alarm.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  bool _taskLoaded = false;

  List<Widget> _pages = [];
  List<NavigationDestination> _navItems = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.read<AuthProvider>();
    final user = auth.user;

    if (!_taskLoaded && user?.role == Role.elder && user?.familyId != null) {
      _taskLoaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TaskProvider>().getTasks(
          user!.familyId!,
          elderlyId: user.uid,
        );
        // schedule food alarms ตาม foodTime ของ elder
        if (user is ElderUser) {
          AlarmScheduler.instance.scheduleFoodAlarms(user);
        }
      });
    }
  }

  void _setupCaregiverView() {
    _pages = [
      const CaregiverHomeScreen(),
      const TaskScreen(),
      const HistoryScreen(),
    ];

    _navItems = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'หน้าแรก',
      ),
      NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'รายการ',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'ประวัติ',
      ),
    ];
  }

  void _setupElderView() {
    _pages = [
      const ElderlyHomeScreen(),
      const HistoryScreen(),
      const TestFoodAlarmApp(),
      const TestTaskAlarmApp(),
    ];

    _navItems = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'หน้าแรก',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'ประวัติ',
      ),
      NavigationDestination(
        icon: Icon(Icons.punch_clock_outlined),
        selectedIcon: Icon(Icons.punch_clock),
        label: 'test alarm',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'โปรไฟล์',
      ),
    ];
  }

  Widget _buildScaffold() {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: _navItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isCaregiver = user?.role == Role.caregiver;

    if (isCaregiver) {
      _setupCaregiverView();
    } else {
      _setupElderView();
    }

    // [FIX] ไม่ใช้ MultiProvider เพราะถ้า providers list ว่าง (elder) จะ crash
    // ใช้ ChangeNotifierProvider เดี่ยวเฉพาะ caregiver แทน
    if (isCaregiver) {
      return ChangeNotifierProvider(
        create: (_) => CaregiverHomeProvider(),
        child: _buildScaffold(),
      );
    }

    return _buildScaffold();
  }
}

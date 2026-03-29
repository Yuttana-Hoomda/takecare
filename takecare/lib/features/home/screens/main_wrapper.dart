import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';

import 'package:takecare/features/caregiver_home/screens/caregiver_home_screen.dart';
import 'package:takecare/features/elderly_home/screens/elderly_home_screen.dart';

import 'package:takecare/features/task/screens/task_screen.dart';
import 'package:takecare/features/history/screens/history_screen.dart';

import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/test_task_alarm.dart';

import '../../../test_food_alarm.dart';

// 👇 ถ้ามีจริงค่อย import
// import 'package:takecare/features/calendar/screens/caregiver_calendar_screen.dart';
// import 'package:takecare/features/calendar/screens/elderly_calendar_screen.dart';

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

    // ✅ โหลด task สำหรับ elder เพื่อใช้ alarm
    if (!_taskLoaded && user?.role == Role.elder && user?.familyId != null) {
      _taskLoaded = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TaskProvider>().getTasks(
          user!.familyId!,
          elderlyId: user.uid,
        );
      });
    }
  }

  void _setupCaregiverView() {
    _pages = [
      const CaregiverHomeScreen(),
      const TaskScreen(),
      const HistoryScreen(), // หรือ CaregiverCalendarScreen()
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
      const HistoryScreen(), // หรือ ElderlyCalendarScreen()
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isCaregiver = user?.role == Role.caregiver;

    // ✅ setup view ตาม role
    if (isCaregiver) {
      _setupCaregiverView();
    } else {
      _setupElderView();
    }

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
}

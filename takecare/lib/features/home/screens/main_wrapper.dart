import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/caregiver_home/screens/caregiver_home_screen.dart';
import 'package:takecare/features/elderly_home/screens/elderly_history_screen.dart';
import 'package:takecare/features/elderly_home/screens/elderly_home_screen.dart';
import 'package:takecare/features/task/screens/task_screen.dart';
import 'package:takecare/test_medication_alarm_overlay.dart';
import '../../../test_food_alarm.dart';
import '../../auth/providers/auth_provider.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  List<Widget> _pages = [];
  List<NavigationDestination> _navItems = [];

  void _setupCaregiverView() {
    _pages = [
      const CaregiverHomeScreen(), //   Home → CaregiverHomeScreen
      const TaskScreen(), // Tasks
      const Placeholder(), // Profile
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
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'โปรไฟล์',
      ),
    ];
  }

  void _setupElderView() {
    _pages = [
      const ElderlyHomeScreen(),
      const ElderlyCalendarScreen(),// Home
      const TestFoodAlarmApp(),
      const Placeholder(), // Profile
    ];

    _navItems = const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'calendar',
      ),
      NavigationDestination(
        icon: Icon(Icons.punch_clock_outlined),
        selectedIcon: Icon(Icons.punch_clock),
        label: 'test alarm',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isCaregiver = user?.role == Role.caregiver;

    if (isCaregiver) {
      _setupCaregiverView();
    } else {
      _setupElderView();
    }

    return Scaffold(
      backgroundColor: AppTheme.bgColorLight,
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
          onDestinationSelected: (int index) {
            setState(() => _currentIndex = index);
          },
          destinations: _navItems,
        ),
      ),
    );
  }
}

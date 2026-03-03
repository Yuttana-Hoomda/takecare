import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/task/screens/task_screen.dart';
import 'package:takecare/features/elderly_home/screens/elderly_home_screen.dart';
import 'package:takecare/features/elderly_history/screens/elderly_history_screen.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:takecare/features/caregiver_calendar/screens/caregiver_calendar_screen.dart';
import 'package:takecare/features/caregiver_home/screens/caregiver_home_screen.dart';


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
      const CaregiverHomeScreen(), // Home
      const TaskScreen(),  // Tasks
      const CaregiverCalendarScreen(), // Profile
    ];

    _navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'หน้าแรก',
      ),
      const NavigationDestination(
        icon: Icon(Icons.assignment_outlined),
        selectedIcon: Icon(Icons.assignment),
        label: 'รายการ',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'ประวัติ',
      ),
    ];
  }

  void _setupElderView() {
    _pages = [
      const ElderlyHomeScreen(),       // Home
      const ElderlyCalendarScreen(),   // History
      const Placeholder(),             // Care
      const Placeholder(),             // Profile
    ];

    _navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'หน้าแรก',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'ประวัติ',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'โปรไฟล์',
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
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: _navItems,
        ),
      ),
    );
  }
}
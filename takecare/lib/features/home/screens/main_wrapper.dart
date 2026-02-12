import 'package:flutter/material.dart';
import 'package:takecare/features/task/screens/task.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  List<Widget> _pages = [];
  List<NavigationDestination> _navItems = [];

  @override
  void initState() {
    super.initState();

    String role = "caregiver"; // Simulated user role

    if (role == 'caregiver') {
      _setupCaregiverView();
    } else {
      _setupElederView();
    }
  }

  void _setupCaregiverView() {
    _pages = [
      const Placeholder(), // Home
      const Task(), // Tasks
      const Placeholder(), // Profile
    ];

    _navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.check_circle_outline),
        selectedIcon: Icon(Icons.check_circle),
        label: 'Tasks',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  void _setupElederView() {
    _pages = [
      const Placeholder(), // Home
      const Placeholder(), // Profile
    ];

    _navItems = [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _navItems,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:takecare/features/automated_alarm/models/automated_alarm_model.dart';
import 'package:takecare/features/automated_alarm/screens/automated_alarm_screen.dart';
import 'package:takecare/constants/app_theme.dart';

void main() {
  runApp(const TestMedicationAlarmApp());
}

class TestMedicationAlarmApp extends StatelessWidget {
  const TestMedicationAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AutomatedAlarmScreen(
        alarm: const AutomatedAlarmScreen(
          id: 'test-1',
          medicationName: 'เทส Calcium & Vitamin D',
          scheduledTime: '8:00 AM',
          dosage: '1 tablet',
        ),
      ),
    );
  }
}

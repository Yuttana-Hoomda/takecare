import 'package:flutter/material.dart';
import 'package:takecare/features/medication_alarm_overlay/models/medication_alarm_model.dart';
import 'package:takecare/features/medication_alarm_overlay/screens/medication_alarm_screen.dart';
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
      home: MedicationAlarmScreen(
        alarm: const MedicationAlarmModel(
          id: 'test-1',
          medicationName: 'เทส Calcium & Vitamin D',
          scheduledTime: '8:00 AM',
          dosage: '1 tablet',
        ),
      ),
    );
  }
}

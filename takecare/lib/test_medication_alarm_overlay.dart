import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/medication_alarm_overlay/screens/medication_alarm_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MedicationAlarmScreen(),
    ),
  );
}

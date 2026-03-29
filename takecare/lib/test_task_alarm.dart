import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/food_alarm/screens/food_alarm_screen.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/task_submission/screens/task_alram_screen.dart';

void main(){
  runApp(TestTaskAlarmApp());
}

class TestTaskAlarmApp extends StatelessWidget {
  const TestTaskAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: TaskAlarmScreen(
          taskId: '0dYpj26kpoahXolfnZRt',
          icon: Icons.medical_services,
          time: '07.00',
          title: 'test',
          description: 'test',
          color: Colors.blueAccent,
        isRequiredCamera: true,
      )
    );
  }
}
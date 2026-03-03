import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/food_alarm/screens/food_alarm_screen.dart';
import 'package:takecare/constants/app_theme.dart';

void main(){
  runApp(TestFoodAlarmApp());
}

class TestFoodAlarmApp extends StatelessWidget {
  const TestFoodAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: FoodAlarmScreen(foodAlarmType: FoodAlarmType.breakfast),
    );
  }
}
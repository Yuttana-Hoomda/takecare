import 'dart:io';

import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/camera/camera_screen.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/food_alarm/screens/food_analysis_screen.dart';

import 'package:provider/provider.dart';
import '../providers/food_analysis_provider.dart';

class FoodAlarmData {
  final String time;
  final String title;
  final String description;

  const FoodAlarmData({
    required this.time,
    required this.title,
    required this.description,
  });
}

FoodAlarmData foodAlarmTypeData(FoodAlarmType foodAlarmType) {
  switch (foodAlarmType) {
    case FoodAlarmType.breakfast:
      return const FoodAlarmData(
        time: '07:00',
        title: 'มื้อเช้า',
        description:
            'ถึงเวลากินอาหารเช้าแล้ว!\nเริ่มต้นวันใหม่ด้วยมื้อเช้าที่ดี',
      );
    case FoodAlarmType.lunch:
      return const FoodAlarmData(
        time: '12:00',
        title: 'มื้อกลางวัน',
        description: 'ถึงเวลากินอาหารกลางวันแล้ว!\nอย่าลืมพักและรับประทานอาหาร',
      );
    case FoodAlarmType.dinner:
      return const FoodAlarmData(
        time: '18:00',
        title: 'มื้อเย็น',
        description: 'ถึงเวลากินอาหารเย็นแล้ว!\nจบวันด้วยมื้อเย็นที่อร่อย',
      );
  }
}

class FoodAlarmScreen extends StatelessWidget {
  const FoodAlarmScreen({super.key, required this.foodAlarmType});

  final FoodAlarmType foodAlarmType;

  @override
  Widget build(BuildContext context) {
    final data = foodAlarmTypeData(foodAlarmType);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _foodLogo(),
                    const SizedBox(height: 24),
                    Text(
                      data.time,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: _colorByFoodType(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorByFoodType(),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(
                              onSubmit: (imgBase64, imageFilePath) async {
                                final user = context.read<AuthProvider>().user;

                                await context.read<FoodAnalysisProvider>().analysisFood(
                                  imgBase64,
                                  imageFilePath,
                                  user!.diseases ?? [],
                                );

                                if (!context.mounted) return;

                                final provider = context.read<FoodAnalysisProvider>();
                                if (provider.result != null) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodAnalysisScreen(
                                        analysisResult: provider.result!,
                                        img: File(imageFilePath),
                                      ),
                                    ),
                                        (route) => false,
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera_rounded, size: 25),
                          SizedBox(width: 10),
                          Text(
                            'กินแล้ว (ถ่ายรูป)',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.black87,
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_alarm_rounded, size: 25),
                          SizedBox(width: 10),
                          Text(
                            'เลื่อนออกไป 15 นาที',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodLogo() {
    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _backgroundColorByFoodType(),
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: 56,
        color: _colorByFoodType(),
      ),
    );
  }

  Color _colorByFoodType() {
    switch (foodAlarmType) {
      case FoodAlarmType.breakfast:
        return const Color(0xFF2E7D32);
      case FoodAlarmType.lunch:
        return const Color(0xFFF9A825); // deep yellow/amber
      case FoodAlarmType.dinner:
        return const Color(0xFF1565C0); // deep blue
    }
  }

  Color _backgroundColorByFoodType() {
    switch (foodAlarmType) {
      case FoodAlarmType.breakfast:
        return const Color(0xFFA5D6A7); // light green
      case FoodAlarmType.lunch:
        return const Color(0xFFFFF9C4); // light yellow
      case FoodAlarmType.dinner:
        return const Color(0xFF90CAF9); // light blue
    }
  }
}

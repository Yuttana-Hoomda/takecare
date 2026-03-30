import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/models/user_model.dart';

import '../../task/models/task_model.dart';
import '../../task/services/task_service.dart';

class OnBoardingProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Diseases> diseases = [];
  bool isHealthy = false;

  TimeOfDay breakfastTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay lunchTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay dinnerTime = const TimeOfDay(hour: 18, minute: 0);

  MealSchedule get currentFoodTime {
    return MealSchedule(
      breakfast: breakfastTime,
      lunch: lunchTime,
      dinner: dinnerTime,
    );
  }

  void setBreakfastTime(TimeOfDay time) {
    breakfastTime = time;
    notifyListeners();
  }

  void setLunchTime(TimeOfDay time) {
    lunchTime = time;
    notifyListeners();
  }

  void setDinnerTime(TimeOfDay time) {
    dinnerTime = time;
    notifyListeners();
  }

  void setFoodTime(MealSchedule foodTime) {
    breakfastTime = foodTime.breakfast;
    lunchTime = foodTime.lunch;
    dinnerTime = foodTime.dinner;
    notifyListeners();
  }

  void toggleDisease(Diseases disease) {
    isHealthy = false;
    if (diseases.contains(disease)) {
      diseases.remove(disease);
    } else {
      diseases.add(disease);
    }
    notifyListeners();
  }

  Future<void> createFoodTime(
    MealSchedule foodTime,
    String userId,
    String familyId,
  ) async {
    try {
      final now = DateTime.now();
      await Future.wait([
        _taskService.createTask(
          Task(
            createdBy: userId,
            familyId: familyId,
            title: 'มื้อเช้า',
            type: 'foodTime',
            icon: 'assets/task.svg',
            repeatDays: const [0, 1, 2, 3, 4, 5, 6],
            time: foodTime.breakfast,
            createdAt: now,
          ),
        ),
        _taskService.createTask(
          Task(
            createdBy: userId,
            familyId: familyId,
            title: 'มื้อเที่ยง',
            type: 'foodTime',
            icon: 'assets/task.svg',
            repeatDays: const [0, 1, 2, 3, 4, 5, 6],
            time: foodTime.lunch,
            createdAt: now,
          ),
        ),
        _taskService.createTask(
          Task(
            createdBy: userId,
            familyId: familyId,
            title: 'มื้อเย็น',
            type: 'foodTime',
            icon: 'assets/task.svg',
            repeatDays: const [0, 1, 2, 3, 4, 5, 6],
            time: foodTime.dinner,
            createdAt: now,
          ),
        ),
      ]);

      notifyListeners();
    } catch (e) {
      debugPrint('Error creating food time: $e');
      rethrow;
    }
  }

  void clearDisease() {
    diseases.clear();
    isHealthy = true;
    notifyListeners();
  }
}

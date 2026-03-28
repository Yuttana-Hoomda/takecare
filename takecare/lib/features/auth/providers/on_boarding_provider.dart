import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/models/user_model.dart';

class OnBoardingProvider extends ChangeNotifier{
  List<Diseases> diseases = [];
  bool isHealthy = false;

  TimeOfDay breakfastTime = TimeOfDay(hour: 7, minute: 00);
  TimeOfDay lunchTime = TimeOfDay(hour: 12, minute: 00);
  TimeOfDay dinnerTime = TimeOfDay(hour: 18, minute: 00);

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
    foodTime = foodTime;
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

  void clearDisease() {
    diseases.clear();
    isHealthy = true;
    notifyListeners();
  }
}
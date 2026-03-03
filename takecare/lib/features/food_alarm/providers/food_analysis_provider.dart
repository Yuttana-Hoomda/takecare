import 'package:flutter/material.dart';
import 'package:takecare/features/food_alarm/models/food_analysis.dart';
import 'package:takecare/features/food_alarm/services/food_analysis_service.dart';

class FoodAnalysisProvider extends ChangeNotifier {
  final FoodAnalysisService _service = FoodAnalysisService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnalysisResult? _result;
  AnalysisResult? get result => _result;

  String? _error;
  String? get error => _error;

  String? _imagePath;
  String? get imagePath => _imagePath;

  Future<void> analysisFood(String imgBase64, String imagePath, String disease) async {
    try {
      _isLoading = true;
      _imagePath = imagePath;
      _error = null;
      notifyListeners();

      _result = await _service.analysisFood(imgBase64, disease);
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _result = null;
    _error = null;
    _imagePath = null;
    _isLoading = false;
    notifyListeners();
  }
}
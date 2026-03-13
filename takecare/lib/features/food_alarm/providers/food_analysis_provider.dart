import 'package:flutter/material.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/food_alarm/models/food_analysis.dart';
import 'package:takecare/features/food_alarm/services/food_analysis_service.dart';
import '../models/ai_analysis_result_model.dart';
import '../models/save_analysis_food_model.dart';

class FoodAnalysisProvider extends ChangeNotifier {
  final FoodAnalysisService _service = FoodAnalysisService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AiAnalysisResult? _result;
  AiAnalysisResult? get result => _result;

  FoodAnalysis? _foodAnalysis;
  FoodAnalysis? get foodAnalysis => _foodAnalysis;

  String? _error;
  String? get error => _error;

  String? _imagePath;
  String? get imagePath => _imagePath;

  String? _imageBase64;

  // ─── Analyze ───────────────────────────────────────────────────────────────
  Future<void> analysisFood(String imgBase64, String imagePath, List<Disease> disease) async {
    try {
      _isLoading = true;
      _imagePath = imagePath;
      _imageBase64 = imgBase64;
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

  // ─── Save — returns SaveAnalysisResponse directly to caller ───────────────
  Future<void> saveFoodAnalysis({
    required String elderlyId,
    required String familyId,
    required String displayTitle,
  }) async {
    if (_result == null || _imageBase64 == null) {
      _error = 'Please analyze food before saving';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _service.saveFoodAnalysis(
        SaveAnalysisFood(
          elderlyId: elderlyId,
          familyId: familyId,
          imageBase64: _imageBase64!,
          analysisResult: _result!,
          displayTitle: displayTitle,
        ),
      );

      return response; // caller can use foodId / eventId if needed
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Get by Firestore doc ID ───────────────────────────────────────────────
  Future<void> getFoodAnalysisById(String foodId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _foodAnalysis = await _service.getFoodAnalysisById(foodId);
    } catch (err) {
      _error = err.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    _result = null;
    _foodAnalysis = null;
    _error = null;
    _imagePath = null;
    _imageBase64 = null;
    _isLoading = false;
    notifyListeners();
  }
}
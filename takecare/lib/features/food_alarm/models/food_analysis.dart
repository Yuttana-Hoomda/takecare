import 'package:flutter/material.dart';

class FoodAnalysis {
  final String foodAnalysisId;
  final String elderId;
  final String familyId;
  final String imageUrl;
  final String foodName;
  final String healthLevel;
  final String description;
  final double sugar;
  final double sodium;
  final double fat;
  final double calories;
  final TimeOfDay time;
  final DateTime createAt;

  const FoodAnalysis({
    required this.foodAnalysisId,
    required this.elderId,
    required this.familyId,
    required this.imageUrl,
    required this.foodName,
    required this.healthLevel,
    required this.description,
    required this.sugar,
    required this.sodium,
    required this.fat,
    required this.calories, required this.time, required this.createAt});
}

class AnalysisResult {
  final String foodName;
  final String healthLevel;
  final double sugar;
  final double sodium;
  final double fat;
  final double calories;
  final String analysisResult;

  const AnalysisResult({
    required this.foodName,
    required this.healthLevel,
    required this.sugar,
    required this.sodium,
    required this.fat,
    required this.calories,
    required this.analysisResult
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      foodName: json['foodName'] ?? '',
      healthLevel: json['healthLevel'] ?? '',
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      analysisResult: json['analysisResult'] ?? '',
    );
  }
}
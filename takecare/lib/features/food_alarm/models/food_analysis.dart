import 'package:flutter/material.dart';

class FoodAnalysis {
  final String elderId;
  final String familyId;
  final String imageUrl;
  final String healthLevel;
  final double sugar;
  final double sodium;
  final String analysisResult;

  const FoodAnalysis({
    required this.elderId,
    required this.familyId,
    required this.imageUrl,
    required this.healthLevel,
    required this.sugar,
    required this.sodium,
    required this.analysisResult
  });

  factory FoodAnalysis.fromJson(Map<String, dynamic> json) {
    return FoodAnalysis(
        elderId: json['elderId'],
        familyId: json['familyId'],
        imageUrl: json['imageUrl'],
        healthLevel: json['healthLevel'],
        sugar: json['sugar'],
        sodium: json['sodium'],
        analysisResult: json['analysisResult']);
  }
}
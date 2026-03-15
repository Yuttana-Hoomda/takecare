import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:takecare/features/food_alarm/models/food_analysis.dart';
import 'package:http/http.dart' as http;

class FoodAnalysisService {
  final String url = "http://10.0.2.2:3000/api";
  Future<AnalysisResult> analysisFood(String imgBase64, String disease) async {
    try{
      final response = await http.post(
          Uri.parse('$url/food-analysis/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'img': imgBase64,
          'disease': disease
        }),
      );

      if(response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint(jsonData.toString());
        return AnalysisResult.fromJson(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    }catch(err) {
      throw Exception('Failed to analyze food: $err');
    }
  }
}
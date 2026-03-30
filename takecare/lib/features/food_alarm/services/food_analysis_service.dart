import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:takecare/constants/enum.dart';

import '../models/ai_analysis_result_model.dart';
import '../models/food_analysis.dart';
import '../models/save_analysis_food_model.dart';

class FoodAnalysisService {
  //final String url = "https://takecare-taupe.vercel.app//api";
  final String url = Platform.isAndroid
      ? "https://takecare-taupe.vercel.app/api"
      : "https://takecare-taupe.vercel.app/api";

  Future<AiAnalysisResult> analysisFood(String imgBase64, List<Diseases> disease) async {
    try{
      final response = await http.post(
          Uri.parse('$url/food-analysis/analyze'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'img': imgBase64,
          'disease': disease.map((d) => d.name).toList(),
        }),
      );

      if(response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint(jsonData.toString());
        return AiAnalysisResult.fromJson(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    }catch(err) {
      throw Exception('Failed to analyze food: $err');
    }
  }

  Future<Map<String, dynamic>> saveFoodAnalysis(SaveAnalysisFood request) async {
    try {
      final response = await http.post(
        Uri.parse('$url/food-analysis/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint(jsonData.toString());
        return jsonData;
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (err) {
      throw Exception('Failed to save food analysis: $err');
    }
  }

  Future<FoodAnalysis> getFoodAnalysisById(String foodId) async {
    try {
      final response = await http.get(
        Uri.parse('$url/food-analysis/$foodId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        debugPrint(jsonData.toString());
        return FoodAnalysis.fromJson(jsonData);
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (err) {
      throw Exception('Failed to get food analysis: $err');
    }
  }
}
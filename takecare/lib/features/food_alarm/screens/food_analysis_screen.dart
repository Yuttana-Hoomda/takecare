import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:takecare/features/food_alarm/models/food_analysis.dart';

class FoodAnalysisScreen extends StatelessWidget {
  const FoodAnalysisScreen({
    super.key,
    required this.analysisResult,
    required this.img
  });

  final AnalysisResult analysisResult;
  final File img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('วิเคราะห์อาหาร'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Image.file(img),
          Text(analysisResult.analysisResult)
        ],
      ),
    );
  }
}

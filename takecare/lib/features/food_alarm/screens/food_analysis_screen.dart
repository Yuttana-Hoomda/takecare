import 'dart:io';

import 'package:flutter/material.dart';
import 'package:takecare/features/food_alarm/models/food_analysis.dart';

class FoodAnalysisScreen extends StatelessWidget {
  const FoodAnalysisScreen({
    super.key,
    required this.analysisResult,
    required this.img,
  });

  final AnalysisResult analysisResult;
  final File img;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('วิเคราะห์อาหาร'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(24),
                    child: Image.file(
                      img,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _healthLevelBuild(analysisResult.healthLevel ,context),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      analysisResult.analysisResult,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _nutrientInfo(
                          'น้ำตาล (กรัม)',
                          analysisResult.sugar,
                          Icons.cookie_outlined,
                          'sugar',
                          'Hypertension',
                          context,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _nutrientInfo(
                          'โซเดี่ยม (มิลลิกรัม)',
                          analysisResult.sodium,
                          Icons.cookie_outlined,
                          'sodium',
                          'Hypertension',
                          context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.black45),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Ai อาจจะแสดงข้อมูลผิดพลาดได้',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                      'แชร์ให้ครอบครัว',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontSize: 20
                    ),
                  )
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _nutrientInfo(
      String label,
      double value,
      IconData icon,
      String nutrientType,
      String? disease,
      BuildContext context,
      ) {
    final thresholds = {
      'none': {
        'sugar':  (moderate: 8.0,   unhealthy: 17.0),
        'sodium': (moderate: 667.0, unhealthy: 1067.0),
      },
      'diabetes': {
        'sugar':  (moderate: 5.0,   unhealthy: 10.0),
        'sodium': (moderate: 667.0, unhealthy: 1067.0),
      },
      'Hypertension': {
        'sugar':  (moderate: 8.0,   unhealthy: 17.0),
        'sodium': (moderate: 500.0, unhealthy: 800.0),
      },
    };

    final key = disease ?? 'none';
    final threshold = thresholds[key]?[nutrientType] ?? (moderate: double.infinity, unhealthy: double.infinity);
    final maxValue = threshold.moderate;

    final Color levelColor;
    if (value <= threshold.moderate) {
      levelColor = Colors.green;
    } else if (value <= threshold.unhealthy) {
      levelColor = Colors.orange;
    } else {
      levelColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '/$maxValue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthLevelBuild(String healthLevel, BuildContext context) {
    final Map<String, (Color, String)> config = {
      'healthy':   (Colors.green,  'ดีต่อสุขภาพ'),
      'moderate':  (Colors.orange, 'ปานกลาง'),
      'unhealthy': (Colors.red,    'ไม่ดีต่อสุขภาพ'),
    };

    final (color, label) = config[healthLevel] ?? (Colors.grey, 'ไม่ทราบ');

    return Text(
      label,
      style: Theme.of(context).textTheme.displaySmall!.copyWith(
        color: color,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:takecare/features/food_analysis/screens/camera_scan_food.dart';

class TestCameraScreen extends StatelessWidget {
  const TestCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraScanFood())
            );
          },
          label: Icon(Icons.photo_camera_rounded)
      )
    );
  }
}

import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontFamily: 'GoogleSans')),
      ),
      body: const Center(
        child: Text("หน้าตั้งค่าสำหรับแอป"),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../components/setting_button.dart';
import '/constants/app_theme.dart';

Widget buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const CircleAvatar(
        radius: 25,
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.person, color: Colors.white),
      ),
      const SettingButton(),
    ],
  );
}

import 'package:flutter/material.dart';
import '/constants/app_theme.dart';
import 'package:takecare/features/home/screens/setting_screen.dart';

class SettingButton extends StatelessWidget {
  const SettingButton({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: IconButton(
        icon: Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingScreen()),
          );
        },
      ),
    );
  }
}

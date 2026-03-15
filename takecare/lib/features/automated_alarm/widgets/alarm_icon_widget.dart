import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

class AlarmIconWidget extends StatelessWidget {
  const AlarmIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.notifications_active_rounded, size: 64, color: AppTheme.primaryColor),
      ),
    );
  }
}

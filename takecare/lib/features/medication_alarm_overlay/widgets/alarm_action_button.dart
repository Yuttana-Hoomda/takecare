// lib/features/medication_alarm_overlay/widgets/alarm_action_button.dart

import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

enum AlarmButtonType { primary, secondary }

class AlarmActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed; // nullable = disabled
  final AlarmButtonType type;
  final bool isLoading;

  const AlarmActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.type = AlarmButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == AlarmButtonType.primary;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? AppTheme.primaryColor
              : const Color(0xFFE8EDF2),
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF4A5568),
          disabledBackgroundColor: isPrimary
              ? AppTheme.primaryColor.withOpacity(0.6)
              : const Color(0xFFE8EDF2),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}

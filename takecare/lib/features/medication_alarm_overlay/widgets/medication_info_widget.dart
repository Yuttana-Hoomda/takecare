// lib/features/medication_alarm_overlay/widgets/medication_info_widget.dart

import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import '../models/medication_alarm_model.dart';

class MedicationInfoWidget extends StatelessWidget {
  final MedicationAlarmModel alarm;

  const MedicationInfoWidget({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Title
        Text(
          'Time for your\nMedication',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A1628),
            height: 1.3,
          ),
        ),

        const SizedBox(height: 12),

        // Subtitle: Time · Medication Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_alarm_rounded,
              size: 16,
              color: AppTheme.subtitle,
            ),
            const SizedBox(width: 4),
            Text(
              '${alarm.scheduledTime} · ${alarm.medicationName}',
              style: textTheme.titleSmall?.copyWith(
                color: AppTheme.subtitle,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

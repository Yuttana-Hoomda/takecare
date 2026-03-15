import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import '../models/automated_alarm_model.dart';

class AlarmInfoWidget extends StatelessWidget {
  final AutomatedAlarmModel alarm;

  const AlarmInfoWidget({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          'ถึงเวลาทำรายการ',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0A1628),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_alarm_rounded, size: 16, color: AppTheme.subtitle),
            const SizedBox(width: 4),
            Text(
              '${alarm.scheduledTime} · ${alarm.title}',
              style: textTheme.titleSmall?.copyWith(color: AppTheme.subtitle, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

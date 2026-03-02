
import 'package:flutter/material.dart';

class CalendarWeekdayLabels extends StatelessWidget {
  static const _dayHeaders = ['อา.', 'จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.'];
  const CalendarWeekdayLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _dayHeaders.map((d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
            ),
          ),
        )).toList(),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../elderly_history/components/nav_button.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  static const _monthNames = [
    '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];

  const CalendarHeader({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          NavButton(
            icon: Icons.chevron_left,
            onTap: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month - 1, 1)),
          ),
          Column(
            children: [
              Text(
                _monthNames[selectedDate.month],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary),
              ),
              Text(
                '${selectedDate.year + 543}',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          NavButton(
            icon: Icons.chevron_right,
            onTap: () => onDateSelected(DateTime(selectedDate.year, selectedDate.month + 1, 1)),
          ),
        ],
      ),
    );
  }
}
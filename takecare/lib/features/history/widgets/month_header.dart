import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onCalendarTap;

  const MonthHeader({
    super.key,
    required this.selectedDate,
    required this.onCalendarTap,
  });

  static const _thaiMonths = [
    '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
    'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
    'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];

  @override
  Widget build(BuildContext context) {
    final buddhistYear = selectedDate.year + 543;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_thaiMonths[selectedDate.month]} $buddhistYear',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          GestureDetector(
            onTap: onCalendarTap,
            child: Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
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
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_thaiMonths[selectedDate.month]} $buddhistYear',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: onCalendarTap,
          ),
        ],
      ),
    );
  }
}
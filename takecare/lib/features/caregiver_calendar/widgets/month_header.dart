import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  final DateTime selectedDate;
  const MonthHeader({super.key, required this.selectedDate});

  static const _months = [
    '',
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_months[selectedDate.month]} ${selectedDate.year + 543}',
            style: Theme.of(context).textTheme?.titleLarge,
          ),
          Icon(
            Icons.calendar_today_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

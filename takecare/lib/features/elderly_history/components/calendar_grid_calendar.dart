
import 'package:flutter/material.dart';
import 'package:takecare/features/elderly_history/models/event_task.dart';
import 'day_status_dot.dart';


class CalendarGrid extends StatelessWidget {
  final DateTime selectedDate;
  final int firstDay;
  final int daysInMonth;
  final Map<String, DayData> eventData;
  final Function(DateTime) onDateSelected;

  const CalendarGrid({
    super.key,
    required this.selectedDate,
    required this.firstDay,
    required this.daysInMonth,
    required this.eventData,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: firstDay + daysInMonth,
        itemBuilder: (context, index) {
          if (index < firstDay) return const SizedBox();
          final day = index - firstDay + 1;
          final date = DateTime(selectedDate.year, selectedDate.month, day);
          final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return DayStatusDot(
            day: day,
            status: eventData[key]?.status,
            isSelected: isSelected,
            onTap: () => onDateSelected(date),
          );
        },
      ),
    );
  }
}
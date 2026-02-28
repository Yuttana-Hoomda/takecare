import 'package:flutter/material.dart';
import '../models/event_task.dart';
import 'day_status_dot.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Map<String, DayData> eventData;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.eventData,
    required this.onDateSelected,
  });

  static const _dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDay =
        DateTime(selectedDate.year, selectedDate.month, 1).weekday % 7;

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                onTap: () => onDateSelected(
                  DateTime(selectedDate.year, selectedDate.month - 1, 1),
                ),
              ),
              Column(
                children: [
                  Text(
                    _monthNames[selectedDate.month],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                  Text(
                    '${selectedDate.year}',
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              _NavButton(
                icon: Icons.chevron_right,
                onTap: () => onDateSelected(
                  DateTime(selectedDate.year, selectedDate.month + 1, 1),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _dayHeaders
                .map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),

        Padding(
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
              final date =
              DateTime(selectedDate.year, selectedDate.month, day);
              final key =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final data = eventData[key];
              final isSelected = date.day == selectedDate.day &&
                  date.month == selectedDate.month &&
                  date.year == selectedDate.year;

              return DayStatusDot(
                day: day,
                status: data?.status,
                isSelected: isSelected,
                onTap: () => onDateSelected(date),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: cs.primary, size: 22),
      ),
    );
  }
}
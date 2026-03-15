import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/history/models/event_calendar_model.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import '/constants/app_theme.dart';

class MonthGrid extends StatefulWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<MonthGrid> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HistoryProvider>(context, listen: false)
          .loadMonth(month: widget.month.month, year: widget.month.year);
    });
  }

  Color _dotColor(DayStatus status) {
    switch (status) {
      case DayStatus.complete:
        return const Color(0xFF4DB887);
      case DayStatus.partial:
        return const Color(0xFFFFAA55);
      case DayStatus.missed:
        return const Color(0xFFFF7F7F);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final firstDay = DateTime(widget.month.year, widget.month.month, 1);
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final daysInMonth =
        DateTime(widget.month.year, widget.month.month + 1, 0).day;
    final today = DateTime.now();

    final thaiMonths = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    final buddhistYear = widget.month.year + 543;

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          '${thaiMonths[widget.month.month]}, $buddhistYear พ.ศ.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'].map((d) {
            return Expanded(
              child: Center(
                child: Text(d,
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) return const SizedBox();

            final day = index - startWeekday + 1;
            final date =
            DateTime(widget.month.year, widget.month.month, day);
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isSelected = widget.selectedDate != null &&
                date.year == widget.selectedDate!.year &&
                date.month == widget.selectedDate!.month &&
                date.day == widget.selectedDate!.day;
            final isFuture = date.isAfter(today);
            final status = provider.getStatusForDate(date);

            return GestureDetector(
              onTap: () => widget.onDateSelected(date),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      border: isToday && !isSelected
                          ? Border.all(
                          color: AppTheme.primaryColor, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday || isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : isFuture
                              ? Colors.grey.withOpacity(0.4)
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (status != null && !isFuture)
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _dotColor(status),
                      ),
                    )
                  else
                    const SizedBox(height: 6),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/history/models/event_calendar_model.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import '/constants/app_theme.dart';

class MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;

  const MonthGrid({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
  });

  Color _dotColor(DayStatus status) {
    switch (status) {
      case DayStatus.complete:
        return AppTheme.success;
      case DayStatus.partial:
        return AppTheme.warning;
      case DayStatus.missed:
        return AppTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final firstDay = DateTime(month.year, month.month, 1);
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();

    final thaiMonths = [
      '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน',
      'พฤษภาคม', 'มิถุนายน', 'กรกฎาคม', 'สิงหาคม',
      'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
    ];
    final buddhistYear = month.year + 543;

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          '${thaiMonths[month.month]}, พ.ศ. $buddhistYear',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'].map((d) {
            return Expanded(
              child: Center(
                child: Text(d, style: Theme.of(context).textTheme.bodySmall),
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
            childAspectRatio: 0.8,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (context, index) {
            if (index < startWeekday) return const SizedBox();
            final day = index - startWeekday + 1;
            final date = DateTime(month.year, month.month, day);
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;
            final isSelected = selectedDate != null &&
                date.year == selectedDate!.year &&
                date.month == selectedDate!.month &&
                date.day == selectedDate!.day;
            final isFuture = date.isAfter(today);
            final status = provider.getStatusForDate(date);
            final hasStatus = status != null && !isFuture;
            final Color activeColor = hasStatus ? _dotColor(status) : AppTheme.primaryColor;

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // สีพื้นหลัง: ถ้ามีสถานะหรือถูกเลือก ให้เป็นสีอ่อนๆ
                      color: hasStatus || isSelected
                          ? activeColor.withOpacity(isSelected ? 0.3 : 0.1)
                          : Colors.transparent,
                      // เส้นขอบ: ถูกเลือก = หนา, มีสถานะ = ปกติ, วันนี้ = สีจางๆ
                      border: isSelected
                          ? Border.all(color: activeColor, width: 3.0)
                          : (hasStatus
                          ? Border.all(color: activeColor, width: 1.5)
                          : (isToday
                          ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 1.5)
                          : null)),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 18,
                          color: isFuture
                              ? Colors.grey.withOpacity(0.4)
                              : (isSelected || hasStatus ? Colors.black87 : (isToday ? AppTheme.primaryColor : Colors.black87)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
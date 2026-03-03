
import 'package:flutter/material.dart';
import '../models/event_task.dart';
import 'calendar_grid_calendar.dart';
import '../../elderly_home/components/calendarHeader_calendar.dart';
import 'calendarWeekdayLabels_calendar.dart';
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

  @override
  Widget build(BuildContext context) {
    // Logic คำนวณวันที่
    final daysInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1).weekday % 7;

    return Column(
      children: [
        // ส่วนหัว: เดือนและปี พ.ศ. พร้อมปุ่มเลื่อน
        CalendarHeader(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        ),
        const CalendarWeekdayLabels(),
        const SizedBox(height: 8),
        CalendarGrid(
          selectedDate: selectedDate,
          firstDay: firstDay,
          daysInMonth: daysInMonth,
          eventData: eventData,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
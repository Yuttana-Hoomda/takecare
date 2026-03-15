import 'package:flutter/material.dart';

class WeekDatePicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const WeekDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<WeekDatePicker> createState() => _WeekDatePickerState();
}

class _WeekDatePickerState extends State<WeekDatePicker> {
  late PageController _pageController;

  // index 500 = สัปดาห์ปัจจุบัน
  static const int _initialIndex = 500;

  DateTime _startOfWeek(DateTime date) {
    // จันทร์เป็นวันแรก
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _weekAtIndex(int index) {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);
    final diff = index - _initialIndex;
    return currentWeekStart.add(Duration(days: diff * 7));
  }

  int _indexOfDate(DateTime date) {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);
    final targetWeekStart = _startOfWeek(date);
    final diff = targetWeekStart.difference(currentWeekStart).inDays ~/ 7;
    return _initialIndex + diff;
  }

  @override
  void initState() {
    super.initState();
    final initialPage = _indexOfDate(widget.selectedDate);
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void didUpdateWidget(WeekDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ถ้า selectedDate เปลี่ยนจากภายนอก (จาก InfiniteCalendar) ให้ jump ไปสัปดาห์นั้น
    if (oldWidget.selectedDate != widget.selectedDate) {
      final targetPage = _indexOfDate(widget.selectedDate);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const dayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

    return SizedBox(
      height: 80,
      child: PageView.builder(
        controller: _pageController,
        itemBuilder: (context, index) {
          final weekStart = _weekAtIndex(index);
          final dates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

          return Row(
            children: dates.asMap().entries.map((e) {
              final i = e.key;
              final date = e.value;
              final isSelected = date.year == widget.selectedDate.year &&
                  date.month == widget.selectedDate.month &&
                  date.day == widget.selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onDateSelected(date),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected
                          ? Border.all(color: cs.primary, width: 1.5)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? cs.onPrimary : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
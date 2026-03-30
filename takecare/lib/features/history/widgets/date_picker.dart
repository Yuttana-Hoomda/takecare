import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/history/models/event_calendar_model.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import '/constants/app_theme.dart';

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
  static const int _initialIndex = 500;

  DateTime _startOfWeek(DateTime date) {
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
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: _indexOfDate(widget.selectedDate));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMonthForIndex(_pageController.initialPage);
    });
  }

  void _loadMonthForIndex(int index) {
    if (!mounted) return;
    final familyId = Provider.of<AuthProvider>(context, listen: false).user?.familyId;
    if (familyId == null || familyId.isEmpty) return;

    final provider = Provider.of<HistoryProvider>(context, listen: false);
    final weekStart = _weekAtIndex(index);
    
    provider.loadMonth(month: weekStart.month, year: weekStart.year, familyId: familyId);
    
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekEnd.month != weekStart.month) {
      provider.loadMonth(month: weekEnd.month, year: weekEnd.year, familyId: familyId);
    }
  }

  @override
  void didUpdateWidget(WeekDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    final provider = context.watch<HistoryProvider>();
    final dayLabels = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];

    return SizedBox(
      height: 120, // ✅ เพิ่มความสูงจาก 105 เป็น 120
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _loadMonthForIndex,
        itemBuilder: (context, index) {
          final weekStart = _weekAtIndex(index);
          final dates =
              List.generate(7, (i) => weekStart.add(Duration(days: i)));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0), // ลด padding เพื่อให้ตัวเลขที่ใหญ่ขึ้นไม่เบียดกัน
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: dates.asMap().entries.map((e) {
                final i = e.key;
                final date = e.value;
                final isSelected =
                    DateUtils.isSameDay(date, widget.selectedDate);
                final isToday = DateUtils.isSameDay(date, DateTime.now());
                final isFuture = date.isAfter(DateTime.now());
                final status = provider.getStatusForDate(date);

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDateSelected(date),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 16, // ✅ เพิ่มจาก 12 เป็น 16
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48, // ✅ เพิ่มความกว้างเล็กน้อย
                          height: 75, // ✅ เพิ่มความสูงเล็กน้อย
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isToday && !isSelected
                                ? Border.all(
                                    color: AppTheme.primaryColor, width: 2) // หนาขึ้น
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppTheme.primaryColor.withOpacity(0.3)
                                    : Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 24, // ✅ เพิ่มจาก 18 เป็น 24
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (!isFuture)
                                Container(
                                  width: 8, // ✅ ใหญ่ขึ้นเล็กน้อย
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: status != null 
                                        ? _dotColor(status) 
                                        : (isSelected ? Colors.white.withOpacity(0.4) : Colors.grey[300]),
                                  ),
                                )
                              else
                                const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

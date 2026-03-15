import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/history/models/event_calendar_model.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import '/constants/app_theme.dart';

class YearView extends StatefulWidget {
  final int year;
  final void Function(DateTime) onMonthSelected;

  const YearView({
    super.key,
    required this.year,
    required this.onMonthSelected,
  });

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  @override
  void initState() {
    super.initState();
    // โหลดทุกเดือนในปีนี้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
      Provider.of<HistoryProvider>(context, listen: false);
      for (int m = 1; m <= 12; m++) {
        provider.loadMonth(month: m, year: widget.year);
      }
    });
  }

  DayStatus? _monthSummary(HistoryProvider provider, int month) {
    int complete = 0, partial = 0, missed = 0;
    final daysInMonth =
        DateTime(widget.year, month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      final status = provider.getStatusForDate(
          DateTime(widget.year, month, d));
      if (status == null) continue;
      if (status == DayStatus.complete) complete++;
      if (status == DayStatus.partial) partial++;
      if (status == DayStatus.missed) missed++;
    }
    if (complete == 0 && partial == 0 && missed == 0) return null;
    if (complete >= partial && complete >= missed) return DayStatus.complete;
    if (partial >= missed) return DayStatus.partial;
    return DayStatus.missed;
  }

  Color _statusColor(DayStatus status) {
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
    final thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.',
      'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.',
      'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    final buddhistYear = widget.year + 543;
    final today = DateTime.now();

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          '$buddhistYear พ.ศ.',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 12,
          itemBuilder: (context, i) {
            final month = i + 1;
            final isCurrentMonth =
                today.year == widget.year && today.month == month;
            final summary = _monthSummary(provider, month);

            return GestureDetector(
              onTap: () =>
                  widget.onMonthSelected(DateTime(widget.year, month)),
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrentMonth
                      ? AppTheme.primaryColor.withOpacity(0.08)
                      : const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentMonth
                      ? Border.all(
                      color: AppTheme.primaryColor, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      thaiMonths[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrentMonth
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: isCurrentMonth
                            ? AppTheme.primaryColor
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (summary != null)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor(summary),
                        ),
                      )
                    else
                      const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
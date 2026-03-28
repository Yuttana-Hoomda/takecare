import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import '/constants/app_theme.dart';
import 'month_grid.dart';
import 'year_view.dart';

enum _CalendarMode { month, year }

class InfiniteCalendarScreen extends StatefulWidget {
  const InfiniteCalendarScreen({super.key});

  @override
  State<InfiniteCalendarScreen> createState() =>
      _InfiniteCalendarScreenState();
}

class _InfiniteCalendarScreenState extends State<InfiniteCalendarScreen> {
  _CalendarMode _mode = _CalendarMode.month;

  static const int _initialIndex = 500;
  late final PageController _monthPageController;
  late final PageController _yearPageController;

  final DateTime _baseMonth =
  DateTime(DateTime.now().year, DateTime.now().month);
  final int _baseYear = DateTime.now().year;

  DateTime _monthAtIndex(int index) {
    final diff = index - _initialIndex;
    final totalMonths =
        _baseMonth.year * 12 + (_baseMonth.month - 1) + diff;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    return DateTime(year, month);
  }

  int _yearAtIndex(int index) => _baseYear + (index - _initialIndex);

  void _switchToMonth(DateTime month) {
    final totalMonths = month.year * 12 + (month.month - 1);
    final baseMonths = _baseMonth.year * 12 + (_baseMonth.month - 1);
    final targetIndex = _initialIndex + (totalMonths - baseMonths);
    setState(() => _mode = _CalendarMode.month);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _monthPageController.jumpToPage(targetIndex);
    });
  }

  @override
  void initState() {
    super.initState();
    _monthPageController = PageController(initialPage: _initialIndex);
    _yearPageController = PageController(initialPage: _initialIndex);
    
    // โหลดเดือนปัจจุบันทันทีที่เปิดหน้าจอ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdjacentMonths(_initialIndex);
    });
  }

  void _loadAdjacentMonths(int index) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final familyId = user?.familyId ?? '';
    if (familyId.isEmpty) return;

    final provider = Provider.of<HistoryProvider>(context, listen: false);
    
    // โหลดเดือนปัจจุบัน
    final current = _monthAtIndex(index);
    provider.loadMonth(month: current.month, year: current.year, familyId: familyId);
    
    // โหลดเดือนก่อนหน้าและถัดไป (Preload)
    final next = _monthAtIndex(index + 1);
    final prev = _monthAtIndex(index - 1);
    provider.loadMonth(month: next.month, year: next.year, familyId: familyId);
    provider.loadMonth(month: prev.month, year: prev.year, familyId: familyId);
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    _yearPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('เลือกวันที่',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: _ModeToggle(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
          ),
          Expanded(
            child: _mode == _CalendarMode.month
                ? PageView.builder(
              controller: _monthPageController,
              scrollDirection: Axis.vertical,
              onPageChanged: _loadAdjacentMonths,
              itemBuilder: (context, index) {
                final month = _monthAtIndex(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: MonthGrid(
                    month: month,
                    selectedDate: null,
                    onDateSelected: (date) =>
                        Navigator.pop(context, date),
                  ),
                );
              },
            )
                : PageView.builder(
              controller: _yearPageController,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                final year = _yearAtIndex(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: YearView(
                    year: year,
                    onMonthSelected: _switchToMonth,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _CalendarMode mode;
  final void Function(_CalendarMode) onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // เพิ่มความสูงให้ดูไม่อึดอัด
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ToggleBtn(
              label: 'เดือน',
              isActive: mode == _CalendarMode.month,
              onTap: () => onChanged(_CalendarMode.month)),
          _ToggleBtn(
              label: 'ปี',
              isActive: mode == _CalendarMode.year,
              onTap: () => onChanged(_CalendarMode.year)),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleBtn(
      {required this.label,
        required this.isActive,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight:
                isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
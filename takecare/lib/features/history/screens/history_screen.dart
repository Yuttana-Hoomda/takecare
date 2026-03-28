import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import 'package:takecare/features/history/widgets/month_header.dart';
import 'package:takecare/features/history/widgets/date_picker.dart';
import 'package:takecare/features/history/widgets/infinite_calendar_screen.dart';
import 'package:takecare/features/history/widgets/event_tile.dart';
import '/constants/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  final DateTime? initialDate;
  const HistoryScreen({super.key, this.initialDate});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDay(_selectedDate);
      _loadMonth(_selectedDate);
    });
  }

  void _loadMonth(DateTime date, {bool force = false}) {
    final familyId =
        Provider.of<AuthProvider>(context, listen: false).user?.familyId;
    if (familyId == null || familyId.isEmpty) return;
    Provider.of<HistoryProvider>(context, listen: false)
        .loadMonth(
          month: date.month, 
          year: date.year, 
          familyId: familyId,
          force: force,
        );
  }

  void _loadDay(DateTime date, {bool force = false}) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final familyId =
        Provider.of<AuthProvider>(context, listen: false).user?.familyId;
    if (familyId == null || familyId.isEmpty) return;
    Provider.of<HistoryProvider>(context, listen: false).loadDay(dateStr, familyId, force: force);
  }

  Future<void> _onRefresh() async {
    _loadDay(_selectedDate, force: true);
    _loadMonth(_selectedDate, force: true);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _openCalendar() async {
    final result = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => const InfiniteCalendarScreen(),
      ),
    );
    if (result != null) {
      setState(() => _selectedDate = result);
      _loadDay(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final events = provider.dayEvents;
    return Scaffold(
      backgroundColor: AppTheme.bgColorLight,
      appBar: AppBar(
        title: const Text(
          'ประวัติกิจกรรม',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          edgeOffset: 120,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: AppTheme.bgColorLight, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MonthHeader(
                        selectedDate: _selectedDate,
                        onCalendarTap: _openCalendar,
                      ),
                      WeekDatePicker(
                        selectedDate: _selectedDate,
                        onDateSelected: (date) {
                          setState(() => _selectedDate = date);
                          _loadDay(date);
                          _loadMonth(date); 
                        },
                      ),
                      const SizedBox(height: 10),
                      Text("Timeline")
                    ],
                  ),
                ),
              ),
              if (provider.isDayLoading && events.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.errorMessage != null)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: provider.errorMessage!,
                    onRetry: () => _loadDay(_selectedDate, force: true),
                  ),
                )
              else if (events.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => EventTile(
                          event: events[index],
                          isLast: index == events.length - 1,
                        ),
                        childCount: events.length,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Center(
            child: Text(
              'ไม่มีรายการในวันนี้',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/history/providers/history_provider.dart';
import 'package:takecare/features/history/widgets/month_header.dart';
import 'package:takecare/features/history/widgets/date_picker.dart';
import 'package:takecare/features/history/widgets/infinite_calendar_screen.dart';
import 'package:takecare/features/history/widgets/event_tile.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDay(_selectedDate));
  }

  void _loadDay(DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final familyId =
        Provider.of<AuthProvider>(context, listen: false).user?.familyId ?? '';
    Provider.of<HistoryProvider>(context, listen: false).loadDay(dateStr, familyId);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            if (provider.isDayLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null)
              SliverFillRemaining(
                child: _ErrorView(
                  message: provider.errorMessage!,
                  onRetry: () => _loadDay(_selectedDate),
                ),
              )
            else if (events.isEmpty)
                const SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'ไม่มีรายการในวันนี้',
        style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
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
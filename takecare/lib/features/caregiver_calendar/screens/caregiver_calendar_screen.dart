import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/elderly_history/provider/history_provider.dart';
import '../widgets/month_header.dart';
import '../widgets/date_picker.dart';
import '../widgets/schedule_tile.dart';
import 'package:takecare/features/caregiver_home/widgets/caregiver_header.dart';
import 'package:takecare/features/caregiver_calendar/mock/mock_task.dart';

const bool _useMock = true;

class CaregiverCalendarScreen extends StatefulWidget {
  const CaregiverCalendarScreen({super.key});

  @override
  State<CaregiverCalendarScreen> createState() =>
      _CaregiverCalendarScreenState();
}

class _CaregiverCalendarScreenState extends State<CaregiverCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  void _fetchData() {
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_useMock) {
      historyProvider.loadMockData(MockEventData.data);
    } else {
      final familyId = authProvider.user?.familyId;
      if (familyId != null) {
        historyProvider.getEvents(familyId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final dayData = history.getDataForDate(_selectedDate);
    final tasks = dayData?.tasks ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              elevation: 0,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              toolbarHeight: 90,
              titleSpacing: 20,
              title: const CaregiverHeader(
                name: 'Mom',
                avatarUrl:
                    'https://hilight.thaicdn.net/img_cms2/user/thachapol/tah/ee1226.jpg',
                isOnline: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthHeader(selectedDate: _selectedDate),
                  WeekDatePicker(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            tasks.isEmpty
                ? const SliverFillRemaining(child: _EmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return ScheduleTile(
                          eventTask: tasks[index],
                          isLast: index == tasks.length - 1,
                        );
                      }, childCount: tasks.length),
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
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          Text(message, style: TextStyle(color: cs.onSurfaceVariant)),
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

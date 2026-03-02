import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import '../provider/history_provider.dart';
import '../widgets/calendar_widget.dart';
import '../components/summary_section.dart';
import '../mock_data/mockTask.dart';

class ElderlyCalendarScreen extends StatefulWidget {
  const ElderlyCalendarScreen({super.key});

  @override
  State<ElderlyCalendarScreen> createState() => _ElderlyCalendarScreenState();
}

class _ElderlyCalendarScreenState extends State<ElderlyCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  bool get _useMock => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchData());
  }

  void _fetchData() {
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_useMock) {
      historyProvider.loadMockData(mockEventData);
    } else {
      final familyId = authProvider.user?.familyId;
      if (familyId != null) {
        historyProvider.getEvents(familyId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final history = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('ประวัติกิจกรรม'),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        centerTitle: false,
      ),
      body: history.isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.errorMessage != null
          ? _ErrorView(message: history.errorMessage!, onRetry: _fetchData)
          : RefreshIndicator(
              onRefresh: () async => _fetchData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  CalendarWidget(
                    selectedDate: _selectedDate,
                    eventData: history.eventData,
                    onDateSelected: (date) =>
                        setState(() => _selectedDate = date),
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  SummarySection(
                    date: _selectedDate,
                    data: history.getDataForDate(_selectedDate),
                  ),
                ],
              ),
            ),
    );
  }
}
// ---------------------------------------------------------------------------
//  ErrorView
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: cs.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('ลองใหม่อีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }
}

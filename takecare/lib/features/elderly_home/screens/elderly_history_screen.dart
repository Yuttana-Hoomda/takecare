import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import '../provider/history_provider.dart';
import '../components/calendar_component.dart';
import '../components/summary_section.dart';

class ElderlyCalendarScreen extends StatefulWidget {
  const ElderlyCalendarScreen({super.key});

  @override
  State<ElderlyCalendarScreen> createState() => _ElderlyCalendarScreenState();
}

class _ElderlyCalendarScreenState extends State<ElderlyCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user?.familyId;
      if (familyId != null) {
        Provider.of<HistoryProvider>(context, listen: false)
            .getEvents(familyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          fontFamily: 'GoogleSans',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              _headerMonthYear(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
        ],
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyProvider.errorMessage != null
          ? _ErrorView(
        message: historyProvider.errorMessage!,
        onRetry: () {
          final familyId = Provider.of<AuthProvider>(
            context,
            listen: false,
          ).user?.familyId;
          if (familyId != null) {
            historyProvider.getEvents(familyId);
          }
        },
      )
          : ListView(
        children: [
          CalendarWidget(
            selectedDate: _selectedDate,
            eventData: historyProvider.eventData,
            onDateSelected: (date) {
              setState(() => _selectedDate = date);
            },
          ),
          SummarySection(
            date: _selectedDate,
            data: historyProvider.getDataForDate(_selectedDate),
          ),
        ],
      ),
    );
  }

  String _headerMonthYear() {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[_selectedDate.month]} ${_selectedDate.year}';
  }
}

// ---------------------------------------------------------------------------

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
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('ลองใหม่'),
          ),
        ],
      ),
    );
  }
}
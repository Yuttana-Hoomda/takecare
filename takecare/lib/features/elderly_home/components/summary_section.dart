import 'package:flutter/material.dart';
import '../models/event_task.dart';


class SummarySection extends StatelessWidget {
  final DateTime date;
  final DayData? data;

  const SummarySection({
    super.key,
    required this.date,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: data == null
          ? const _EmptyState()
          : _SummaryContent(date: date, data: data!),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('📅', style: TextStyle(fontSize: 36)),
        const SizedBox(height: 8),
        Text(
          'Select a date to view details',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryContent extends StatelessWidget {
  final DateTime date;
  final DayData data;

  const _SummaryContent({required this.date, required this.data});

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Summary: ${_monthNames[date.month]} ${date.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            _StatusBadge(status: data.status),
          ],
        ),
        const SizedBox(height: 14),
        ...data.tasks.map((eventTask) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _TaskCard(eventTask: eventTask),
        )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final DayStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    late Color bg, border, text;
    late String label;

    switch (status) {
      case DayStatus.complete:
        bg = cs.tertiaryContainer;
        border = cs.tertiary;
        text = cs.onTertiaryContainer;
        label = 'All Done ✓';
        break;
      case DayStatus.missed:
        bg = cs.errorContainer;
        border = cs.error;
        text = cs.onErrorContainer;
        label = 'Missed ✗';
        break;
      case DayStatus.partial:
        bg = cs.secondaryContainer;
        border = cs.secondary;
        text = cs.onSecondaryContainer;
        label = 'Partial';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TaskCard extends StatelessWidget {
  final EventTask eventTask;
  const _TaskCard({required this.eventTask});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final task = eventTask.task;
    final isDone = eventTask.isDone;

    final String detail = isDone
        ? (eventTask.completedAt ?? 'Completed')
        : (task.note?.isNotEmpty == true ? task.note! : 'Not completed');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDone ? cs.surfaceContainerLow : cs.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? cs.outlineVariant : cs.error.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDone
                  ? cs.primaryContainer
                  : cs.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(task.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),

          // Title + detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Check / Cross
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? cs.tertiary : cs.error,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.close,
              color: isDone ? cs.onTertiary : cs.onError,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
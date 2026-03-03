import 'package:flutter/material.dart';
import 'schedule_tile.dart';

class TimelineDot extends StatelessWidget {
  final TaskStatus status;
  final bool isLast;

  const TimelineDot({super.key, required this.status, required this.isLast});

  Color _color(BuildContext context) {
    switch (status) {
      case TaskStatus.finished: return const Color(0xFF00E676);
      case TaskStatus.missed:   return const Color(0xFFFF5252);
      case TaskStatus.now:      return Theme.of(context).colorScheme.primary;
      case TaskStatus.next:     return Theme.of(context).colorScheme.outlineVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _color(context)),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}
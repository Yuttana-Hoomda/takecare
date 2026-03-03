import 'package:flutter/material.dart';
import 'schedule_tile.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    late Color bg, text;
    late String label;
    late IconData icon;

    switch (status) {
      case TaskStatus.finished:
        bg = const Color(0xFF4DB887).withOpacity(0.15);
        text = const Color(0xFF4DB887);
        label = 'COMPLETED'; icon = Icons.check_circle_outline; break;
      case TaskStatus.missed:
        bg = const Color(0xFFFF7F7F).withOpacity(0.15);
        text = const Color(0xFFFF7F7F);
        label = 'UNCOMPLETED'; icon = Icons.timer_outlined; break;
      case TaskStatus.now:
        bg = Colors.white.withOpacity(0.2);
        text = Colors.white;
        label = 'CURRENT'; icon = Icons.access_time; break;
      case TaskStatus.next:
        bg = cs.surfaceContainerHighest;
        text = cs.onSurfaceVariant;
        label = 'UPCOMING'; icon = Icons.radio_button_unchecked; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: text)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/event_task.dart';

class TaskCard extends StatelessWidget {
  final EventTask eventTask;
  const TaskCard({super.key, required this.eventTask});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final task = eventTask.task;
    final isDone = eventTask.isDone;

    final String detail = isDone
        ? (eventTask.completedAt ?? 'Completed')
        : (task.note?.isNotEmpty == true ? task.note! : 'Not completed');

    final Color cardBg = isDone
        ? const Color(0xFFEAF7F1)
        : const Color(0xFFFFF0F0);

    final Color cardBorder = isDone
        ? const Color(0xFF4DB887)
        : const Color(0xFFFF7F7F);

    final Color iconBg = isDone
        ? const Color(0xFF4DB887).withOpacity(0.15)
        : const Color(0xFFFF7F7F).withOpacity(0.15);

    final Color checkColor = isDone
        ? const Color(0xFF4DB887)
        : const Color(0xFFFF7F7F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(task.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: checkColor),
            child: Icon(
              isDone ? Icons.check : Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
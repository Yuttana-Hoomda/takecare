import 'package:flutter/material.dart';
import '../models/event_task.dart';

class StatusBadge extends StatelessWidget {
  final DayStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color bg, border, text;
    late String label;

    switch (status) {
      case DayStatus.complete:
        bg = const Color(0xFFEAF7F1);
        border = const Color(0xFF4DB887);
        text = const Color(0xFF4DB887);
        label = 'All Done ✓';
        break;
      case DayStatus.missed:
        bg = const Color(0xFFFFF0F0);
        border = const Color(0xFFFF7F7F);
        text = const Color(0xFFFF7F7F);
        label = 'Missed ✗';
        break;
      case DayStatus.partial:
        bg = const Color(0xFFFFF4E6);
        border = const Color(0xFFFFAA55);
        text = const Color(0xFFFFAA55);
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
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }
}
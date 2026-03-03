import 'package:flutter/material.dart';
import 'schedule_tile.dart';

class StatusLabel extends StatelessWidget {
  final TaskStatus status;
  const StatusLabel({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color color;
    switch (status) {
      case TaskStatus.finished:
        label = 'FINISHED'; color = const Color(0xFF4DB887); break;
      case TaskStatus.missed:
        label = 'MISSED'; color = const Color(0xFFFF7F7F); break;
      case TaskStatus.now:
        label = 'NOW'; color = Colors.white; break;
      case TaskStatus.next:
        label = 'NEXT'; color = Colors.grey; break;
    }
    return Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    );
  }
}
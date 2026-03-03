import 'package:flutter/material.dart';
import '../models/event_task.dart';
import 'status_badge.dart';
import 'task_card.dart';

class SummarySection extends StatelessWidget {
  final DateTime date;
  final DayData? data;
  const SummarySection({super.key, required this.date, required this.data});
  static const List<String> _monthNames = [
    '', 'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
  ];
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (data == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'เลือกวันเพื่อดูรายละเอียด',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'สรุป: วันที่ ${date.day} ${_monthNames[date.month]} ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface),
              ),
              StatusBadge(status: data!.status),
            ],
          ),
          const SizedBox(height: 14),
          ...data!.tasks.map((eventTask) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TaskCard(eventTask: eventTask),
          )),
        ],
      ),
    );
  }
}
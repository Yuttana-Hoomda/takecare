import 'package:flutter/material.dart';
import 'package:takecare/features/elderly_history/models/event_task.dart';
import 'timeline_dot.dart';
import 'schedule_card.dart';

enum TaskStatus { finished, missed, now, next }

class ScheduleTile extends StatefulWidget {
  final EventTask eventTask;
  final bool isLast;

  const ScheduleTile({super.key, required this.eventTask, required this.isLast});

  @override
  State<ScheduleTile> createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<ScheduleTile> {
  bool _markedComplete = false;

  TaskStatus get _status {
    if (widget.eventTask.isDone || _markedComplete) return TaskStatus.finished;

    final now = DateTime.now(); // เวลาจริงตอนนี้
    final taskDate = widget.eventTask.task.createdAt; // วันที่ของ Task นี้

    // สร้าง DateTime ของ Task เพื่อเอามาเทียบกับ DateTime.now() ได้ตรงๆ
    final taskDateTime = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
      widget.eventTask.task.time.hour,
      widget.eventTask.task.time.minute,
    );

    final difference = taskDateTime.difference(now).inMinutes;

    // 1. ถ้าเป็นวันที่ในอดีต (เมื่อวานลงไป)
    if (taskDateTime.isBefore(DateTime(now.year, now.month, now.day))) {
      return TaskStatus.missed;
    }

    // 2. ถ้าเป็นวันที่ในอนาคต (พรุ่งนี้เป็นต้นไป)
    if (taskDateTime.isAfter(DateTime(now.year, now.month, now.day, 23, 59))) {
      return TaskStatus.next;
    }

    // 3. ถ้าเป็น "วันนี้" ค่อยเช็คช่วงเวลา (เหมือนเดิมที่คุณทำไว้)
    if (difference < -30) return TaskStatus.missed;
    if (difference.abs() <= 30) return TaskStatus.now;
    return TaskStatus.next;
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TimelineDot(status: status, isLast: widget.isLast),
          const SizedBox(width: 12),
          Expanded(
            child: ScheduleCard(
              eventTask: widget.eventTask,
              status: status,
              onMarkComplete: () => setState(() => _markedComplete = true),
            ),
          ),
        ],
      ),
    );
  }
}
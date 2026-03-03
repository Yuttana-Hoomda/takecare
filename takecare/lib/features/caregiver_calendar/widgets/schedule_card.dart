import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/features/elderly_history/models/event_task.dart';
import '/constants/app_theme.dart';
import 'schedule_tile.dart';
import 'status_label.dart';
import 'status_badge.dart';

class ScheduleCard extends StatelessWidget {
  final EventTask eventTask;
  final TaskStatus status;
  final VoidCallback onMarkComplete;

  const ScheduleCard({
    super.key,
    required this.eventTask,
    required this.status,
    required this.onMarkComplete,
  });

  bool get _isCurrent => status == TaskStatus.now;

  Color _leftBorderColor() {
    switch (status) {
      case TaskStatus.finished:
        return const Color(0xFF00E676);
      case TaskStatus.missed:
        return const Color(0xFFFF5252);
      case TaskStatus.now:
        return Colors.transparent;
      case TaskStatus.next:
        return const Color(0xFFE0E0E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = eventTask.task;
    final timeStr = task.time.format(context);
    final Color cardBg = _isCurrent ? AppTheme.primaryColor : Colors.white;
    final Color titleColor = _isCurrent ? Colors.white : Colors.black87;
    final Color subtitleColor = _isCurrent
        ? Colors.white.withOpacity(0.8)
        : AppTheme.subtitle;
    final Color timeColor = status == TaskStatus.missed
        ? const Color(0xFFFF5252)
        : subtitleColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),

        // ใช้ border left ข้าง ๆ บอกสถานะ
        border: _isCurrent
            ? null
            : Border(left: BorderSide(color: _leftBorderColor(), width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // สเตตัสกับเวลา ที่อยู่บรรทัดเดียวกัน
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusLabel(status: status),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: timeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Icon + title + badge
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: _isCurrent
                      ? Colors.white.withOpacity(0.2)
                      : AppTheme.primaryColor.withOpacity(0.15), // ใช้สี secondary จาก AppTheme
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    task.icon,
                    width: 22,
                    height: 22,
                    colorFilter: _isCurrent
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),

          // Note
          if (task.note != null && task.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 52,
              ), // ให้ตรงกับแนวข้อความ Title
              child: Text(
                task.note!,
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
            ),

          // completedAt
          if (eventTask.isDone && eventTask.completedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 52),
              child: Text(
                eventTask.completedAt!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4DB887),
                ),
              ),
            ),

          // Action Buttons
          if (status == TaskStatus.missed || _isCurrent)
            const SizedBox(height: 16),

          // View Details Button (เมื่อเป็น Now)
          if (_isCurrent)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

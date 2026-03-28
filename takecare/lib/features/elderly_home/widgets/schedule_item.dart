import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/features/task/models/task_model.dart';
import '/constants/app_theme.dart';

class ScheduleItem extends StatelessWidget {
  final Task task;
  final bool isNow;
  final bool isLast;

  const ScheduleItem({
    super.key,
    required this.task,
    required this.isNow,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = task.time.format(context);
    final dotColor = isNow ? AppTheme.primaryColor : const Color(0xFFCCCCCC);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // dot
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: isNow
                        ? null
                        : Border.all(color: const Color(0xFFCCCCCC), width: 2),
                  ),
                ),
                // line ลงมา
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE5E5E5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isNow
                    ? Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isNow
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : const Color(0xFFF0F0F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(task.icon, width: 26, height: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        if (task.note != null && task.note!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            task.note!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: isNow ? AppTheme.primaryColor : Colors.grey,
                            fontWeight: isNow ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isNow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ตอนนี้',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
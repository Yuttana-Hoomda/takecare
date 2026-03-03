import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../task/models/task_model.dart';
import '/constants/app_theme.dart';

class TaskTimelineTile extends StatelessWidget {
  final Task task;
  final bool isLast;

  const TaskTimelineTile({
    super.key,
    required this.task,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = task.time.format(context);

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    task.icon,
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: VerticalDivider(
                    thickness: 2,
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    indent: 5,
                    endIndent: 5,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$timeStr • ${task.note ?? ''}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.subtitle,
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
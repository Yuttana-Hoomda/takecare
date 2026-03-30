import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/features/task_submission/providers/task_submission_provider.dart';
import 'package:takecare/features/task_submission/screens/task_alram_screen.dart';
import '/constants/app_theme.dart';

class NextTaskCard extends StatelessWidget {
  final Task? task;
  final VoidCallback? onComplete;

  const NextTaskCard({super.key, required this.task, this.onComplete});

  bool _isCompletedToday(BuildContext context, Task task) {
    final submissionProvider = Provider.of<TaskSubmissionProvider>(
      context,
      listen: false,
    );

    return submissionProvider.submissions.any((s) {
      return s.taskId.toString() == task.taskId.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 ไม่มี task
    if (task == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: 100,
          color: AppTheme.primaryColor,
          child: const Center(
            child: Text(
              'ไม่มีกิจกรรมที่กำลังจะถึง',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final timeStr = task!.time.format(context);
    final isCompleted = _isCompletedToday(context, task!);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: AppTheme.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        task!.icon,
                        width: 30,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task!.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (task!.note != null && task!.note!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              task!.note!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskAlarmScreen(
                                  taskId: task!.taskId ?? '',
                                  icon: Icons.task_alt,
                                  time: timeStr,
                                  title: task!.title,
                                  description: task!.note ?? '',
                                  color: AppTheme.primaryColor,
                                  isRequiredCamera: task!.isRequirePhoto ?? false,
                                ),
                              ),
                            );

                            if (result == true) {
                              onComplete?.call();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.grey.shade300
                          : Colors.white,
                      foregroundColor: isCompleted
                          ? Colors.grey
                          : AppTheme.primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'เสร็จแล้ว' : 'เสร็จสิ้นแล้ว',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

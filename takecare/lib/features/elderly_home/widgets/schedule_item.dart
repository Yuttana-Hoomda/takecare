import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/features/task/screens/task_detail_screen.dart';
import '/constants/app_theme.dart';

class ScheduleItem extends StatelessWidget {
  final Task task;
  final bool isNow;
  final bool isLast;
  final bool isCompleted; // รับค่ามาจากหน้า Home

  const ScheduleItem({
    super.key,
    required this.task,
    required this.isNow,
    this.isCompleted = false,
    this.isLast = false,
  });

  (Color, Color) _getColors() {
    if (task.icon.contains('medicine')) {
      return (const Color(0xFFEFF6FF), const Color(0xFF007BFF));
    } else if (task.icon.contains('doctor')) {
      return (Colors.green[50]!, Colors.green);
    } else {
      return (Colors.orange[50]!, Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = task.time.format(context);
    final colors = _getColors();

    // 🔥 สลับสีตามสถานะ: ถ้าเสร็จแล้วใช้สีเขียว
    final bgColor = isCompleted ? Colors.green[50]! : colors.$1;
    final iconColor = isCompleted ? Colors.green : colors.$2;
    final dotColor = isCompleted ? Colors.green : (isNow ? AppTheme.primaryColor : const Color(0xFFCCCCCC));

    return IntrinsicHeight(
      child: GestureDetector(
        onTap: () {
          if (task.taskId != null && task.taskId!.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TaskDetailScreen(taskId: task.taskId!)),
            );
          }
        },
        child: Opacity(
          opacity: isCompleted ? 0.7 : 1.0, // ทำเสร็จแล้วให้จางลงนิดนึง
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                        border: (isNow || isCompleted) ? null : Border.all(color: const Color(0xFFCCCCCC), width: 2),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: isCompleted ? Colors.green.withOpacity(0.3) : const Color(0xFFE5E5E5)),
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
                    border: isNow ? Border.all(color: AppTheme.primaryColor.withOpacity(0.4), width: 1.5) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_circle, color: Colors.green, size: 26) // ติ๊กถูกถ้าเสร็จแล้ว
                              : SvgPicture.asset(task.icon, width: 24, height: 24, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isCompleted ? Colors.grey[600] : Colors.black87),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(timeStr, style: TextStyle(fontSize: 14, color: isCompleted ? Colors.green : (isNow ? AppTheme.primaryColor : Colors.grey[600]), fontWeight: FontWeight.bold)),
                          if (isCompleted)
                            const Text('เสร็จแล้ว', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold))
                          else if (isNow)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
                              child: const Text('ตอนนี้', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
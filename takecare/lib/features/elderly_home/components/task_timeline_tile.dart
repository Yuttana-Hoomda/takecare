import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../task/models/task_model.dart';
import '/constants/app_theme.dart';

class TaskTimelineTile extends StatelessWidget {
  final Task task;
  final bool isLast;

  const TaskTimelineTile({Key? key, required this.task, this.isLast = false})
    : super(key: key);

  bool get _isNow {
    final now = DateTime.now();

    final isToday = task.createdAt.year == now.year &&
        task.createdAt.month == now.month &&
        task.createdAt.day == now.day;

    if (!isToday) return false; // ถ้าไม่ใช่วันนี้เลย return false

    // 2. ถ้าเป็นวันนี้ ค่อยเช็คช่วงเวลา (ห่างไม่เกิน 30 นาที)
    final taskMinutes = task.time.hour * 60 + task.time.minute;
    final nowMinutes = now.hour * 60 + now.minute;

    return (taskMinutes - nowMinutes).abs() <= 30;
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = task.time.format(context);
    // สีพื้นหลังของ Icon Container ตามสถานะ _isNow
    final iconBgColor = _isNow
        ? const Color(0xFF4DB887).withOpacity(0.15)
        : AppTheme.primaryColor.withOpacity(0.1);

    // สีของข้อความเวลา
    final timeTextColor = _isNow ? const Color(0xFF4DB887) : AppTheme.subtitle;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Timeline line (ส่วนเดิม)
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isNow
                        ? const Color(0xFF4DB887)
                        : AppTheme.primaryColor.withOpacity(0.4),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.primaryColor.withOpacity(0.15),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 2. Card Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // ปรับให้กึ่งกลางแนวตั้งจะดูสวยขึ้น
                children: [
                  // Icon container (เปลี่ยนสีพื้นหลังตามสถานะ)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconBgColor, // ใช้สีที่คำนวณไว้ข้างบน
                      borderRadius: BorderRadius.circular(90),
                    ),
                    child: Center(
                      child: SvgPicture.asset(task.icon, width: 25, height: 25),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title + Note (Time ย้ายไปอยู่ขวาบนแล้ว)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ชื่อกิจกรรม
                            Expanded(
                              child: Text(
                                task.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _isNow
                                    ? const Color(0xFF4DB887).withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                timeStr,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: timeTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // แสดงเฉพาะ Note ด้านล่าง
                        if (task.note != null && task.note!.isNotEmpty)
                          Text(
                            task.note!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subtitle.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
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

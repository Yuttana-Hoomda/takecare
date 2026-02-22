import 'package:flutter/material.dart';
import 'package:takecare/components/show_icon.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/task/models/task_model.dart';
import 'package:takecare/utils/format.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียดรายการ')),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShowIcon(
                          icon: task.icon,
                          iconColor: _iconColor().$2,
                          bgColor: _iconColor().$1,
                          size: 70,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          task.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoSection(
                            context,
                            Icons.schedule_outlined,
                            'เวลา',
                            Format().timeToString(task.time),
                          ),
                          const SizedBox(height: 28),
                          _infoSection(
                            context,
                            Icons.update_outlined,
                            'วันที่แจ้งเตือน',
                            (task.date?.isNotEmpty == true)
                                ? Format().dateToString(task.date!)
                                : Format().repeatedDay(task.repeatDays),
                          ),

                          if (task.isRequiredPhoto == true) ...[
                            const SizedBox(height: 28),
                            _infoSection(
                              context,
                              Icons.photo_camera_outlined,
                              'รูปถ่าย',
                              'ใช้รูปถ่าย',
                            ),
                          ],

                          const SizedBox(height: 28),
                          _infoSection(
                            context,
                            Icons.article_outlined,
                            'หมายเหตุ',
                            (task.note?.trim().isNotEmpty == true) ? task.note! : '-',
                          ),
                          const SizedBox(height: 28),
                          const Divider(),
                          Text(Format().createAtToString(task.createdAt))
                        ],
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                      ),
                      onPressed: () {},
                      label: const Text('แก้ไข'),
                      icon: Icon(Icons.edit_outlined),
                    ),
                    const SizedBox(height: 16,),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red,
                        minimumSize: const Size(
                          double.infinity,
                          50,
                        ),
                      ),
                      onPressed: () {},
                      label: Text(
                        'ลบ',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      icon: Icon(Icons.delete_outlined),
                    ),
                  ],
                )
              ],
            ),
          ),
      )
    );
  }

  (Color, Color) _iconColor() {
    if (task.icon.contains('medicine')) {
      return (const Color(0xFFEFF6FF), const Color(0xFF007BFF));
    } else if (task.icon.contains('doctor')) {
      return (Colors.green[50]!, Colors.green);
    } else {
      return (Colors.orange[50]!, Colors.orange);
    }
  }

  Widget _infoSection(
    BuildContext context,
    IconData icon,
    String label,
    String? content,
  ) {
    return Row(
      children: [
        ShowIcon(
          iconData: icon,
          iconColor: AppTheme.subtitle,
          bgColor: Colors.grey[100]!,
          size: 40,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.subtitle
              )),
              Text(content!, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ],
    );
  }
}

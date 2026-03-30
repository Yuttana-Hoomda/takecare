import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/components/task_card.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/features/task/screens/task_form_screen.dart';
import 'package:takecare/features/task/screens/task_detail_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final familyId = Provider.of<AuthProvider>(
        context,
        listen: false,
      ).user?.familyId;
      if (familyId != null) {
        // caregiver screen — elderlyId ไม่จำเป็น ส่ง empty string
        Provider.of<TaskProvider>(
          context,
          listen: false,
        ).getTasks(familyId, elderlyId: '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('รายการที่สร้าง')),
      body: tasks == null || tasks.isEmpty
          ? Center(
        child: Text(
          'ยังไม่มีรายการ',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView.separated(
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = tasks[index];
            if (task == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return TaskCard(
              title: task.title,
              time: task.time,
              date: task.date,
              repeatedDay: task.repeatDays,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TaskDetailScreen(taskId: task.taskId!),
                  ),
                );
              },
              icon: task.icon,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
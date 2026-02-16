import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/components/task_card.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/task/providers/task_provider.dart';
import 'package:takecare/features/task/screens/create_task_screen.dart';

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
        Provider.of<TaskProvider>(context, listen: false).getTasks(familyId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(title: const Text('รายการที่สร้าง')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: ListView.separated(
          itemCount: tasks?.length ?? 0,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final task = tasks?[index];
            return TaskCard(
              title: task!.title,
              time: task.time,
              type: task.type,
              repeatedDay: task.repeatDays,
              detail: task.details,
              onTap: () {},
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateTaskScreen()
              )
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Screen'),
      ),
      body: const Center(
        child: Text('This is the Task Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for adding a new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
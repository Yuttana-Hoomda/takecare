import 'package:flutter/material.dart';

class TaskTypeCard extends StatefulWidget {
  const TaskTypeCard({
    super.key,
    required this.icon,
    required this.type,
    required this.onTap
  });

  final IconData icon;
  final String type;
  final VoidCallback onTap;

  @override
  State<TaskTypeCard> createState() => _TaskTypeCardState();
}

class _TaskTypeCardState extends State<TaskTypeCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(widget.icon),
              const SizedBox(height: 8,),
              Text(widget.type)
            ],
          ),
        )
      ),
    );
  }
}

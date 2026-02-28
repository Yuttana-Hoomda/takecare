import 'package:flutter/material.dart';

Widget buildScheduleHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Today's Schedule",
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      TextButton(onPressed: () {}, child: const Text("See All")),
    ],
  );
}

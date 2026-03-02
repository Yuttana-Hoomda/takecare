import 'package:flutter/material.dart';

Widget buildScheduleHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "ตารางงานวันนี้",
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      TextButton(onPressed: () {}, child: const Text("ดูทั้งหมด")),
    ],
  );
}

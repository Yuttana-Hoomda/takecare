import 'package:flutter/material.dart';

/// ประเภทของกิจกรรม — เพิ่มได้เรื่อยๆ
enum ActivityType {
  medication,
  meal,
  walk,
  bloodPressure,
  heartRate,
  sleep,
  water,
  appointment,
}

/// Model สำหรับ Recent Activity แต่ละรายการ
class ActivityItem {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String time;

  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  /// Icon ของแต่ละประเภทกิจกรรม
  IconData get icon {
    switch (type) {
      case ActivityType.medication:
        return Icons.medication_outlined;
      case ActivityType.meal:
        return Icons.restaurant_outlined;
      case ActivityType.walk:
        return Icons.directions_walk_outlined;
      case ActivityType.bloodPressure:
        return Icons.favorite_border;
      case ActivityType.heartRate:
        return Icons.monitor_heart_outlined;
      case ActivityType.sleep:
        return Icons.bedtime_outlined;
      case ActivityType.water:
        return Icons.water_drop_outlined;
      case ActivityType.appointment:
        return Icons.calendar_today_outlined;
    }
  }

  /// สี icon + พื้นหลัง icon ของแต่ละประเภท
  Color get iconColor {
    switch (type) {
      case ActivityType.medication:
        return const Color(0xFF007BFF);
      case ActivityType.meal:
        return const Color(0xFFE07B00);
      case ActivityType.walk:
        return const Color(0xFF7B3FE4);
      case ActivityType.bloodPressure:
        return const Color(0xFFE44040);
      case ActivityType.heartRate:
        return const Color(0xFFE44040);
      case ActivityType.sleep:
        return const Color(0xFF3F7BE4);
      case ActivityType.water:
        return const Color(0xFF00B4D8);
      case ActivityType.appointment:
        return const Color(0xFF2E7D32);
    }
  }

  Color get iconBgColor => iconColor.withOpacity(0.12);
}

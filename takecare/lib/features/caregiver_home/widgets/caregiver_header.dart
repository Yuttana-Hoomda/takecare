import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

/// Header: รูปโปรไฟล์ + ชื่อ dashboard + สถานะ
class CaregiverHeader extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final bool isOnline;
  final VoidCallback? onNotificationTap;

  const CaregiverHeader({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.isOnline = true,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Avatar + online dot
        Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppTheme.secondary,
              backgroundImage: NetworkImage(avatarUrl),
              onBackgroundImageError: (_, __) {},
            ),
            if (isOnline)
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 12),

        // ชื่อ + สถานะ
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$name's Dashboard", style: textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(
                isOnline ? 'Online now' : 'Offline',
                style: textTheme.titleSmall?.copyWith(
                  color: isOnline ? Colors.green : AppTheme.subtitle,
                ),
              ),
            ],
          ),
        ),

        // Bell
        IconButton(
          onPressed: onNotificationTap ?? () {},
          icon: const Icon(Icons.notifications_outlined, size: 26),
          color: Colors.black87,
        ),
      ],
    );
  }
}

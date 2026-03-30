import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

// แสดงรูปและชื่อผู้สูงอายุที่ caregiver ดูแลอยู่
class CaregiverHeader extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const CaregiverHeader({
    super.key,
    required this.name,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppTheme.secondary,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          onBackgroundImageError: avatarUrl.isNotEmpty ? (_, __) {} : null,
          child: avatarUrl.isEmpty
              ? const Icon(Icons.person, color: AppTheme.primaryColor)
              : null,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'สวัสดีตอนเช้า,,',
                style: textTheme.bodySmall?.copyWith(color: AppTheme.subtitle),
              ),
              Text(
                name.isNotEmpty ? name : 'ผู้สูงอายุ',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

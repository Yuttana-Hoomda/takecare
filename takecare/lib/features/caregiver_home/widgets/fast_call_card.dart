import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

/// Card โทรหาด่วน (Fast Call)
class FastCallCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const FastCallCard({
    super.key,
    this.title = 'โทรหาด่วน',
    this.subtitle = 'แตะเพื่อโทรหาผู้ดูแลทันที',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.secondary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            // ข้อความ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCF5E7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'FAST CALL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),

            // ไอคอนโทรศัพท์
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.contact_phone_outlined,
                color: AppTheme.primaryColor,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

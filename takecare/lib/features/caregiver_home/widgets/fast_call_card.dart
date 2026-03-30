import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:takecare/constants/app_theme.dart';

// กด fast call → เปิดแอพโทรของเครื่องพร้อมเบอร์ elder
class FastCallCard extends StatelessWidget {
  final String phoneNumber;

  const FastCallCard({
    super.key,
    required this.phoneNumber,
  });

  Future<void> _call(BuildContext context) async {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบเบอร์โทรของผู้สูงอายุ')),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถโทรออกได้')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _call(context),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      'โทรด่วน',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('โทรหาผู้สูงอายุ', style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber.isNotEmpty
                        ? phoneNumber
                        : 'ไม่พบเบอร์โทร',
                    style: textTheme.bodyMedium?.copyWith(
                      color: phoneNumber.isNotEmpty
                          ? AppTheme.primaryColor
                          : AppTheme.subtitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
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

import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

/// Card แสดงข้อมูลผู้ดูแล: รูปโปรไฟล์ + ชื่อ + เบอร์โทร
class VerifyCaregiverCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String phoneNumber;

  const VerifyCaregiverCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // รูปโปรไฟล์ + ✓
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // วงกลมพื้นหลัง
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0E6DC),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: AppTheme.subtitle,
                    ),
                  ),
                ),
              ),
            ),

            //  ✓ มุมขวาล่าง
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ชื่อ
        Text(name, style: textTheme.titleLarge),

        const SizedBox(height: 10),

        // เบอร์โทร pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                phoneNumber,
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

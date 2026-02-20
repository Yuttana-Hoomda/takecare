import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';

/// Card ก้อนที่ 1 ไอคอน + หัวข้อ + คำอธิบาย + ช่องแสดงเบอร์
class PhoneInputCard extends StatelessWidget {
  final String formattedPhone;

  const PhoneInputCard({super.key, required this.formattedPhone});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.secondary),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ไอคอนวงกลม
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.contact_phone_outlined,
                color: AppTheme.primaryColor,
                size: 36,
              ),
            ),

            const SizedBox(height: 16),

            // หัวข้อ
            Text('กรอกเบอร์โทรผู้ดูแล', style: textTheme.titleLarge),

            const SizedBox(height: 8),

            // คำอธิบาย
            Text(
              'กรอกหมายเลขโทรศัพท์ของสมาชิกในครอบครัว\nที่จะจัดการดูแลคุณ',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            // ช่องแสดงเบอร์
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.bgColorLight,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.mobile_friendly,
                    color: AppTheme.subtitle,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formattedPhone,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const AnimatedCursor(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // หมายเหตุ
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: textTheme.titleSmall?.fontSize ?? 14,
                  color: AppTheme.subtitle,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'ระบบจะส่งคำขอเชื่อมต่อไปยังหมายเลขนี้',
                    style: textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Cursor กระพริบ
class AnimatedCursor extends StatefulWidget {
  const AnimatedCursor({super.key});

  @override
  State<AnimatedCursor> createState() => _AnimatedCursorState();
}

class _AnimatedCursorState extends State<AnimatedCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 2, height: 22, color: AppTheme.primaryColor),
    );
  }
}

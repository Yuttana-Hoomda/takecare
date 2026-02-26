import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/home/screens/main_wrapper.dart';
import 'package:takecare/features/comfirm_account/widgets/verify_caregiver_card.dart';
import 'package:takecare/features/link_family/providers/link_family_provider.dart';

class VerifyCaregiverScreen extends StatelessWidget {
  const VerifyCaregiverScreen({super.key});

  Future<void> _onConfirm(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final linkProvider = context.read<LinkFamilyProvider>();

    final elder = linkProvider.foundElder;
    final token = authProvider.firebaseToken;

    if (elder == null || token == null) return;

    final success = await linkProvider.confirmLink(elder.uid, token);

    if (!context.mounted) return;

    if (success) {
      // Refresh user profile เพื่ออัปเดต familyId ใน AuthProvider
      await authProvider.refreshUser();

      if (!context.mounted) return;

      // Navigate ไป CaregiverHomeScreen และเคลียร์ stack ทั้งหมด
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainWrapper()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(linkProvider.errorMessage ?? 'เกิดข้อผิดพลาด'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final linkProvider = context.watch<LinkFamilyProvider>();
    final elder = linkProvider.foundElder;
    final isLoading = linkProvider.linkStatus == LinkFamilyStatus.loading;

    return Scaffold(
      backgroundColor: AppTheme.bgColorLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgColorLight,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: Text('ยืนยันบัญชี', style: textTheme.titleMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // หัวข้อ
            Text(
              'ยืนยันผู้ดูแลของคุณ',
              style: textTheme.titleLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              'บุคคลนี้คือผู้ดูแลของคุณใช่หรือไม่',
              style: textTheme.bodyMedium?.copyWith(color: AppTheme.subtitle),
            ),

            const SizedBox(height: 40),

            // Card แสดงข้อมูล elder ที่ดึงมาจาก API
            if (elder != null)
              VerifyCaregiverCard(
                imageUrl: elder.profilePictureUrl,
                name: elder.displayName,
                phoneNumber: elder.phoneNumber,
              )
            else
              const CircularProgressIndicator(),

            const Spacer(flex: 3),

            // ปุ่ม ยืนยัน
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (isLoading || elder == null)
                    ? null
                    : () => _onConfirm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.secondary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'ยืนยันผู้ดูแล',
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่ม ย้อนกลับ เปลี่ยนเบอร์
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.subtitle,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'ไม่ใช่ เปลี่ยนหมายเลข',
                  style: textTheme.titleLarge?.copyWith(fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

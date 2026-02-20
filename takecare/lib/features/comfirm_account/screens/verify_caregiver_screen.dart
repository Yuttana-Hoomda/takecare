import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/comfirm_account/widgets/verify_caregiver_card.dart';

class VerifyCaregiverScreen extends StatelessWidget {
  const VerifyCaregiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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

            // Card แสดงข้อมูลผู้ดูแล
            VerifyCaregiverCard(
              // imageUrl:
              //     'https://img.freepik.com/free-photo/cheerful-old-casual-asian-woman_53876-26362.jpg?semt=ais_hybrid&w=740&q=80',
              imageUrl:
                  'https://hilight.thaicdn.net/img_cms2/user/thachapol/tah/ee1226.jpg',
              name: 'ยายสมศรี',
              phoneNumber: '081-234-5678',
            ),

            const Spacer(flex: 3),

            // ปุ่ม Yes
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.subtitle,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยืนยันผู้ดูแล',
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ปุ่ม No
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  foregroundColor: AppTheme.subtitle,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ไม่ใช่ เปลี่ยนหมายเลข',
                      style: textTheme.titleLarge?.copyWith(fontSize: 15),
                    ),
                  ],
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

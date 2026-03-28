import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/screens/AuthWrapper.dart';
import 'package:takecare/features/auth/screens/select_ncd_screen.dart';
import 'package:takecare/features/caregiver_home/screens/caregiver_home_screen.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  int? _selectedIndex;

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('เลือกบท')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child:
                  Column(
                    children: [
                      Column(
                        children: [
                          Text('คุณคือใคร', style: textTheme.titleLarge),
                          Text(
                            'คุณคือใคร? เลือกบทบาทเพื่อเริ่มต้นใช้งานได้เลย',
                            style: TextStyle(color: AppTheme.subtitle),
                          ),
                        ],
                      ),
                      SizedBox(height: 24,),
                      Column(
                        children: [
                          _roleCard(
                            img: 'assets/elderly.png',
                            role: 'ผู้สูงอายุ',
                            description: 'I want to receive care and medication reminders.',
                            isSelected: _selectedIndex == 0,
                            onTap: () => _onTap(0),
                          ),
                          const SizedBox(height: 24),
                          _roleCard(
                            img: 'assets/caregiver.png',
                            role: 'ลูกหลาน',
                            description: 'I want to manage medication and nutrition for others.',
                            isSelected: _selectedIndex == 1,
                            onTap: () => _onTap(1),
                          ),
                        ],
                      ),
                    ],
                  )
              ),

              // ── Continue Button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  // ปิดปุ่มไว้ (ส่งค่า null) ถ้ายังไม่ได้เลือกอะไรเลย
                  onPressed: _selectedIndex != null
                      ? () async {
                    // กรณีที่ 1: เลือก Caregiver (_selectedIndex == 1)
                    if (_selectedIndex == 1) {
                      final success = await authProvider.updateRoleToCaregiver();

                      if (success && context.mounted) {
                        // ถ้าอัปเดตสำเร็จ พาไปหน้า AuthWrapper
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthWrapper(),
                          ),
                              (route) => false,
                        );
                      } else if (context.mounted) {
                        // (เสริมให้) ถ้าอัปเดต "ไม่สำเร็จ" ควรแจ้งเตือน ไม่ใช่พาไปหน้า Elder
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authProvider.errorMessage ?? 'เกิดข้อผิดพลาด')),
                        );
                      }
                    }
                    // กรณีที่ 2: เลือก Elder (_selectedIndex ไม่ใช่ 1)
                    else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectNcdScreen(),
                        ),
                      );
                    }
                  } // 👈 เพิ่มปีกกาปิดของฟังก์ชัน () async ไว้ตรงนี้!
                      : null, // 👈 ถ้า _selectedIndex == null ปุ่มจะกดไม่ได้ (Disable)
                  child: Text(
                    'ถัดไป',
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _roleCard({
  required String img,
  required String role,
  required String description,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppTheme.primaryColor.withAlpha(85)
                : Colors.black.withAlpha(90),
            blurRadius: isSelected ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: AssetImage(img),
            onBackgroundImageError: (_, _) {},
          ),
          const SizedBox(height: 14),
          Text(
            role,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black45,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}
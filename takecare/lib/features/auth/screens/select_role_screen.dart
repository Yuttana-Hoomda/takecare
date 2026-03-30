import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/screens/AuthWrapper.dart';
import 'package:takecare/features/auth/screens/select_ncd_screen.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Header — fixed height
              Text('คุณคือใคร', style: textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                'คุณคือใคร? เลือกบทบาทเพื่อเริ่มต้นใช้งานได้เลย',
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 32),

              // Cards — fill remaining space
              Expanded(
                child: Column(
                  children: [
                    Flexible( // ✅ Flexible not Expanded — avoids layout crash
                      child: _roleCard(
                        img: 'assets/elderly.png',
                        role: 'ผู้สูงอายุ',
                        description: 'รับการแจ้งเตือนจากลูกหลาน และถ่ายรูปอาหารเพื่อให้ AI วิเคราะห์ความเหมาะสมกับสุขภาพ',
                        isSelected: _selectedIndex == 0,
                        onTap: () => _onTap(0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Flexible( // ✅ Flexible not Expanded
                      child: _roleCard(
                        img: 'assets/caregiver.png',
                        role: 'ลูกหลาน',
                        description: 'สร้างการแจ้งเตือนและติดตามดูแลการกินอาหารของผู้สูงอายุได้จากระยะไกล',
                        isSelected: _selectedIndex == 1,
                        onTap: () => _onTap(1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Button — fixed at bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _selectedIndex != null
                      ? () async {
                    if (_selectedIndex == 1) {
                      final success = await authProvider.updateRoleToCaregiver();
                      if (success && context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthWrapper(),
                          ),
                              (route) => false,
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.errorMessage ?? 'เกิดข้อผิดพลาด'),
                          ),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SelectNcdScreen(),
                        ),
                      );
                    }
                  }
                      : null,
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
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 28),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 44,
            backgroundImage: AssetImage(img),
            onBackgroundImageError: (_, __) {}, // ✅ fixed: __ for unused param
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
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}
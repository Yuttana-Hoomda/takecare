import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/screens/login.dart';
import 'package:takecare/features/home/screens/main_wrapper.dart';
import 'package:takecare/features/link_family/screens/link_family_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authen = Provider.of<AuthProvider>(context);

    if (!authen.isAuthenticated) {
      return const Login();
    }

    final user = authen.user!;

    // ✅ caregiver ที่ยังไม่มี familyId → ไปหน้า link_family ก่อน
    if (user.role == Role.caregiver &&
        (user.familyId == null || user.familyId!.isEmpty)) {
      return const LinkFamilyScreen();
    }

    return const MainWrapper();
  }
}

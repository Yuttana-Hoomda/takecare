import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:takecare/constants/enum.dart';
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/screens/login_screen.dart';
import 'package:takecare/features/home/screens/main_wrapper.dart';
import 'package:takecare/features/link_family/screens/link_family_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authen = Provider.of<AuthProvider>(context);

    // 1. ยังไม่ login
    if (!authen.isAuthenticated) {
      return const LoginScreen();
    }

    final user = authen.user!;

    // 2. caregiver แต่ยังไม่มี family
    if (user.role == Role.caregiver &&
        (user.familyId == null || user.familyId!.isEmpty)) {
      return const LinkFamilyScreen();
    }

    // 3. กรณีอื่น
    return const MainWrapper();
  }
}

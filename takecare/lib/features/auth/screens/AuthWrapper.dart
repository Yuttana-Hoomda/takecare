import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <--- MUST HAVE THIS IMPORT
import 'package:takecare/features/auth/providers/auth_provider.dart';
import 'package:takecare/features/auth/screens/login_screen.dart';
import 'package:takecare/features/home/screens/main_wrapper.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authen = Provider.of<AuthProvider>(context);

    if (authen.isAuthenticated) {
      return const MainWrapper();
    } else {
      return const LoginScreen();
    }
  }
}
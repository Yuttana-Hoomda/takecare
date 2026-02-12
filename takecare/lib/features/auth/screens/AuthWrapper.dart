import 'package:flutter/material.dart';
import 'package:takecare/features/auth/screens/login.dart';
import 'package:takecare/features/home/screens/main_wrapper.dart';

class Authwrapper extends StatelessWidget {
  const Authwrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authen = true; // Simulated authentication status

    if (authen) {
      return MainWrapper();
    } else {
      return Login();
    }
  }
}
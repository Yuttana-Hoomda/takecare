import 'package:flutter/material.dart';
import 'package:takecare/constants/app_theme.dart';
import 'package:takecare/features/link_family/screens/link_family_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LinkFamilyScreen(),
    ),
  );
}

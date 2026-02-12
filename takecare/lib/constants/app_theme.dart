import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF007BFF);
  static const Color bgColorLight = Color(0xFFF5F7F8);
  static const Color bgColorDark = Color.fromARGB(255, 37, 37, 37);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColorLight,

    fontFamily: 'GoogleSans',
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColorDark,

    fontFamily: 'GoogleSans',
  );
}

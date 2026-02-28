import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF007BFF);
  static const Color secondary = Color(0xFFEFF6FF);
  static const Color subtitle = Color(0xFF64748B);
  static const Color bgColorLight = Color(0xFFF3F3F3);
  static const Color bgColorDark = Color.fromARGB(255, 37, 37, 37);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColorLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      surface: bgColorLight,
    ),

    fontFamily: 'GoogleSans',

    textTheme: const TextTheme(
      titleSmall: TextStyle(fontSize: 14, color: subtitle),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54), // Good for subtitles
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: bgColorLight,
      indicatorColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontFamily: 'GoogleSans',
          );
        }

        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.black54,
          fontFamily: 'GoogleSans',
        );
      }),

      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: primaryColor, size: 24);
        }
        return const IconThemeData(color: Colors.black54, size: 24);
      }),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white
      )
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white
    )
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColorDark,
    fontFamily: 'GoogleSans',
  );
}

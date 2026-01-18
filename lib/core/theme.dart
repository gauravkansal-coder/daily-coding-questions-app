import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static const Color primaryColor = Color(0xFF6200EA);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color errorColor = Color(0xFFB00020);

  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFFBB86FC);
  static const Color darkAccentColor = Color(0xFF03DAC6);
  static const Color darkBackgroundColor = Color(0xFF121212);

  // Text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimaryColor,
    scaffoldBackgroundColor: darkBackgroundColor,
  );
}

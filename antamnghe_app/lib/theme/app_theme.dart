import 'package:flutter/material.dart';

class AppTheme {
  // Modern palette (Style hiện đại)
  static const Color background = Color(0xFF0F172A); // main background
  static const Color card = Color(0xFF1E293B);
  static const Color primary = Color(0xFF6366F1); // main primary
  static const Color accent = Color(0xFF3B82F6);
  static const Color cta = Color(0xFFF59E0B);
  static const Color textTitle = Color(0xFFF9FAFB);
  static const Color textBody = Color(0xFFD1D5DB);
  static const Color placeholder = Color(0xFF6B7280);
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primary,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: textTitle,
      secondary: accent,
      onSecondary: textTitle,
      background: background,
      onBackground: textBody,
      surface: card,
      onSurface: textBody,
      error: Colors.red.shade400,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textTitle,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF020617),
      selectedItemColor: primary,
      unselectedItemColor: const Color(0xFF64748B),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      hintStyle: const TextStyle(color: placeholder),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cta,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF93C5FD)),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: textTitle,
      ),
      bodyMedium: TextStyle(fontSize: 14.0, color: textBody),
    ),
  );
}

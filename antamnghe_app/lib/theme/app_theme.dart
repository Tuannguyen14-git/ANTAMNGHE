import 'package:flutter/material.dart';

class AppTheme {
  // Modern Tech palette (applied per design notes)
  // Slightly warmer off-white background for softer contrast
  static const Color background = Color(0xFFF8FAFC); // #F8FAFC (requested)
  static const Color card = Color(0xFFFFFFFF); // #FFFFFF (cards)
  static const Color primary = Color(0xFFE63946); // Primary accent #E63946
  static const Color accent = Color(
    0xFFFFD166,
  ); // Accent (use sparingly) #FFD166
  static const Color cta = Color(0xFFE63946);
  static const Color textTitle = Color(0xFF1D1D1F); // Charcoal #1D1D1F
  static const Color textBody = Color(0xFF86868B); // Neutral gray #86868B
  static const Color secondaryText = Color(
    0xFF86868B,
  ); // alias for body #86868B
  static const Color placeholder = Color(0xFF9CA3AF);

  // Header gradient (banner): softened red tone for professional look
  // Suggested: #D31027 -> #EA384D
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFD31027), Color(0xFFEA384D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Pale red square background for icons (10% opacity)
  // 10% alpha ~= 0x1A
  static const Color iconBg = Color(0x1AE63946);
  // Avatar pale gray background
  static const Color avatarBg = Color(0xFFE5E5EA); // #E5E5EA
  // Arrow chevron color (thin, light grey)
  static const Color arrowColor = Color(0xFFD6D6DA);
  // Card gradient for elevated white cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Dark surface used instead of pure black for heavy cards/tiles
  // Use deep charcoal / dark slate to feel premium: #1C252E
  static const Color darkSurface = Color(0xFF1C252E); // #1C252E
  // Light search background (we often use pure white + subtle shadow in widgets)
  static const Color searchBackground = Color(0xFFFFFFFF); // white
  // Off-white text for dark surfaces (reduced glare)
  static const Color darkOnSurfaceText = Color(0xFFE8EAED); // #E8EAED
  // Muted icon color for subtle UI elements
  static const Color mutedIcon = Color(0xFF8E8E93); // #8E8E93
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: accent,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: textTitle,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    // Ensure inputs are readable on light surfaces
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: placeholder),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide.none,
      ),
    ),
    // Make card color available as Theme.cardColor and ensure readable text on cards
    cardColor: card,
    cardTheme: CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      shadowColor: const Color(0x0D000000), // ~5% black for very subtle shadow
    ),
    // Icons on light cards use the primary accent to create consistent brand color
    iconTheme: const IconThemeData(color: primary, size: 28),
    // List tiles and other surface widgets should use readable text colors by default
    listTileTheme: const ListTileThemeData(
      textColor: textTitle,
      iconColor: primary,
    ),
    // Text theme with default readable colors across the app
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: textTitle,
      ),
      bodyMedium: TextStyle(fontSize: 14.0, color: textTitle),
      bodyLarge: TextStyle(fontSize: 16.0, color: textTitle),
      labelLarge: TextStyle(fontSize: 14.0, color: textTitle),
    ).apply(bodyColor: textTitle, displayColor: textTitle),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primary,
      unselectedItemColor: secondaryText,
      showUnselectedLabels: true,
    ),
  );

  // For simplicity, use the same lightTheme for now as the app requested light palette.
  static final ThemeData darkTheme = lightTheme;
}

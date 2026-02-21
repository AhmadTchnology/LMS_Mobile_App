import 'package:flutter/material.dart';
import 'app_color_extension.dart';

class AppTheme {
  // Primary Colors (Ocean Blue - PURPLE BAN ENFORCED)
  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color primaryLight = Color(0xFF38BDF8);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardAlt = Color(0xFF2D3748);
  static const Color darkBorder = Color(0xFF475569);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Text Colors (Dark Theme Defaults)
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFE2E8F0);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF1F2937);

  // Text Colors (Light Theme Defaults)
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF6B7280);

  // Accent Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color orange = Color(0xFFF59E0B);

  /// Build a dark theme with optional custom primary + background colors.
  static ThemeData buildDarkTheme({
    Color? customPrimary,
    Color? customBackground,
    Color? customCard,
    Color? customTextPrimary,
    Color? customTextSecondary,
    Color? customButtonPrimary,
    Color? customButtonHover,
    Color? customBorder,
    Color? customSuccess,
    Color? customWarning,
    Color? customDanger,
  }) {
    final p = customPrimary ?? primary;
    final bg = customBackground ?? darkBackground;
    final card = customCard ?? darkCard;
    final txtP = customTextPrimary ?? textPrimary;
    final txtS = customTextSecondary ?? textSecondary;
    final btnP = customButtonPrimary ?? p;
    final btnH = customButtonHover ?? p.withValues(alpha: 0.8);
    final brd = customBorder ?? darkBorder;
    final cSuccess = customSuccess ?? success;
    final cWarning = customWarning ?? warning;
    final cDanger = customDanger ?? danger;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: bg,
      extensions: [
        AppColorExtension(
          textSecondary: txtS,
          buttonPrimary: btnP,
          buttonHover: btnH,
          border: brd,
          success: cSuccess,
          warning: cWarning,
          danger: cDanger,
        ),
      ],
      colorScheme: ColorScheme.dark(
        primary: p,
        secondary: p.withValues(alpha: 0.8),
        surface: card,
        onPrimary: txtP,
        onSurface: txtP,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: txtP,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: brd, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: TextStyle(color: txtP),
        prefixIconColor: textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnP,
          foregroundColor: txtP,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: p,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  /// Build a light theme with optional custom primary + background colors.
  static ThemeData buildLightTheme({
    Color? customPrimary,
    Color? customBackground,
    Color? customCard,
    Color? customTextPrimary,
    Color? customTextSecondary,
    Color? customButtonPrimary,
    Color? customButtonHover,
    Color? customBorder,
    Color? customSuccess,
    Color? customWarning,
    Color? customDanger,
  }) {
    final p = customPrimary ?? primary;
    final bg = customBackground ?? lightBackground;
    final card = customCard ?? lightCard;
    final txtP = customTextPrimary ?? lightTextPrimary;
    final txtS = customTextSecondary ?? lightTextSecondary;
    final btnP = customButtonPrimary ?? p;
    final btnH = customButtonHover ?? p.withValues(alpha: 0.8);
    final brd = customBorder ?? lightBorder;
    final cSuccess = customSuccess ?? success;
    final cWarning = customWarning ?? warning;
    final cDanger = customDanger ?? danger;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: bg,
      extensions: [
        AppColorExtension(
          textSecondary: txtS,
          buttonPrimary: btnP,
          buttonHover: btnH,
          border: brd,
          success: cSuccess,
          warning: cWarning,
          danger: cDanger,
        ),
      ],
      colorScheme: ColorScheme.light(
        primary: p,
        secondary: p.withValues(alpha: 0.7),
        surface: card,
        onPrimary: Colors.white,
        onSurface: txtP,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        foregroundColor: txtP,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: brd, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p, width: 2),
        ),
        hintStyle: const TextStyle(color: lightTextMuted),
        labelStyle: TextStyle(color: txtP),
        prefixIconColor: lightTextMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnP,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: p,
        unselectedItemColor: lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Static shortcut getters for default themes
  static ThemeData get darkTheme => buildDarkTheme();
  static ThemeData get lightTheme => buildLightTheme();
}

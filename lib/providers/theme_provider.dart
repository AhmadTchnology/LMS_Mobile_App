import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'lms_theme_mode';
  static const String _lightColorsKey = 'lms_custom_colors_light';
  static const String _darkColorsKey = 'lms_custom_colors_dark';

  ThemeMode _themeMode = ThemeMode.dark;
  Map<String, Color> _lightColors = {};
  Map<String, Color> _darkColors = {};

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Map<String, Color> get currentColors =>
      isDarkMode ? _darkColors : _lightColors;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final mode = prefs.getString(_themeKey);
    if (mode == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    // Load custom colors
    _lightColors = _parseColors(prefs.getString(_lightColorsKey));
    _darkColors = _parseColors(prefs.getString(_darkColorsKey));

    notifyListeners();
  }

  Map<String, Color> _parseColors(String? json) {
    if (json == null) {
      return {};
    }
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, Color(int.parse(value))));
  }

  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, isDarkMode ? 'dark' : 'light');
  }

  Future<void> updateColor(String key, Color color) async {
    if (isDarkMode) {
      _darkColors[key] = color;
    } else {
      _lightColors[key] = color;
    }
    notifyListeners();
    await _saveColors();
  }

  Future<void> setPreset(Map<String, Color> preset) async {
    if (isDarkMode) {
      _darkColors = Map.from(preset);
    } else {
      _lightColors = Map.from(preset);
    }
    notifyListeners();
    await _saveColors();
  }

  Future<void> _saveColors() async {
    final prefs = await SharedPreferences.getInstance();
    final key = isDarkMode ? _darkColorsKey : _lightColorsKey;
    final colors = isDarkMode ? _darkColors : _lightColors;

    final json = jsonEncode(
      colors.map((key, value) => MapEntry(key, value.toARGB32().toString())),
    );
    await prefs.setString(key, json);
  }

  Future<void> resetToDefaults() async {
    if (isDarkMode) {
      _darkColors = {};
    } else {
      _lightColors = {};
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(isDarkMode ? _darkColorsKey : _lightColorsKey);
  }

  ThemeData getThemeData() {
    final colors = currentColors;
    if (isDarkMode) {
      return AppTheme.buildDarkTheme(
        customPrimary: colors['primary'],
        customBackground: colors['background'],
        customCard: colors['card'],
        customTextPrimary: colors['textPrimary'],
        customTextSecondary: colors['textSecondary'],
        customButtonPrimary: colors['buttonPrimary'],
        customButtonHover: colors['buttonHover'],
        customBorder: colors['border'],
        customSuccess: colors['success'],
        customWarning: colors['warning'],
        customDanger: colors['danger'],
      );
    } else {
      return AppTheme.buildLightTheme(
        customPrimary: colors['primary'],
        customBackground: colors['background'],
        customCard: colors['card'],
        customTextPrimary: colors['textPrimary'],
        customTextSecondary: colors['textSecondary'],
        customButtonPrimary: colors['buttonPrimary'],
        customButtonHover: colors['buttonHover'],
        customBorder: colors['border'],
        customSuccess: colors['success'],
        customWarning: colors['warning'],
        customDanger: colors['danger'],
      );
    }
  }
}

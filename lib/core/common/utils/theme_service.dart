import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  static final ValueNotifier<Color> primaryColorNotifier = ValueNotifier(
    const Color(0xFF4F378A),
  );

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final modeStr = prefs.getString('theme_mode') ?? 'system';
      themeModeNotifier.value = _parseThemeMode(modeStr);

      final colorHex = prefs.getString('theme_primary_color');
      if (colorHex != null) {
        primaryColorNotifier.value = Color(int.parse(colorHex, radix: 16));
      }
    } catch (_) {}
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.name);
    } catch (_) {}
  }

  static Future<void> setPrimaryColor(Color color) async {
    primaryColorNotifier.value = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      final hex = color.value.toRadixString(16);
      await prefs.setString('theme_primary_color', hex);
    } catch (_) {}
  }

  static ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

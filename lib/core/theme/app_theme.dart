import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color secondaryColor = Color(0xFFFFFFFF);

  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightInputColor = Color(0xFFF7F8F9);

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkInputColor = Color(0xFF1E1E1E);

  static ThemeData lightThemeMode(Color primaryColor) => themeData(
    brightness: Brightness.light,
    backgroundColor: lightBackgroundColor,
    primaryColor: primaryColor,
  );

  static ThemeData darkThemeMode(Color primaryColor) => themeData(
    brightness: Brightness.dark,
    backgroundColor: darkBackgroundColor,
    primaryColor: primaryColor,
  );

  static ThemeData themeData({
    required Brightness brightness,
    required Color backgroundColor,
    required Color primaryColor,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        surface: backgroundColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF7F8F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        border: _border(isDark),
        enabledBorder: _border(isDark),
        focusedBorder: _border(isDark, primaryColor, 1.5),
        errorBorder: _border(isDark, Colors.red),
      ),
    );
  }

  static OutlineInputBorder _border(
    bool isDark, [
    Color? color,
    double width = 1,
  ]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: color ?? (isDark ? Colors.grey.shade800 : const Color(0xFFE8ECF4)),
      width: width,
    ),
  );
}

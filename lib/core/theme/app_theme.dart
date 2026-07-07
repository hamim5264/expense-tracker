import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4F378A);
  static const Color secondaryColor = Color(0xFFFFFFFF);
  static const Color buttonPrimaryColor = Color(0xFF65558F);

  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightInputColor = Color(0xFFF7F8F9);

  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkInputColor = Color(0xFF1E1E1E);

  static final lightThemeMode = _themeData(
    brightness: Brightness.light,
    backgroundColor: lightBackgroundColor,
  );

  static final darkThemeMode = _themeData(
    brightness: Brightness.dark,
    backgroundColor: darkBackgroundColor,
  );

  static ThemeData _themeData({
    required Brightness brightness,
    required Color backgroundColor,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
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
          backgroundColor: buttonPrimaryColor,
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
        fillColor: isDark ? darkInputColor : lightInputColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(primaryColor, 2),
        errorBorder: _border(Colors.red),
      ),
    );
  }

  static OutlineInputBorder _border([
    Color color = const Color(0xFFE8ECF4),
    double width = 1,
  ]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color, width: width),
  );
}

import 'package:flutter/material.dart';

/// 暗色调技术感主题
class DarkTheme {
  static const Color _bg = Color(0xFF0A0E1A);
  static const Color _surface = Color(0xFF141B2D);
  static const Color _primary = Color(0xFF00D4FF);
  static const Color _accent = Color(0xFF7C4DFF);
  static const Color _success = Color(0xFF00E676);
  static const Color _warning = Color(0xFFFFAB00);
  static const Color _error = Color(0xFFFF5252);
  static const Color _textPrimary = Color(0xFFE8EAFF);
  static const Color _textSecondary = Color(0xFF8892B0);

  static Color get background => _bg;
  static Color get surface => _surface;
  static Color get primary => _primary;
  static Color get accent => _accent;
  static Color get success => _success;
  static Color get warning => _warning;
  static Color get error => _error;
  static Color get textPrimary => _textPrimary;
  static Color get textSecondary => _textSecondary;

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _accent,
        surface: _surface,
        error: _error,
        onPrimary: _bg,
        onSecondary: _bg,
        onSurface: _textPrimary,
        onError: _bg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: _primary),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _primary,
        unselectedLabelColor: _textSecondary,
        indicatorColor: _primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: _primary,
        inactiveTrackColor: _surface,
        thumbColor: _primary,
        overlayColor: Color(0x3300D4FF),
      ),
      cardTheme: const CardThemeData(
        color: _surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF1E2A45), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: _textPrimary,
          fontSize: 72,
          fontWeight: FontWeight.w300,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          color: _textPrimary,
          fontSize: 48,
          fontWeight: FontWeight.w300,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          color: _textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: _textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: _textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: _textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: _textSecondary,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2A45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E2A45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        labelStyle: const TextStyle(color: _textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: _bg,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primary,
          side: const BorderSide(color: _primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: _primary),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E2A45),
        thickness: 1,
      ),
    );
  }
}

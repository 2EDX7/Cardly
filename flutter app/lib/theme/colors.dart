import 'package:flutter/material.dart';

class AppColors {
  // primary colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8C86FF);
  static const Color primaryDark = Color(0xFF4A42CC);

  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF8CA3);
  static const Color secondaryDark = Color(0xFFCC4A65);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);

  //  Neutral colors vary by theme
  static const _lightBackground = Color(0xFFF9F9F9);
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightTextPrimary = Color(0xFF222222);
  static const _lightTextSecondary = Color(0xFF666666);

  static const _darkBackground = Color(0xFF121212);
  static const _darkSurface = Color(0xFF1E1E1E);
  static const _darkTextPrimary = Color(0xFFEFEFEF);
  static const _darkTextSecondary = Color(0xFFB0B0B0);

  // Light theme palette
  static const light = _Palette(
    background: _lightBackground,
    surface: _lightSurface,
    textPrimary: _lightTextPrimary,
    textSecondary: _lightTextSecondary,
  );

  // Dark theme palette
  static const dark = _Palette(
    background: _darkBackground,
    surface: _darkSurface,
    textPrimary: _darkTextPrimary,
    textSecondary: _darkTextSecondary,
  );
}

class _Palette {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  const _Palette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });
}

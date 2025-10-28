import 'package:flutter/material.dart';
import 'colors.dart';

/// Central theme configuration for light and dark modes
class AppTheme {
  // 🔹 Light Theme
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextSecondary,
        appBarBgColor: AppColors.primary,
        buttonBgColor: AppColors.primary,
      );

  // 🔹 Dark Theme
  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextSecondary,
        appBarBgColor: AppColors.primaryDark,
        buttonBgColor: AppColors.primaryLight,
      );

  /// Private method to build theme with common configurations
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color onPrimary,
    required Color onSecondary,
    required Color onBackground,
    required Color onSurface,
    required Color appBarBgColor,
    required Color buttonBgColor,
  }) {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        secondary: secondary,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
        error: AppColors.error,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primary),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          side: WidgetStateProperty.all(BorderSide(color: primary, width: 2)),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';
import 'theme_modifier.dart';

/// ---------------------------------------------------------------------------
///  AppTheme
/// ---------------------------------------------------------------------------
/// Centralized definition for the application's design system, providing
/// consistent color, spacing, and typography rules for both light and dark
/// modes.
///
/// Developers should only import this file:
/// ```dart
/// import 'package:your_app/theme/theme.dart';
/// ```
///
/// This ensures all components use the same design tokens internally.
/// ---------------------------------------------------------------------------
class AppTheme {
  /// Light mode configuration
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
        hintColor: AppColors.lightTextTertiary,
        textColor: AppColors.lightTextPrimary,
        borderColor: Colors.grey.shade300,
      );

  /// Dark mode configuration
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
        hintColor: AppColors.darkTextTertiary,
        textColor: AppColors.darkTextPrimary,
        borderColor: Colors.grey.shade700,
      );

  /// -------------------------------------------------------------------------
  ///  Private builder for shared configuration between light and dark themes.
  /// -------------------------------------------------------------------------
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
    required Color hintColor,
    required Color textColor,
    required Color borderColor,
  }) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: background,

      // ---------------------------------------------------------------------
      //  Color Scheme
      // ---------------------------------------------------------------------
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary, // Brand color (used for main buttons, accents)
        secondary: secondary, // Secondary UI highlights
        onPrimary: onPrimary, // Text/icons appearing on primary color
        onSecondary: onSecondary, // Text/icons on secondary color
        error: AppColors.error, // Error or validation feedback
        onError: Colors.white,
        surface: surface, // Cards, sheets, modals, elevated areas
        onSurface: onSurface, // Text/icons on surface containers
        background: background,
        onBackground: onBackground,
      ),

      // ---------------------------------------------------------------------
      //  AppBar Theme
      // ---------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // titleTextStyle: AppTextStyles.heading3(context).copyWith(
        //   color: Colors.white,
        //   fontWeight: FontWeight.w600,
        // ),
      ),

      // ---------------------------------------------------------------------
      //  ElevatedButton Theme (filled primary button)
      // ---------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
        ),
      ),

      // ---------------------------------------------------------------------
      //  OutlinedButton Theme (bordered secondary button)
      // ---------------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primary),
          side: WidgetStateProperty.all(
            BorderSide(color: primary, width: 2),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.lg,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
          ),
        ),
      ),

      // ---------------------------------------------------------------------
      //  InputDecoration Theme (for TextField / TextFormField)
      // ---------------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        // Hint text style - grey/subtle color
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,

        ),
        // Label text style (for floating labels)
        labelStyle: TextStyle(
          color: hintColor,
        ),
        floatingLabelStyle: TextStyle(
          color: primary,
        ),
        // Text style when user types
        // This is controlled globally via TextTheme below
        
        // Border when not focused
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: borderColor),
        ),
        // Border when focused
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        // Border on error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        // Padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        // Fill color (optional - for filled style)
        filled: false,
      ),

      // ---------------------------------------------------------------------
      //  Text Theme - Controls default text colors throughout the app
      // ---------------------------------------------------------------------
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textColor),
        displayMedium: TextStyle(color: textColor),
        displaySmall: TextStyle(color: textColor),
        headlineLarge: TextStyle(color: textColor),
        headlineMedium: TextStyle(color: textColor),
        headlineSmall: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
        titleMedium: TextStyle(color: textColor),
        titleSmall: TextStyle(color: textColor),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        bodySmall: TextStyle(color: textColor.withOpacity(0.7)),
        labelLarge: TextStyle(color: textColor),
        labelMedium: TextStyle(color: textColor),
        labelSmall: TextStyle(color: textColor.withOpacity(0.7)),
      ),

      // ---------------------------------------------------------------------
      //  Icon Theme
      // ---------------------------------------------------------------------
      iconTheme: IconThemeData(
        color: textColor,
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography styles for consistent text styling across the app
class AppTextStyles {
  // 🔹 Headings
  static TextStyle heading1(BuildContext context) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.2,
      );

  static TextStyle heading2(BuildContext context) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.2,
      );

  static TextStyle heading3(BuildContext context) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.3,
      );

  // 🔹 Body Text
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.openSans(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(250),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.openSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
        height: 1.5,
      );

  // 🔹 Button Text
  static TextStyle buttonPrimary(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimary,
        height: 1.2,
      );

  static TextStyle buttonSecondary(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
        height: 1.2,
      );

  // 🔹 Caption & Overline
  static TextStyle caption(BuildContext context) => GoogleFonts.openSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        height: 1.3,
      );

  static TextStyle linkText(BuildContext context) => GoogleFonts.openSans(
        fontSize: 12,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
        height: 1.3,
      );

  static TextStyle overline(BuildContext context) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        letterSpacing: 1.5,
        height: 1.3,
      );
}
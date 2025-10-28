import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onBackground,
      );

  static TextStyle heading2(BuildContext context) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onBackground,
      );

  static TextStyle heading3(BuildContext context) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onBackground,
      );

  static TextStyle buttonPrimary(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimary,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.openSans(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.9),
      );

  static TextStyle caption(BuildContext context) => GoogleFonts.openSans(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      );
}

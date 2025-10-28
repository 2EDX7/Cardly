import 'package:flutter/material.dart';

/// Centralized spacing/padding/margin constants for consistent layout
class AppSpacing {
  // 🔹 Extra Small
  static const double xs = 4.0;

  // 🔹 Small
  static const double sm = 8.0;

  // 🔹 Medium
  static const double md = 16.0;

  // 🔹 Large
  static const double lg = 24.0;

  // 🔹 Extra Large
  static const double xl = 32.0;

  // 🔹 XXL (for hero sections)
  static const double xxl = 48.0;

  // 🔹 Common EdgeInsets Presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // 🔹 Horizontal/Vertical Presets
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);

  // 🔹 Asymmetric Presets
  static const EdgeInsets paddingTopLg = EdgeInsets.only(top: lg);
  static const EdgeInsets paddingBottomLg = EdgeInsets.only(bottom: lg);
  static const EdgeInsets paddingLeftMd = EdgeInsets.only(left: md);
  static const EdgeInsets paddingRightMd = EdgeInsets.only(right: md);
}
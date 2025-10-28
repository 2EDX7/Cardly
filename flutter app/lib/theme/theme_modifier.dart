import 'package:flutter/material.dart';

/// ChangeNotifier for managing theme state (Light/Dark mode toggle)
class ThemeModifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Set theme to light mode
  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  /// Set theme to dark mode
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  /// Set theme based on system preference
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
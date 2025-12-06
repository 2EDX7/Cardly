import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/database_helper.dart';
import 'theme_state.dart';

/// Cubit for managing app theme with database persistence
class ThemeCubit extends Cubit<ThemeState> {
  final DatabaseHelper _dbHelper;
  String? _userId;

  ThemeCubit({required DatabaseHelper dbHelper, String? userId})
      : _dbHelper = dbHelper,
        _userId = userId,
        super(const ThemeState(themeMode: ThemeMode.system));

  /// Set user and load their theme preference from database
  Future<void> setUser(String? userId, {ThemeMode? initialTheme}) async {
    _userId = userId;
    if (initialTheme != null) {
      emit(state.copyWith(themeMode: initialTheme));
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set specific theme mode and persist to database
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _saveThemeToDatabase(mode);
  }

  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Reset to default theme (system) for guest/logged-out state
  void resetToDefault() {
    _userId = null;
    emit(const ThemeState(themeMode: ThemeMode.system));
  }

  /// Save theme preference to database
  Future<void> _saveThemeToDatabase(ThemeMode mode) async {
    if (_userId != null) {
      try {
        await _dbHelper.updateUserPreferences(
          userId: _userId!,
          themeMode: _themeModeToString(mode),
        );
      } catch (e) {
        // Handle error silently - theme still works in memory
      }
    }
  }

  /// Convert ThemeMode to string for database storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string from database to ThemeMode
  static ThemeMode themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/repositories/user_repository.dart';
import 'theme_state.dart';

/// Cubit for managing app theme with database persistence
/// Cubit for managing app theme with database persistence
class ThemeCubit extends Cubit<ThemeState> {
  final DatabaseHelper _dbHelper; // Keep for local backup/offline
  final UserRepository? _userRepository; // Add user repository
  String? _userId;

  ThemeCubit({
    required DatabaseHelper dbHelper, 
    UserRepository? userRepository,
    String? userId,
  }) : _dbHelper = dbHelper,
       _userRepository = userRepository,
       _userId = userId,
       super(const ThemeState(themeMode: ThemeMode.system));

  /// Set user and load their theme preference
  Future<void> setUser(String? userId, {ThemeMode? initialTheme}) async {
    _userId = userId;
    if (initialTheme != null) {
      // Prioritize the theme coming from the user profile we just loaded
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

  /// Set specific theme mode and persist
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _saveThemePreference(mode);
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

  /// Save theme preference to database and backend
  Future<void> _saveThemePreference(ThemeMode mode) async {
    if (_userId != null) {
      final modeStr = _themeModeToString(mode);
      
      // Save locally
      try {
        await _dbHelper.updateUserPreferences(
          userId: _userId!,
          themeMode: modeStr,
        );
      } catch (e) {
        // Handle error silently
      }

      // Save to backend
      if (_userRepository != null) {
        try {
          await _userRepository!.updatePreferences(themeMode: modeStr);
        } catch (e) {
          debugPrint('Failed to sync theme to backend: $e');
        }
      }
    }
  }

  /// Convert ThemeMode to string for storage
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

  /// Convert string from storage to ThemeMode
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

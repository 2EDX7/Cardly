import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'theme_state.dart';

/// Cubit for managing app theme with persistence
class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  /// Toggle between light and dark theme
  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    emit(state.copyWith(themeMode: newMode));
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    emit(state.copyWith(themeMode: mode));
  }

  /// Set light theme
  void setLightTheme() {
    emit(state.copyWith(themeMode: ThemeMode.light));
  }

  /// Set dark theme
  void setDarkTheme() {
    emit(state.copyWith(themeMode: ThemeMode.dark));
  }

  /// Set system theme
  void setSystemTheme() {
    emit(state.copyWith(themeMode: ThemeMode.system));
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      final themeModeIndex = json['themeMode'] as int?;
      final themeMode = themeModeIndex != null 
          ? ThemeMode.values[themeModeIndex]
          : ThemeMode.system;
      return ThemeState(themeMode: themeMode);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return {
      'themeMode': state.themeMode.index,
    };
  }
}

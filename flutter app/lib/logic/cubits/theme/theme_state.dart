import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State for theme management
class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({this.themeMode = ThemeMode.system});

  @override
  List<Object?> get props => [themeMode];

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

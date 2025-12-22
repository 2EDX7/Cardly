import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/database_helper.dart';
import '../../../data/repositories/user_repository.dart';
import 'language_state.dart';

/// Cubit for managing app language with database persistence
/// Cubit for managing app language with database persistence
class LanguageCubit extends Cubit<LanguageState> {
  final DatabaseHelper _dbHelper;
  final UserRepository? _userRepository; // Add user repository
  String? _userId;

  LanguageCubit({
    required DatabaseHelper dbHelper, 
    UserRepository? userRepository,
    String? userId,
  }) : _dbHelper = dbHelper,
       _userRepository = userRepository,
       _userId = userId,
       super(const LanguageState(locale: Locale('en')));

  /// Set user and load their language preference
  Future<void> setUser(String? userId, {Locale? initialLocale}) async {
    _userId = userId;
    if (initialLocale != null) {
      emit(state.copyWith(locale: initialLocale));
    }
  }

  /// Change the app language and persist
  Future<void> changeLanguage(Locale locale) async {
    emit(state.copyWith(locale: locale));
    await _saveLanguagePreference(locale);
  }

  /// Set language to English
  Future<void> setEnglish() => changeLanguage(const Locale('en'));

  /// Set language to French
  Future<void> setFrench() => changeLanguage(const Locale('fr'));

  /// Set language to Arabic
  Future<void> setArabic() => changeLanguage(const Locale('ar'));

  /// Reset to default language (English) for guest/logged-out state
  void resetToDefault() {
    _userId = null;
    emit(const LanguageState(locale: Locale('en')));
  }

  /// Save language preference to database and backend
  Future<void> _saveLanguagePreference(Locale locale) async {
    if (_userId != null) {
      // Save locally
      try {
        await _dbHelper.updateUserPreferences(
          userId: _userId!,
          language: locale.languageCode,
        );
      } catch (e) {
        // Handle error silently
      }

      // Save to backend
      if (_userRepository != null) {
        try {
          await _userRepository!.updatePreferences(language: locale.languageCode);
        } catch (e) {
          debugPrint('Failed to sync language to backend: $e');
        }
      }
    }
  }

  /// Convert string from database to Locale
  static Locale localeFromString(String? value) {
    switch (value) {
      case 'ar':
        return const Locale('ar');
      case 'fr':
        return const Locale('fr');
      case 'en':
      default:
        return const Locale('en');
    }
  }
}

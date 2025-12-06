import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/database_helper.dart';
import 'language_state.dart';

/// Cubit for managing app language with database persistence
class LanguageCubit extends Cubit<LanguageState> {
  final DatabaseHelper _dbHelper;
  String? _userId;

  LanguageCubit({required DatabaseHelper dbHelper, String? userId})
      : _dbHelper = dbHelper,
        _userId = userId,
        super(const LanguageState(locale: Locale('en')));

  /// Set user and load their language preference from database
  Future<void> setUser(String? userId, {Locale? initialLocale}) async {
    _userId = userId;
    if (initialLocale != null) {
      emit(state.copyWith(locale: initialLocale));
    }
  }

  /// Change the app language and persist to database
  Future<void> changeLanguage(Locale locale) async {
    emit(state.copyWith(locale: locale));
    await _saveLanguageToDatabase(locale);
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

  /// Save language preference to database
  Future<void> _saveLanguageToDatabase(Locale locale) async {
    if (_userId != null) {
      try {
        await _dbHelper.updateUserPreferences(
          userId: _userId!,
          language: locale.languageCode,
        );
      } catch (e) {
        // Handle error silently - language still works in memory
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

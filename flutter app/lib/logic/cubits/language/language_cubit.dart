import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'language_state.dart';

/// Cubit for managing app language with persistence
class LanguageCubit extends HydratedCubit<LanguageState> {
  LanguageCubit() : super(const LanguageState());

  /// Change the app language
  void changeLanguage(Locale locale) {
    emit(state.copyWith(locale: locale));
  }

  /// Set language to English
  void setEnglish() => changeLanguage(const Locale('en'));

  /// Set language to French
  void setFrench() => changeLanguage(const Locale('fr'));

  /// Set language to Arabic
  void setArabic() => changeLanguage(const Locale('ar'));

  @override
  LanguageState? fromJson(Map<String, dynamic> json) {
    try {
      return LanguageState(
        locale: Locale(json['languageCode'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(LanguageState state) {
    return {
      'languageCode': state.locale.languageCode,
    };
  }
}

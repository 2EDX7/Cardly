import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      throw FlutterError(
        'AppLocalizations not found in widget tree. '
        'Make sure MaterialApp has localizationsDelegates configured.'
      );
    }
    return localizations;
  }
}
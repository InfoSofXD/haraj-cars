// app_localizations.dart

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(context.locale);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    try {
      return key.tr();
    } catch (e) {
      print(
          '⚠️ Translation key not found: "$key" for locale: ${locale.languageCode}');
      return key;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Return AppLocalizations with the current locale
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension
extension TranslateX on BuildContext {
  String tr(String key) {
    try {
      return key.tr();
    } catch (e) {
      print('⚠️ Translation key not found: "$key"');
      return key;
    }
  }
}

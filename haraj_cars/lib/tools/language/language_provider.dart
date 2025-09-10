import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', '');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  void setLanguage(String languageCode) {
    switch (languageCode) {
      case 'العربيه':
        setLocale(const Locale('ar', ''));
        break;
      case 'English':
        setLocale(const Locale('en', ''));
        break;
      default:
        setLocale(const Locale('ar', ''));
    }
  }
}

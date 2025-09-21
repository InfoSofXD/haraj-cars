import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._internal();

  static final ThemeController instance = ThemeController._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('theme_mode')) {
      final bool? isDark = prefs.getBool('theme_mode');
      _themeMode = isDark == null
          ? ThemeMode.system
          : (isDark ? ThemeMode.dark : ThemeMode.light);
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeBool(bool? isDark) async {
    // Map bool? to ThemeMode
    if (isDark == null) {
      _themeMode = ThemeMode.system;
    } else if (isDark) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    final prefs = await SharedPreferences.getInstance();
    if (isDark == null) {
      await prefs.remove('theme_mode');
    } else {
      await prefs.setBool('theme_mode', isDark);
    }

    notifyListeners();
  }
}

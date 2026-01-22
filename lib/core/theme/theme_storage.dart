import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  ThemeStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'theme_mode'; // 0=system,1=light,2=dark

  ThemeMode read() {
    final v = _prefs.getInt(_key) ?? 0;
    switch (v) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> write(ThemeMode mode) async {
    final v = switch (mode) {
      ThemeMode.system => 0,
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
    };
    await _prefs.setInt(_key, v);
  }
}

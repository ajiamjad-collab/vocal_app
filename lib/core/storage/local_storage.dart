import 'package:shared_preferences/shared_preferences.dart';
import 'storage_keys.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  LocalStorage(this._prefs);

  // Sync getters (UI)
  bool get rememberMe => _prefs.getBool(StorageKeys.rememberMe) ?? false;
  String get rememberedEmail => _prefs.getString(StorageKeys.rememberedEmail) ?? '';

  // Async getters (Bloc/Services)
  Future<bool> getRememberMe() async => _prefs.getBool(StorageKeys.rememberMe) ?? false;
  Future<String> getRememberedEmail() async => _prefs.getString(StorageKeys.rememberedEmail) ?? '';

  Future<void> setRememberMe(bool value) async {
    await _prefs.setBool(StorageKeys.rememberMe, value);
  }

  Future<void> setRememberedEmail(String email) async {
    await _prefs.setString(StorageKeys.rememberedEmail, email);
  }

  Future<void> clearRememberedEmail() async {
    await _prefs.remove(StorageKeys.rememberedEmail);
  }
}

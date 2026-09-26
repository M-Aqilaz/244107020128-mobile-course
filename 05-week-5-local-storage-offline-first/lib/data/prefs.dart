import 'package:shared_preferences/shared_preferences.dart';

class PrefsRepository {
  static const _darkModeKey = 'dark_mode';
  static const _lastOpenedKey = 'last_opened_at';
  static const _forceOfflineKey = 'force_offline';

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  Future<void> markOpenedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastOpenedKey, DateTime.now().toIso8601String());
  }

  Future<String?> getLastOpened() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastOpenedKey);
  }

  Future<bool> getForceOffline() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_forceOfflineKey) ?? false;
  }

  Future<void> setForceOffline(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_forceOfflineKey, value);
  }
}

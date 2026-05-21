import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsStorage {
  PrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  static const themeModeKey = 'theme_mode';
  static const localeKey = 'locale';
  static const rememberMeKey = 'remember_me';
  static const odooUrlKey = 'odoo_url';
  static const odooDbKey = 'odoo_db';
  static const odooLoginKey = 'odoo_login';

  String? getString(String key) => _prefs.getString(key);
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final prefsStorageProvider = FutureProvider<PrefsStorage>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return PrefsStorage(prefs);
});

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for the app's persisted user
/// preferences: theme mode, preferred language, and notification opt-in.
/// All three are read back on next launch (SettingsController does this).
class SharedPrefsService {
  SharedPrefsService(this._prefs);

  final SharedPreferences _prefs;

  static const _themeModeKey = 'pref_theme_mode';
  static const _languageKey = 'pref_language';
  static const _notificationsEnabledKey = 'pref_notifications_enabled';

  /// 'system' | 'light' | 'dark'
  String get themeMode => _prefs.getString(_themeModeKey) ?? 'system';
  Future<void> setThemeMode(String value) =>
      _prefs.setString(_themeModeKey, value);

  /// 'en' | 'so' (English / Somali) — reflects the multilingual need
  /// surfaced repeatedly in the project's user research.
  String get language => _prefs.getString(_languageKey) ?? 'en';
  Future<void> setLanguage(String value) =>
      _prefs.setString(_languageKey, value);

  bool get notificationsEnabled =>
      _prefs.getBool(_notificationsEnabledKey) ?? true;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_notificationsEnabledKey, value);
}
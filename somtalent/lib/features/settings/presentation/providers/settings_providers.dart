import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/shared_prefs_service.dart';

/// Overridden in `main.dart` with the real instance once
/// `SharedPreferences.getInstance()` resolves, before `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  return SharedPrefsService(ref.watch(sharedPreferencesProvider));
});

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.language,
    required this.notificationsEnabled,
  });

  final ThemeMode themeMode;
  final String language;
  final bool notificationsEnabled;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

/// The app's three persisted preferences (theme, language, notifications),
/// all restored from [SharedPrefsService] on launch.
class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final service = ref.watch(sharedPrefsServiceProvider);
    return SettingsState(
      themeMode: _themeModeFromString(service.themeMode),
      language: service.language,
      notificationsEnabled: service.notificationsEnabled,
    );
  }

  ThemeMode _themeModeFromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await ref.read(sharedPrefsServiceProvider).setThemeMode(mode.name);
  }

  Future<void> setLanguage(String language) async {
    state = state.copyWith(language: language);
    await ref.read(sharedPrefsServiceProvider).setLanguage(language);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await ref.read(sharedPrefsServiceProvider).setNotificationsEnabled(enabled);
  }
}
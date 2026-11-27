import 'package:flutter/material.dart';
import 'package:ludo_unbiased/features/settings/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes [AppSettings] in [SharedPreferences]. Missing or
/// unknown values fall back to the defaults, so a bad value never blocks
/// the app from starting.
class SettingsRepository {
  /// Creates a repository over `prefs`.
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _theme = 'settings.themeMode';
  static const _language = 'settings.language';
  static const _sound = 'settings.sound';
  static const _music = 'settings.music';
  static const _vibration = 'settings.vibration';

  /// The stored settings, or defaults.
  AppSettings load() {
    const d = AppSettings();
    final theme = ThemeMode.values.asNameMap()[_prefs.getString(_theme)];
    final lang = _prefs.getString(_language);
    return AppSettings(
      themeMode: theme ?? d.themeMode,
      languageCode: supportedLanguageCodes.contains(lang)
          ? lang!
          : d.languageCode,
      sound: _prefs.getBool(_sound) ?? d.sound,
      music: _prefs.getBool(_music) ?? d.music,
      vibration: _prefs.getBool(_vibration) ?? d.vibration,
    );
  }

  /// Stores [s].
  Future<void> save(AppSettings s) async {
    await Future.wait([
      _prefs.setString(_theme, s.themeMode.name),
      _prefs.setString(_language, s.languageCode),
      _prefs.setBool(_sound, s.sound),
      _prefs.setBool(_music, s.music),
      _prefs.setBool(_vibration, s.vibration),
    ]);
  }
}

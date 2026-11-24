import 'package:flutter/material.dart';

/// The languages the app ships, in picker order. English is the default.
const supportedLanguageCodes = ['en', 'hi', 'es', 'fr', 'pt'];

/// The player's preferences (ARCHITECTURE.md §11).
@immutable
class AppSettings {
  /// Creates settings; the defaults are a fresh install's.
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.sound = true,
    this.music = true,
    this.vibration = true,
  });

  /// System, light or dark.
  final ThemeMode themeMode;

  /// One of [supportedLanguageCodes].
  final String languageCode;

  /// Sound effects on.
  final bool sound;

  /// Background music on.
  final bool music;

  /// Haptic feedback on.
  final bool vibration;

  /// The app locale.
  Locale get locale => Locale(languageCode);

  /// A copy with the given fields replaced.
  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? sound,
    bool? music,
    bool? vibration,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    languageCode: languageCode ?? this.languageCode,
    sound: sound ?? this.sound,
    music: music ?? this.music,
    vibration: vibration ?? this.vibration,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.languageCode == languageCode &&
      other.sound == sound &&
      other.music == music &&
      other.vibration == vibration;

  @override
  int get hashCode =>
      Object.hash(themeMode, languageCode, sound, music, vibration);
}

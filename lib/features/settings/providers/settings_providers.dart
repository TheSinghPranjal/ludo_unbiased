import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/game/services/haptics_service.dart';
import 'package:ludo_unbiased/features/settings/data/settings_repository.dart';
import 'package:ludo_unbiased/features/settings/models/app_settings.dart';

/// Where settings are stored.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
);

/// The player's preferences. Every change is saved at once.
final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Changes and persists [AppSettings].
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(settingsRepositoryProvider).load();

  void _set(AppSettings next) {
    if (next == state) return;
    state = next;
    unawaited(ref.read(settingsRepositoryProvider).save(next));
  }

  /// System, light or dark.
  void setThemeMode(ThemeMode mode) => _set(state.copyWith(themeMode: mode));

  /// App language; one of [supportedLanguageCodes].
  void setLanguage(String code) {
    assert(supportedLanguageCodes.contains(code), 'unsupported: $code');
    _set(state.copyWith(languageCode: code));
  }

  /// Sound effects on or off.
  void setSound({required bool on}) => _set(state.copyWith(sound: on));

  /// Music on or off.
  void setMusic({required bool on}) => _set(state.copyWith(music: on));

  /// Vibration on or off.
  void setVibration({required bool on}) => _set(state.copyWith(vibration: on));
}

/// Plays audio files; tests override it with a [SilentAudioBackend].
final audioBackendProvider = Provider<AudioBackend>((ref) {
  final b = FlameAudioBackend();
  ref.onDispose(() => unawaited(b.dispose()));
  return b;
});

/// Sound effects and music, kept in step with the settings.
final audioServiceProvider = Provider<AudioService>((ref) {
  final audio = AudioService(ref.watch(audioBackendProvider));
  void apply(AppSettings s) => audio.configure(sound: s.sound, music: s.music);
  ref.listen(settingsProvider, (_, next) => apply(next));
  apply(ref.read(settingsProvider));
  return audio;
});

/// Haptic feedback, enabled by the Vibration setting.
final hapticsProvider = Provider<HapticsService>(
  (ref) => HapticsService(
    enabled: ref.watch(settingsProvider.select((s) => s.vibration)),
  ),
);

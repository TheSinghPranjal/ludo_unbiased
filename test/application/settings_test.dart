import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/settings/data/settings_repository.dart';
import 'package:ludo_unbiased/features/settings/models/app_settings.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(ProviderContainer, SilentAudioBackend)> makeContainer([
  Map<String, Object> prefs = const {},
]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final audio = SilentAudioBackend();
  final c = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      audioBackendProvider.overrideWithValue(audio),
    ],
  );
  addTearDown(c.dispose);
  return (c, audio);
}

void main() {
  test('a fresh install defaults to English, system theme, all on', () async {
    final (c, _) = await makeContainer();
    final s = c.read(settingsProvider);
    expect(s.languageCode, 'en');
    expect(s.themeMode, ThemeMode.system);
    expect(s.sound && s.music && s.vibration, isTrue);
  });

  test('changes persist across restarts', () async {
    final (c, _) = await makeContainer();
    c.read(settingsProvider.notifier)
      ..setLanguage('hi')
      ..setThemeMode(ThemeMode.dark)
      ..setSound(on: false)
      ..setMusic(on: false)
      ..setVibration(on: false);
    await Future<void>.delayed(Duration.zero);
    final sp = await SharedPreferences.getInstance();
    expect(
      SettingsRepository(sp).load(),
      const AppSettings(
        languageCode: 'hi',
        themeMode: ThemeMode.dark,
        sound: false,
        music: false,
        vibration: false,
      ),
    );
  });

  test('unknown stored values fall back to defaults', () async {
    final (c, _) = await makeContainer({
      'settings.language': 'xx',
      'settings.themeMode': 'neon',
    });
    final s = c.read(settingsProvider);
    expect(s.languageCode, 'en');
    expect(s.themeMode, ThemeMode.system);
  });

  test('Sound off mutes effects; Music toggles the loop', () async {
    final (c, backend) = await makeContainer();
    final audio = c.read(audioServiceProvider);
    expect(backend.music, isNotNull);

    audio.play(Sfx.capture);
    await Future<void>.delayed(Duration.zero);
    expect(backend.played, hasLength(1));

    c.read(settingsProvider.notifier).setSound(on: false);
    audio.play(Sfx.capture);
    await Future<void>.delayed(Duration.zero);
    expect(backend.played, hasLength(1));

    c.read(settingsProvider.notifier).setMusic(on: false);
    await Future<void>.delayed(Duration.zero);
    expect(backend.music, isNull);
  });

  test('iOS uses M4A and Android uses OGG', () async {
    final ios = SilentAudioBackend();
    AudioService(ios, platform: TargetPlatform.iOS)
      ..configure(sound: true, music: false)
      ..play(Sfx.step);
    final android = SilentAudioBackend();
    AudioService(android, platform: TargetPlatform.android)
      ..configure(sound: true, music: false)
      ..play(Sfx.step);
    await Future<void>.delayed(Duration.zero);
    expect(ios.played, ['step.m4a']);
    expect(android.played, ['step.ogg']);
  });
}

import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Every sound effect the game plays, with its volume.
enum Sfx {
  /// Dice starts tumbling.
  diceRoll('dice_roll', .8),

  /// Dice lands.
  diceLand('dice_land', .8),

  /// One token hop.
  step('step', .55),

  /// A token is captured.
  capture('capture', 1),

  /// A token reaches HOME.
  home('home', .9),

  /// An extra roll is earned.
  extraRoll('extra_roll', .8),

  /// A token leaves base.
  leaveBase('leave_base', .9),

  /// The game is won.
  win('win', 1),

  /// The last seconds of a turn.
  timerTick('timer_tick', .6),

  /// A button press.
  uiTap('ui_tap', .5)
  ;

  const Sfx(this.file, this.volume);

  /// File name without the extension.
  final String file;

  /// Playback volume, 0–1.
  final double volume;
}

/// Plays audio files. [AudioService] decides what plays; this does the I/O.
/// Tests use a fake.
abstract interface class AudioBackend {
  /// Loads [files] so the first play has no delay.
  Future<void> preload(List<String> files);

  /// Plays [file] once.
  Future<void> play(String file, double volume);

  /// Loops [file] as music.
  Future<void> startMusic(String file, double volume);

  /// Stops the music.
  Future<void> stopMusic();

  /// Releases every player.
  Future<void> dispose();
}

/// The sound effects and music, gated by the player's settings.
///
/// Calls never throw: a missing audio device must not break the game.
class AudioService {
  /// Creates the service over `backend`.
  AudioService(this._backend, {TargetPlatform? platform})
    : _ext = switch (platform ?? defaultTargetPlatform) {
        // iOS and macOS cannot decode OGG. Android loops OGG gaplessly,
        // which AAC's encoder padding prevents (AUDIT.md §7.5).
        TargetPlatform.iOS || TargetPlatform.macOS => 'm4a',
        _ => 'ogg',
      };

  final AudioBackend _backend;
  final String _ext;
  bool _sound = false;
  bool _music = false;
  bool _preloaded = false;

  static const _musicFile = 'music_loop';
  static const _musicVolume = .35;

  /// True when sound effects play.
  bool get soundOn => _sound;

  /// True when music plays.
  bool get musicOn => _music;

  String _path(String name) => '$name.$_ext';

  /// Applies the settings: starts or stops music, mutes or unmutes effects.
  void configure({required bool sound, required bool music}) {
    _sound = sound;
    if (sound && !_preloaded) {
      _preloaded = true;
      _guard(_backend.preload([for (final s in Sfx.values) _path(s.file)]));
    }
    if (music == _music) return;
    _music = music;
    _guard(
      music
          ? _backend.startMusic(_path(_musicFile), _musicVolume)
          : _backend.stopMusic(),
    );
  }

  /// Plays [sfx] unless sound effects are off.
  void play(Sfx sfx) {
    if (!_sound) return;
    _guard(_backend.play(_path(sfx.file), sfx.volume));
  }

  /// Releases the players.
  Future<void> dispose() => _backend.dispose().catchError((_) {});

  void _guard(Future<void> f) => unawaited(
    f.catchError((Object e) {
      debugPrint('Audio unavailable: $e');
    }),
  );
}

/// [AudioBackend] on `flame_audio`: a small pool per effect, so rapid
/// repeats (token hops) never wait on a player, and `Bgm` for music, which
/// pauses itself while the app is in the background.
class FlameAudioBackend implements AudioBackend {
  final Map<String, Future<AudioPool>> _pools = {};
  bool _bgmReady = false;

  Future<AudioPool> _pool(String file) => _pools.putIfAbsent(
    file,
    () => FlameAudio.createPool(file, maxPlayers: 4),
  );

  @override
  Future<void> preload(List<String> files) async {
    await Future.wait(files.map(_pool));
  }

  @override
  Future<void> play(String file, double volume) async {
    final pool = await _pool(file);
    await pool.start(volume: volume);
  }

  @override
  Future<void> startMusic(String file, double volume) async {
    if (!_bgmReady) {
      _bgmReady = true;
      await FlameAudio.bgm.initialize();
    }
    await FlameAudio.bgm.play(file, volume: volume);
  }

  @override
  Future<void> stopMusic() => FlameAudio.bgm.stop();

  @override
  Future<void> dispose() async {
    final pools = await Future.wait(_pools.values);
    _pools.clear();
    await Future.wait([
      for (final p in pools) p.dispose(),
      FlameAudio.bgm.dispose(),
    ]);
  }
}

/// [AudioBackend] that plays nothing; for tests and headless runs.
class SilentAudioBackend implements AudioBackend {
  /// Every file passed to [play], in order.
  final List<String> played = [];

  /// The music file playing, or null.
  String? music;

  @override
  Future<void> preload(List<String> files) async {}

  @override
  Future<void> play(String file, double volume) async => played.add(file);

  @override
  Future<void> startMusic(String file, double volume) async => music = file;

  @override
  Future<void> stopMusic() async => music = null;

  @override
  Future<void> dispose() async {}
}

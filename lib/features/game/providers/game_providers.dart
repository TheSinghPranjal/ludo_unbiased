import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_unbiased/features/game/controllers/game_controller.dart';
import 'package:ludo_unbiased/features/game/controllers/local_game_controller.dart';
import 'package:ludo_unbiased/features/game/data/saved_game_repository.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app's [SharedPreferences], loaded in `main` and supplied with
/// `ProviderScope(overrides: [...])`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  ),
);

/// Where the local game is saved.
final savedGameRepositoryProvider = Provider<SavedGameRepository>(
  (ref) => SavedGameRepository(ref.watch(sharedPreferencesProvider)),
);

/// Dice for games this device runs. Tests override it with scripted dice.
final diceServiceProvider = Provider<DiceService>(
  (ref) => SecureDiceService(),
);

/// The game currently on screen, if any.
final activeGameProvider = NotifierProvider<ActiveGame, GameController?>(
  ActiveGame.new,
);

/// Starts, resumes and ends the game on screen.
class ActiveGame extends Notifier<GameController?> {
  GameController? _current;

  @override
  GameController? build() {
    ref.onDispose(() => unawaited(_current?.dispose()));
    return null;
  }

  /// Starts a new local game for [seats].
  void startLocal(List<SeatConfig> seats) {
    end();
    final c = LocalGameController.newGame(
      seats,
      saves: ref.read(savedGameRepositoryProvider),
      dice: ref.read(diceServiceProvider),
    )..start();
    _current = c;
    state = c;
  }

  /// Continues the saved local game. Returns false when there is none.
  bool resumeSaved() {
    final repo = ref.read(savedGameRepositoryProvider);
    final saved = repo.load();
    if (saved == null) return false;
    end();
    final c = LocalGameController.resume(
      saved,
      saves: repo,
      dice: ref.read(diceServiceProvider),
    )..start(remaining: saved.remaining);
    _current = c;
    state = c;
    return true;
  }

  /// Stops and releases the current game.
  void end() {
    final c = _current;
    _current = null;
    state = null;
    unawaited(c?.dispose());
  }
}

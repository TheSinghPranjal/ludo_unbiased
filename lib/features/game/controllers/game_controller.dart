import 'package:flutter/foundation.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/animation_gate.dart';

/// What the Game screen talks to, whatever runs the game: this device
/// (local or host) or a remote host (client).
abstract interface class GameController {
  /// The latest state.
  ValueListenable<GameState> get state;

  /// Turn time left in milliseconds.
  ValueListenable<int> get remainingMs;

  /// Each batch of events, in order, for animation, sound and the status line.
  Stream<List<GameEvent>> get events;

  /// Colours this device may act for.
  Set<PlayerColor> get controlledColors;

  /// True when the Pause menu stops the clock (local games only).
  bool get canPause;

  /// Asks to roll for the current player. Returns a rule error, or null.
  Future<RuleError?> requestRoll();

  /// Asks to move [tokenId] for the current player.
  Future<RuleError?> requestMove(int tokenId);

  /// Installs the board's animation gate, or a timed one when hidden.
  void bindAnimationGate(AnimationGate gate);

  /// Pauses the game (local only; a no-op online).
  void pause();

  /// Resumes after [pause].
  void resume();

  /// Releases timers and connections.
  Future<void> dispose();
}

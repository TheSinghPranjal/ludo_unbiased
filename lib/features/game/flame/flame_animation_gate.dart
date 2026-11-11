import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/core/utils/clock.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/services/animation_gate.dart';

/// The animation gate while the board is on screen: a batch is done when
/// the dice has landed and the board has played every event.
class FlameAnimationGate implements AnimationGate {
  /// Creates a gate for [game]. [diceLanded] waits for the dice widget; by
  /// default the fixed 800 ms.
  FlameAnimationGate(
    this.game, {
    this.diceLanded,
    this.clock = const GameClock(),
  });

  /// The board.
  final LudoGame game;

  /// Completes when the dice widget finishes its tumble.
  final Future<void> Function()? diceLanded;

  /// Time source for the default dice wait.
  final GameClock clock;

  @override
  Future<void> played(List<GameEvent> events) async {
    final rolled = events.any((e) => e is DiceRolled);
    await Future.wait([
      if (rolled) diceLanded?.call() ?? clock.delay(Timing.diceAnimation),
      game.animations.play(events),
    ]);
  }
}

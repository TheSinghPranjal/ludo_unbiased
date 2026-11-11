import 'package:ludo_unbiased/core/utils/result.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

const PlayerColor red = PlayerColor.red;
const PlayerColor blue = PlayerColor.blue;
const PlayerColor yellow = PlayerColor.yellow;
const PlayerColor green = PlayerColor.green;

/// The player id used for [c] in tests.
String pid(PlayerColor c) => 'p-${c.name}';

/// A new game with human seats for [colors].
GameState newGame([List<PlayerColor> colors = PlayerColor.values]) =>
    GameEngine.newGame(
      gameId: 'test',
      players: [
        for (final c in colors)
          Player(id: pid(c), color: c, name: c.name, kind: PlayerKind.human),
      ],
    );

/// [s] with tokens moved to the given relative steps.
GameState place(GameState s, Map<(PlayerColor, int), int> rels) => s.copyWith(
  tokens: [
    for (final t in s.tokens) t.copyWith(rel: rels[(t.color, t.id)] ?? t.rel),
  ],
);

/// [s] waiting for [c] to roll.
GameState turnOf(GameState s, PlayerColor c) =>
    s.copyWith(currentColor: c, phase: GamePhase.awaitingRoll, dice: null);

/// [s] with [c] having rolled [dice], waiting for a move.
GameState rolled(GameState s, PlayerColor c, int dice) =>
    s.copyWith(currentColor: c, phase: GamePhase.rolled, dice: dice);

/// Rolls [value] for the current player and settles; fails on rejection.
Commit rollOk(GameState s, int value) {
  final r = GameEngine.roll(
    s,
    pid(s.currentColor),
    ScriptedDiceService([value]),
  );
  final (next, events) = r.value;
  return (GameEngine.settle(next), events);
}

/// Moves [tokenId] for the current player and settles; fails on rejection.
Commit moveOk(GameState s, int tokenId) {
  final (next, events) = GameEngine.move(s, pid(s.currentColor), tokenId).value;
  return (GameEngine.settle(next), events);
}

/// The rule error of [r], or null when it succeeded.
RuleError? errorOf(Result<Commit, RuleError> r) => r.isOk ? null : r.error;

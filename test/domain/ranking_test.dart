import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/rank_rules.dart';

import '../helpers/game_builders.dart';

/// [s] with three of [c]'s tokens home and the fourth at [lastRel].
GameState almostDone(GameState s, PlayerColor c, int lastRel) =>
    place(s, {(c, 0): 56, (c, 1): 56, (c, 2): 56, (c, 3): lastRel});

/// [c] (current) rolls 3 from 53 and finishes.
GameState finish(GameState s, PlayerColor c) {
  final (next, _) = moveOk(rolled(almostDone(s, c, 53), c, 3), 3);
  return next;
}

void main() {
  test('four tokens home finishes the player; the game continues', () {
    final s = rolled(almostDone(newGame(), red, 53), red, 3);
    final (next, events) = moveOk(s, 3);
    final done = events.whereType<PlayerFinished>().single;
    expect(done.rank, 1);
    expect(next.playerOf(red)!.finishedRank, 1);
    expect(events.whereType<ExtraRoll>(), isEmpty);
    expect(next.currentColor, blue);
    expect(next.phase, GamePhase.awaitingRoll);
    expect(next.activeColors, [blue, yellow, green]);
  });

  test('ranks 1–4 follow finishing order; the last player is ranked 4th', () {
    var s = newGame();
    s = finish(s, red);
    s = finish(turnOf(s, yellow), yellow);
    expect(s.isOver, isFalse);
    final (end, events) = moveOk(
      rolled(almostDone(s, blue, 53), blue, 3),
      3,
    );
    expect(end.phase, GamePhase.gameOver);
    expect(events.whereType<GameOver>().single.ranking, [
      red,
      yellow,
      blue,
      green,
    ]);
    expect(end.playerOf(green)!.finishedRank, 4);
  });

  test('a removed current player passes the turn and leaves the board', () {
    final s = place(newGame(), {(red, 0): 10});
    final (next, events) = GameEngine.removePlayer(s, pid(red)).value;
    expect(next.currentColor, blue);
    expect(next.tokensOf(red), isEmpty);
    expect(next.leavers, [red]);
    expect(next.turnSeq, s.turnSeq + 1);
    expect(
      events.whereType<TurnPassed>().single.reason,
      TurnPassReason.playerRemoved,
    );
    expect(next.activeColors, [blue, yellow, green]);
  });

  test('leavers rank below finishers; a later leaver ranks higher', () {
    var s = newGame();
    (s, _) = GameEngine.removePlayer(s, pid(yellow)).value;
    (s, _) = GameEngine.removePlayer(s, pid(green)).value;
    final (end, events) = moveOk(rolled(almostDone(s, red, 53), red, 3), 3);
    expect(end.isOver, isTrue);
    expect(events.whereType<GameOver>().single.ranking, [
      red,
      blue,
      green,
      yellow,
    ]);
  });

  test('when removals leave one player, that player ranks first', () {
    final s = newGame([red, yellow]);
    final (end, events) = GameEngine.removePlayer(s, pid(yellow)).value;
    expect(end.isOver, isTrue);
    expect(events.last, isA<GameOver>());
    expect(end.ranking, [red, yellow]);
  });

  test('rank rules: finishers, last player, then leavers latest first', () {
    expect(
      RankRules.finalRanking(
        finishers: [green],
        lastUnfinished: red,
        leavers: [blue, yellow],
      ),
      [green, red, yellow, blue],
    );
  });

  test('turn order skips finished and removed players', () {
    var s = finish(newGame(), red);
    expect(s.currentColor, blue);
    (s, _) = GameEngine.removePlayer(s, pid(yellow)).value;
    (s, _) = rollOk(s, 2);
    expect(s.currentColor, green);
    (s, _) = rollOk(s, 2);
    expect(s.currentColor, blue);
  });
}

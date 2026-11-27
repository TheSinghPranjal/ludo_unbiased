import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

import '../helpers/game_builders.dart';

void main() {
  group('passing and extra rolls', () {
    test('1–5 with every token in base passes the turn', () {
      for (var f = 1; f <= 5; f++) {
        final (s, events) = rollOk(newGame(), f);
        expect(s.currentColor, blue, reason: 'face $f');
        expect(s.phase, GamePhase.awaitingRoll);
        expect(s.dice, isNull);
        expect(events.last, isA<TurnPassed>());
        expect((events.last as TurnPassed).reason, TurnPassReason.noMoves);
      }
    });

    test('a 6 from base waits for a move, then earns one extra roll', () {
      var (s, _) = rollOk(newGame(), 6);
      expect(s.phase, GamePhase.rolled);
      expect(s.currentColor, red);
      final (after, events) = moveOk(s, 0);
      s = after;
      expect(s.currentColor, red);
      expect(s.phase, GamePhase.awaitingRoll);
      expect(events.whereType<ExtraRoll>().single.reason, ExtraRollReason.six);
    });

    test('a capture with a non-6 earns an extra roll', () {
      // Red rel 2 → 5 is absolute 5; Blue rel 44 is absolute 5.
      final s = rolled(place(newGame(), {(red, 0): 2, (blue, 0): 44}), red, 3);
      final (next, events) = moveOk(s, 0);
      expect(next.currentColor, red);
      expect(
        events.whereType<ExtraRoll>().single.reason,
        ExtraRollReason.capture,
      );
    });

    test('reaching HOME with a non-6 earns an extra roll', () {
      final s = rolled(place(newGame(), {(red, 0): 54}), red, 2);
      final (next, events) = moveOk(s, 0);
      expect(next.currentColor, red);
      expect(events.whereType<ExtraRoll>().single.reason, ExtraRollReason.home);
    });

    test('a 6 that also captures earns only one extra roll', () {
      // Red rel 3 + 6 = absolute 9 (unsafe); Blue rel 48 is absolute 9.
      final s = rolled(place(newGame(), {(red, 0): 3, (blue, 0): 48}), red, 6);
      expect(legalMoves(s).firstWhere((m) => m.tokenId == 0).isCapture, isTrue);
      final (afterCapture, events) = moveOk(s, 0);
      expect(events.whereType<ExtraRoll>(), hasLength(1));
      expect(afterCapture.currentColor, red);
      final (afterRoll, _) = rollOk(afterCapture, 2);
      final (afterMove, events2) = moveOk(afterRoll, 0);
      expect(events2.whereType<ExtraRoll>(), isEmpty);
      expect(afterMove.currentColor, blue);
    });

    test('a 6 with no legal move still earns an extra roll', () {
      final s = place(newGame(), {
        (red, 0): 53,
        (red, 1): 56,
        (red, 2): 56,
        (red, 3): 56,
      });
      final (next, events) = rollOk(s, 6);
      expect(next.currentColor, red);
      expect(next.phase, GamePhase.awaitingRoll);
      expect(next.sixesThisTurn, 1);
      expect(events.whereType<ExtraRoll>().single.reason, ExtraRollReason.six);
    });

    test('any non-6 resets the consecutive-six count', () {
      final s = place(newGame(), {(red, 0): 10}).copyWith(sixesThisTurn: 2);
      final (next, _) = rollOk(s, 4);
      expect(next.sixesThisTurn, 0);
    });
  });

  group('three consecutive 6s', () {
    test('the third 6 is not played and earlier moves stand', () {
      var s = place(newGame(), {(red, 0): 10});
      (s, _) = rollOk(s, 6);
      (s, _) = moveOk(s, 0);
      (s, _) = rollOk(s, 6);
      (s, _) = moveOk(s, 0);
      expect(s.tokensOf(red)[0].rel, 22);
      expect(s.sixesThisTurn, 2);
      final (next, events) = rollOk(s, 6);
      expect(events.whereType<ThreeSixesForfeit>(), hasLength(1));
      expect(
        events.whereType<TurnPassed>().single.reason,
        TurnPassReason.threeSixes,
      );
      expect(next.currentColor, blue);
      expect(next.sixesThisTurn, 0);
      expect(next.tokensOf(red)[0].rel, 22);
      expect(next.playerOf(red)!.stats.sixes, 3);
    });
  });

  group('command validation', () {
    test('the wrong player cannot roll; the dice are not used', () {
      final s = newGame();
      final dice = ScriptedDiceService([6]);
      final r = GameEngine.roll(s, pid(blue), dice);
      expect(errorOf(r), RuleError.notYourTurn);
      expect(dice.remaining, 1);
    });

    test('the wrong player cannot move', () {
      final s = rolled(newGame(), red, 6);
      expect(errorOf(GameEngine.move(s, pid(blue), 0)), RuleError.notYourTurn);
    });

    test('unknown players and tokens are rejected', () {
      final s = rolled(newGame(), red, 6);
      expect(errorOf(GameEngine.move(s, 'forged', 0)), RuleError.unknownPlayer);
      expect(errorOf(GameEngine.move(s, pid(red), 4)), RuleError.unknownToken);
      expect(errorOf(GameEngine.move(s, pid(red), -1)), RuleError.unknownToken);
    });

    test('a fabricated position is rejected: base token on a 3', () {
      final s = rolled(place(newGame(), {(red, 1): 10}), red, 3);
      expect(errorOf(GameEngine.move(s, pid(red), 0)), RuleError.illegalMove);
    });

    test('moving before rolling and rolling twice are rejected', () {
      final s = newGame();
      expect(errorOf(GameEngine.move(s, pid(red), 0)), RuleError.wrongPhase);
      final r = rolled(s, red, 6);
      final dice = ScriptedDiceService([1]);
      expect(errorOf(GameEngine.roll(r, pid(red), dice)), RuleError.wrongPhase);
      expect(dice.remaining, 1);
    });

    test('every command is rejected while animating', () {
      final (animating, _) = GameEngine.roll(
        newGame(),
        pid(red),
        ScriptedDiceService([6]),
      ).value;
      expect(animating.phase, GamePhase.animating);
      final dice = ScriptedDiceService([3]);
      expect(
        errorOf(GameEngine.roll(animating, pid(red), dice)),
        RuleError.wrongPhase,
      );
      expect(
        errorOf(GameEngine.move(animating, pid(red), 0)),
        RuleError.wrongPhase,
      );
    });

    test('commands after game over are rejected', () {
      final over = newGame().copyWith(phase: GamePhase.gameOver);
      final dice = ScriptedDiceService([6]);
      expect(
        errorOf(GameEngine.roll(over, pid(red), dice)),
        RuleError.gameOver,
      );
      expect(errorOf(GameEngine.move(over, pid(red), 0)), RuleError.gameOver);
      expect(
        errorOf(GameEngine.removePlayer(over, pid(blue))),
        RuleError.gameOver,
      );
    });

    test('rejected commands leave the state identical', () {
      final s = rolled(place(newGame(), {(red, 0): 53}), red, 4);
      final json = s.toJson();
      final hash = s.hashCode;
      final dice = ScriptedDiceService([2]);
      final rejections = [
        GameEngine.move(s, pid(red), 0),
        GameEngine.move(s, pid(blue), 0),
        GameEngine.move(s, 'nobody', 0),
        GameEngine.roll(s, pid(red), dice),
      ];
      for (final r in rejections) {
        expect(r.isOk, isFalse);
      }
      expect(s.toJson(), json);
      expect(s.hashCode, hash);
      expect(dice.remaining, 1);
    });
  });

  group('turnSeq', () {
    test('increments once per committed command', () {
      var s = newGame();
      expect(s.turnSeq, 0);
      (s, _) = rollOk(s, 6);
      expect(s.turnSeq, 1);
      (s, _) = moveOk(s, 0);
      expect(s.turnSeq, 2);
      (s, _) = rollOk(s, 2);
      expect(s.turnSeq, 3);
    });
  });
}

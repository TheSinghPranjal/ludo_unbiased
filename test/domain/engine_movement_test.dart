import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';

import '../helpers/game_builders.dart';

void main() {
  group('leaving base', () {
    test('needs a 6; faces 1–5 give no legal move', () {
      final s = newGame();
      for (var f = 1; f <= 5; f++) {
        expect(legalMoves(rolled(s, red, f)), isEmpty, reason: 'face $f');
      }
    });

    test('a 6 lets any base token onto its own start cell', () {
      final moves = legalMoves(rolled(newGame(), red, 6));
      expect(moves.map((m) => m.tokenId), [0, 1, 2, 3]);
      for (final m in moves) {
        expect(m.toRel, 0);
        expect(m.entersBase, isTrue);
        expect(m.landsSafe, isTrue);
      }
      final (s, events) = moveOk(rolled(newGame(), red, 6), 2);
      expect(s.tokensOf(red)[2].rel, 0);
      final moved = events.whereType<TokenMoved>().single;
      expect(moved.path, [const BoardCell(13, 6)]);
    });
  });

  group('moving', () {
    test('every face 1–6 moves exactly that many steps', () {
      for (var f = 1; f <= 6; f++) {
        final s = rolled(place(newGame(), {(red, 0): 10}), red, f);
        final (next, events) = moveOk(s, 0);
        expect(next.tokensOf(red)[0].rel, 10 + f);
        expect(events.whereType<TokenMoved>().single.path, hasLength(f));
      }
    });

    test('crosses track index 51 → 0', () {
      // Blue rel 37 is absolute 50; three steps go 51, 0, 1.
      final s = rolled(place(newGame(), {(blue, 0): 37}), blue, 3);
      final (_, events) = moveOk(s, 0);
      final path = events.whereType<TokenMoved>().single.path;
      expect(path, [
        BoardConstants.track[51],
        BoardConstants.track[0],
        BoardConstants.track[1],
      ]);
    });

    test('enters its home column after relative 50', () {
      final s = rolled(place(newGame(), {(red, 0): 48}), red, 5);
      final (next, events) = moveOk(s, 0);
      expect(next.tokensOf(red)[0].rel, 53);
      expect(events.whereType<TokenMoved>().single.path, const [
        BoardCell(14, 8),
        BoardCell(14, 7),
        BoardCell(13, 7),
        BoardCell(12, 7),
        BoardCell(11, 7),
      ]);
    });

    test('lands exactly on HOME at 56', () {
      final s = rolled(place(newGame(), {(red, 0): 52}), red, 4);
      final (next, events) = moveOk(s, 0);
      expect(next.tokensOf(red)[0].isHome, isTrue);
      expect(events.whereType<TokenHome>(), hasLength(1));
      expect(next.currentPlayer.stats.tokensHome, 1);
    });

    test('overshooting HOME is illegal and changes nothing', () {
      final s = rolled(place(newGame(), {(red, 0): 53, (red, 1): 10}), red, 4);
      expect(legalMoves(s).map((m) => m.tokenId), [1]);
      final before = s.toJson();
      final r = GameEngine.move(s, pid(red), 0);
      expect(errorOf(r), RuleError.illegalMove);
      expect(s.toJson(), before);
    });

    test('a roll whose only token would overshoot passes the turn', () {
      final s = place(newGame(), {(red, 0): 53});
      final (next, events) = rollOk(s, 4);
      expect(next.currentColor, blue);
      expect(
        events.whereType<TurnPassed>().single.reason,
        TurnPassReason.noMoves,
      );
    });

    test('a token at HOME has no moves', () {
      final s = rolled(place(newGame(), {(red, 0): 56, (red, 1): 5}), red, 3);
      expect(legalMoves(s).map((m) => m.tokenId), [1]);
    });
  });

  group('settle', () {
    test('moves an animating state to its next phase only', () {
      final s = rolled(newGame(), red, 6);
      final (animating, _) = GameEngine.move(s, pid(red), 0).value;
      expect(animating.phase, GamePhase.animating);
      expect(animating.nextPhase, GamePhase.awaitingRoll);
      final settled = GameEngine.settle(animating);
      expect(settled.phase, GamePhase.awaitingRoll);
      expect(settled.nextPhase, isNull);
      expect(identical(GameEngine.settle(settled), settled), isTrue);
    });
  });
}

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/ai/ai_player.dart';
import 'package:ludo_unbiased/features/ai/ai_weights.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

import '../helpers/game_builders.dart';

void main() {
  final ai = AiPlayer(random: Random(7));

  test('weights reward good outcomes and penalise risk', () {
    const w = AiWeights();
    for (final v in [w.capture, w.reachHome, w.enterHomeColumn, w.leaveBase]) {
      expect(v, greaterThan(0));
    }
    expect(w.safeLanding, greaterThan(0));
    expect(w.risk, lessThan(0));
    expect(w.breakStack, lessThan(0));
    expect(w.capture + w.risk, greaterThan(0), reason: 'a capture is worth it');
  });

  test('prefers a capture over plain progress', () {
    // Token 0: 2 → 5 captures Blue. Token 1: 20 → 23 plain.
    final s = rolled(
      place(newGame(), {(red, 0): 2, (red, 1): 20, (blue, 0): 44}),
      red,
      3,
    );
    expect(ai.choose(s, AiLevel.normal), 0);
  });

  test('prefers reaching HOME', () {
    final s = rolled(place(newGame(), {(red, 0): 52, (red, 1): 20}), red, 4);
    expect(ai.choose(s, AiLevel.normal), 0);
  });

  test('leaves base on a 6 when other moves are plain', () {
    final s = rolled(place(newGame(), {(red, 0): 20}), red, 6);
    expect(ai.choose(s, AiLevel.normal), isNot(0));
    expect(legalMoves(s).firstWhere((m) => m.entersBase).tokenId, 1);
    expect(ai.choose(s, AiLevel.normal), 1);
  });

  test('avoids a risky square when a safe alternative exists', () {
    // Token 0: 15 → 18 lands 2 in front of Blue at red rel 16 (risky).
    // Token 1: 5 → 8 lands on the red star (safe).
    final s = rolled(
      place(newGame(), {(red, 0): 15, (red, 1): 5, (blue, 0): 3}),
      red,
      3,
    );
    final scores = {for (final m in ai.rank(s)) m.move.tokenId: m.score};
    expect(scores[1], greaterThan(scores[0]!));
    expect(ai.choose(s, AiLevel.normal), 1);
  });

  test('Easy picks only from the three best moves', () {
    final s = rolled(
      place(newGame(), {
        (red, 0): 2,
        (red, 1): 20,
        (red, 2): 30,
        (red, 3): 40,
        (blue, 0): 44,
      }),
      red,
      3,
    );
    final top3 = ai.rank(s).take(3).map((m) => m.move.tokenId).toSet();
    final easy = AiPlayer(random: Random(1));
    for (var i = 0; i < 50; i++) {
      expect(top3, contains(easy.choose(s, AiLevel.easy)));
    }
  });

  test('only ever chooses legal moves, accepted by the engine', () {
    final rng = Random(42);
    var checked = 0;
    for (var game = 0; game < 30; game++) {
      var s = newGame();
      final dice = SeededDiceService(game);
      for (var step = 0; step < 400 && !s.isOver; step++) {
        final roll = GameEngine.roll(s, pid(s.currentColor), dice).value;
        s = GameEngine.settle(roll.$1);
        if (s.phase != GamePhase.rolled) continue;
        final level = rng.nextBool() ? AiLevel.easy : AiLevel.normal;
        final choice = ai.choose(s, level)!;
        expect(legalMoves(s).map((m) => m.tokenId), contains(choice));
        final r = GameEngine.move(s, pid(s.currentColor), choice);
        expect(r.isOk, isTrue);
        s = GameEngine.settle(r.value.$1);
        checked++;
      }
    }
    expect(checked, greaterThan(1000));
  });

  test('a full AI-only game reaches game over with a complete ranking', () {
    var s = newGame();
    final dice = SeededDiceService(2026);
    var steps = 0;
    while (!s.isOver) {
      expect(steps++, lessThan(5000), reason: 'game must end');
      final (rolledState, _) = GameEngine.roll(
        s,
        pid(s.currentColor),
        dice,
      ).value;
      s = GameEngine.settle(rolledState);
      if (s.phase == GamePhase.rolled) {
        final t = ai.choose(s, AiLevel.normal)!;
        s = GameEngine.settle(
          GameEngine.move(s, pid(s.currentColor), t).value.$1,
        );
      }
    }
    expect(s.ranking.toSet(), hasLength(4));
    final homes = s.players.map((p) => p.stats.tokensHome).toList();
    expect(homes.where((h) => h == 4), hasLength(3));
  });
}

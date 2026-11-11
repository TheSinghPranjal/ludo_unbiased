import 'dart:async';
import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/controllers/game_core.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/animation_gate.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

import '../helpers/game_builders.dart';

/// A gate whose dice animation the test finishes by hand.
class ManualDiceGate implements AnimationGate {
  final List<Completer<void>> dice = [];

  @override
  Future<void> played(List<GameEvent> events) {
    if (events.first is! DiceRolled) return Future<void>.value();
    final c = Completer<void>();
    dice.add(c);
    return c.future;
  }

  void land() {
    for (final c in dice) {
      if (!c.isCompleted) c.complete();
    }
  }
}

class Harness {
  Harness(GameState initial, List<int> rolls, {AnimationGate? gate})
    : core = GameCore(
        initial: initial,
        dice: ScriptedDiceService(rolls),
        random: Random(1),
        gate: gate,
      ) {
    core.events.listen(events.addAll);
  }

  final GameCore core;
  final List<GameEvent> events = [];

  GameState get state => core.state.value;
  List<TokenMoved> get moves => events.whereType<TokenMoved>().toList();
  int get rolls => events.whereType<DiceRolled>().length;
}

void main() {
  group('turn timer', () {
    test('starts at 30 s', () {
      fakeAsync((fa) {
        final h = Harness(newGame(), [])..core.start();
        expect(h.core.remainingMs.value, 30000);
        fa.elapse(const Duration(seconds: 10));
        expect(h.core.remainingMs.value, 20000);
        h.core.dispose();
      });
    });

    test('resets to 30 s when an extra roll is earned', () {
      fakeAsync((fa) {
        final h = Harness(newGame(), [6])..core.start();
        fa.elapse(const Duration(seconds: 10));
        expect(h.core.roll(pid(red)), isNull);
        expect(h.core.remainingMs.value, 20000, reason: 'roll keeps deadline');
        // Single choice (all in base) auto-moves at 1120 ms, the hop takes
        // 150 ms, then the extra roll starts a fresh 30 s.
        fa.elapse(const Duration(milliseconds: 1270));
        expect(h.state.phase, GamePhase.awaitingRoll);
        expect(h.state.currentColor, red);
        expect(h.core.remainingMs.value, 30000);
        h.core.dispose();
      });
    });

    test('expiry before rolling rolls for the player; no move passes', () {
      fakeAsync((fa) {
        final h = Harness(newGame(), [3])..core.start();
        fa.elapse(const Duration(milliseconds: 29999));
        expect(h.rolls, 0);
        fa.elapse(const Duration(milliseconds: 1));
        expect(h.rolls, 1, reason: 'host rolled at expiry');
        fa.elapse(const Duration(milliseconds: 800));
        expect(h.events.last, isA<TurnPassed>());
        expect(h.state.currentColor, blue);
        expect(h.core.remainingMs.value, 30000);
        h.core.dispose();
      });
    });

    test('expiry before rolling with one move plays it at 1120 ms', () {
      fakeAsync((fa) {
        final h = Harness(place(newGame(), {(red, 0): 10}), [2])..core.start();
        fa.elapse(const Duration(seconds: 30));
        expect(h.rolls, 1);
        fa.elapse(const Duration(milliseconds: 1119));
        expect(h.moves, isEmpty);
        fa.elapse(const Duration(milliseconds: 1));
        expect(h.moves.single.toRel, 12);
        h.core.dispose();
      });
    });

    test('expiry before rolling with several moves applies the policy', () {
      fakeAsync((fa) {
        // A 6 with one token out: leave base (tier 3) beats 10 → 16.
        final h = Harness(place(newGame(), {(red, 0): 10}), [6])..core.start();
        fa.elapse(const Duration(milliseconds: 30799));
        expect(h.moves, isEmpty, reason: 'waits for the dice to land');
        fa.elapse(const Duration(milliseconds: 1));
        expect(h.moves.single.tokenId, 1);
        expect(h.moves.single.fromRel, -1);
        h.core.dispose();
      });
    });

    test('expiry after rolling with several moves applies the policy', () {
      fakeAsync((fa) {
        final s = place(newGame(), {(red, 0): 10, (red, 1): 30});
        final h = Harness(s, [2])..core.start();
        h.core.roll(pid(red));
        fa.elapse(const Duration(milliseconds: 29999));
        expect(h.moves, isEmpty);
        fa.elapse(const Duration(milliseconds: 1));
        expect(h.moves.single.tokenId, 1, reason: 'furthest along');
        h.core.dispose();
      });
    });
  });

  group('auto single move', () {
    test('fires at exactly 1120 ms after the roll commits', () {
      fakeAsync((fa) {
        final h = Harness(place(newGame(), {(red, 0): 10}), [3])..core.start();
        h.core.roll(pid(red));
        fa.elapse(const Duration(milliseconds: 1119));
        expect(h.moves, isEmpty);
        fa.elapse(const Duration(milliseconds: 1));
        expect(h.moves, hasLength(1));
        h.core.dispose();
      });
    });

    test('never fires before the dice animation completes', () {
      fakeAsync((fa) {
        final gate = ManualDiceGate();
        final h = Harness(place(newGame(), {(red, 0): 10}), [3], gate: gate)
          ..core.start();
        h.core.roll(pid(red));
        fa.elapse(const Duration(seconds: 5));
        expect(h.moves, isEmpty, reason: 'dice still tumbling');
        expect(h.state.phase, GamePhase.animating);
        gate.land();
        fa.flushMicrotasks();
        expect(h.moves, hasLength(1), reason: 'plays as soon as it lands');
        h.core.dispose();
      });
    });

    test('a tap before 1120 ms wins; the auto-move does nothing', () {
      fakeAsync((fa) {
        final h = Harness(place(newGame(), {(red, 0): 10}), [3])..core.start();
        h.core.roll(pid(red));
        fa.elapse(const Duration(milliseconds: 900));
        expect(h.core.move(pid(red), 0), isNull);
        fa.elapse(const Duration(seconds: 2));
        expect(h.moves, hasLength(1));
        h.core.dispose();
      });
    });

    test('timer expiry and auto-move racing make exactly one move', () {
      for (final rollAt in [29000, 29500]) {
        fakeAsync((fa) {
          final h = Harness(place(newGame(), {(red, 0): 10}), [3])
            ..core.start();
          fa.elapse(Duration(milliseconds: rollAt));
          h.core.roll(pid(red));
          fa.elapse(const Duration(seconds: 5));
          expect(h.moves, hasLength(1), reason: 'roll at $rollAt ms');
          expect(h.state.tokensOf(red)[0].rel, 13);
          h.core.dispose();
        });
      }
    });

    test('nothing fires after game over', () {
      fakeAsync((fa) {
        final s = place(newGame([red, yellow]), {
          (red, 0): 56,
          (red, 1): 56,
          (red, 2): 56,
          (red, 3): 53,
        });
        final h = Harness(s, [3])..core.start();
        h.core.roll(pid(red));
        fa.elapse(const Duration(seconds: 3));
        expect(h.state.isOver, isTrue);
        final count = h.events.length;
        final over = h.state;
        fa.elapse(const Duration(minutes: 2));
        expect(h.events, hasLength(count));
        expect(h.events.last, isA<GameOver>());
        expect(h.state, over);
        expect(h.core.remainingMs.value, 0);
        h.core.dispose();
      });
    });
  });

  group('AI seats', () {
    test('roll after 600–900 ms and move through the engine', () {
      fakeAsync((fa) {
        final s = newGame([red, yellow]).copyWith(
          players: [
            Player(
              id: pid(red),
              color: red,
              name: 'Bot',
              kind: PlayerKind.ai,
              aiLevel: AiLevel.normal,
            ),
            Player(
              id: pid(yellow),
              color: yellow,
              name: 'You',
              kind: PlayerKind.human,
            ),
          ],
        );
        final h = Harness(s, [6, 2])..core.start();
        fa.elapse(const Duration(milliseconds: 599));
        expect(h.rolls, 0);
        fa.elapse(const Duration(milliseconds: 301));
        expect(h.rolls, 1);
        fa.elapse(const Duration(seconds: 6));
        expect(h.rolls, 2);
        expect(h.moves, hasLength(2));
        expect(h.state.currentColor, PlayerColor.yellow);
        expect(h.state.tokensOf(red)[0].rel, 2);
        h.core.dispose();
      });
    });
  });

  group('pause and dispose', () {
    test('pause stops the clock and resume continues it', () {
      fakeAsync((fa) {
        final h = Harness(newGame(), [3])..core.start();
        fa.elapse(const Duration(seconds: 10));
        h.core.pause();
        fa.elapse(const Duration(minutes: 5));
        expect(h.rolls, 0);
        expect(h.core.remainingMs.value, 20000);
        h.core.resume();
        fa.elapse(const Duration(milliseconds: 19999));
        expect(h.rolls, 0);
        fa.elapse(const Duration(milliseconds: 1));
        expect(h.rolls, 1);
        h.core.dispose();
      });
    });

    test('dispose cancels every pending action', () {
      fakeAsync((fa) {
        final h = Harness(place(newGame(), {(red, 0): 10}), [3])..core.start();
        h.core
          ..roll(pid(red))
          ..dispose();
        fa.elapse(const Duration(minutes: 1));
        expect(h.moves, isEmpty);
      });
    });
  });
}

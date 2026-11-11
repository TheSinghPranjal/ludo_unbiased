// Controller calls return futures the tests drive with fake time.
// ignore_for_file: discarded_futures

import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/controllers/local_game_controller.dart';
import 'package:ludo_unbiased/features/game/data/saved_game_repository.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/game_builders.dart';

const List<SeatConfig> seats = [
  (color: red, name: 'Asha', kind: PlayerKind.human, aiLevel: null),
  (color: yellow, name: 'Moss', kind: PlayerKind.ai, aiLevel: AiLevel.easy),
];

void main() {
  late SavedGameRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = SavedGameRepository(await SharedPreferences.getInstance());
  });

  test('pass-and-play acts for the current human seat only', () {
    fakeAsync((fa) {
      final c = LocalGameController.newGame(
        seats,
        dice: ScriptedDiceService([3, 4]),
        random: Random(1),
      )..start();
      expect(c.controlledColors, {red});
      fa.flushMicrotasks();
      expect(c.state.value.currentColor, red);
      c.requestRoll();
      fa.elapse(const Duration(seconds: 1));
      expect(c.state.value.currentColor, yellow);
      RuleError? err;
      c.requestRoll().then((e) => err = e);
      fa.flushMicrotasks();
      expect(err, RuleError.notYourTurn, reason: 'AI seat');
      c.dispose();
    });
  });

  test('saves after every settle and resumes the same state', () {
    fakeAsync((fa) {
      final c = LocalGameController.newGame(
        seats,
        saves: repo,
        dice: ScriptedDiceService([3]),
        random: Random(1),
      )..start();
      fa.elapse(const Duration(seconds: 5));
      c.requestRoll();
      fa.elapse(const Duration(seconds: 1));
      final saved = repo.load()!;
      expect(saved.state, c.state.value);
      expect(saved.remaining, const Duration(seconds: 30));
      c.dispose();

      final resumed = LocalGameController.resume(
        saved,
        saves: repo,
        dice: ScriptedDiceService([]),
        random: Random(1),
      )..start(remaining: saved.remaining);
      expect(resumed.state.value, saved.state);
      expect(resumed.remainingMs.value, 30000);
      resumed.dispose();
    });
  });

  test('a finished game clears the save', () {
    fakeAsync((fa) {
      final s = place(newGame([red, yellow]), {
        (red, 0): 56,
        (red, 1): 56,
        (red, 2): 56,
        (red, 3): 53,
      });
      final c = LocalGameController.resume(
        (state: s, remaining: const Duration(seconds: 30)),
        saves: repo,
        dice: ScriptedDiceService([3]),
      )..start();
      repo.save(s, const Duration(seconds: 30));
      fa.flushMicrotasks();
      expect(repo.hasSave, isTrue);
      // The test seats are human, so the controller acts for Red.
      c.requestRoll();
      fa.elapse(const Duration(seconds: 3));
      expect(c.state.value.phase, GamePhase.gameOver);
      fa.flushMicrotasks();
      expect(repo.hasSave, isFalse);
      c.dispose();
    });
  });

  test('a corrupt or outdated save is ignored', () async {
    await repo.prefs.setString(SavedGameRepository.key, '{"schemaVersion":0}');
    expect(repo.load(), isNull);
    await repo.prefs.setString(SavedGameRepository.key, 'not json');
    expect(repo.load(), isNull);
  });
}

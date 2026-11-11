import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/engine/timeout_policy.dart';

import '../helpers/game_builders.dart';

void main() {
  group('timeout policy priority', () {
    // Red rolls 6. Token 0: 50 → 56 HOME. Token 1: 3 → 9 captures Blue
    // (absolute 9). Token 2: base → start. Token 3: 2 → 8 lands on the star.
    final all = place(newGame(), {
      (red, 0): 50,
      (red, 1): 3,
      (red, 2): -1,
      (red, 3): 2,
      (blue, 0): 48,
    });

    test('1. reaching HOME beats everything', () {
      expect(timeoutMove(rolled(all, red, 6))!.tokenId, 0);
    });

    test('2. a capture beats leaving base and safety', () {
      final s = place(all, {(red, 0): 56});
      expect(timeoutMove(rolled(s, red, 6))!.tokenId, 1);
    });

    test('3. leaving base beats a safe landing', () {
      final s = place(all, {(red, 0): 56, (blue, 0): -1});
      expect(timeoutMove(rolled(s, red, 6))!.tokenId, 2);
    });

    test('4. a safe landing beats plain progress', () {
      final s = place(all, {(red, 0): 56, (blue, 0): -1, (red, 2): 30});
      expect(timeoutMove(rolled(s, red, 6))!.tokenId, 3);
    });

    test('5. otherwise the token furthest along moves', () {
      final s = place(newGame(), {(red, 0): 10, (red, 1): 30, (red, 2): 20});
      expect(timeoutMove(rolled(s, red, 2))!.tokenId, 1);
    });

    test('ties go to the lowest token index', () {
      final s = place(newGame(), {(red, 1): 20, (red, 3): 20});
      expect(timeoutMove(rolled(s, red, 2))!.tokenId, 1);
    });

    test('returns null when there is no legal move', () {
      expect(timeoutMove(rolled(newGame(), red, 3)), isNull);
    });
  });

  group('auto single move', () {
    test('a 6 with every token in base is one choice: token 0', () {
      expect(autoSingleMove(rolled(newGame(), red, 6))!.tokenId, 0);
    });

    test('a stacked pair counts as one choice', () {
      final s = place(newGame(), {(red, 2): 12, (red, 3): 12});
      expect(autoSingleMove(rolled(s, red, 3))!.tokenId, 2);
    });

    test('two different positions are a real choice', () {
      final s = place(newGame(), {(red, 0): 5, (red, 1): 12});
      expect(autoSingleMove(rolled(s, red, 3)), isNull);
    });

    test('no move means nothing to auto-play', () {
      expect(autoSingleMove(rolled(newGame(), red, 2)), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/capture_rules.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

import '../helpers/game_builders.dart';

/// Blue's relative step that sits on absolute track index [abs].
int blueRelAt(int abs) => (abs - PlayerColor.blue.startIndex) % 52;

void main() {
  test('landing on an unsafe cell captures the opponent', () {
    final s = rolled(place(newGame(), {(red, 0): 2, (blue, 0): 44}), red, 3);
    final (next, events) = moveOk(s, 0);
    expect(next.tokensOf(blue)[0].isInBase, isTrue);
    final cap = events.whereType<TokenCaptured>().single;
    expect(cap.color, blue);
    expect(cap.byColor, red);
    expect(next.playerOf(red)!.stats.captures, 1);
    expect(next.playerOf(blue)!.stats.timesCaptured, 1);
  });

  test('captures a stacked opponent pair together', () {
    final s = rolled(
      place(newGame(), {(red, 0): 2, (blue, 0): 44, (blue, 1): 44}),
      red,
      3,
    );
    final (next, events) = moveOk(s, 0);
    expect(events.whereType<TokenCaptured>(), hasLength(2));
    expect(next.tokensOf(blue).where((t) => t.isInBase), hasLength(4));
    expect(next.playerOf(red)!.stats.captures, 2);
  });

  test('never captures on any of the eight safe cells', () {
    for (final abs in SafeCells.indices) {
      final base = place(newGame(), {(blue, 0): blueRelAt(abs)});
      final s = abs == 0
          ? rolled(base, red, 6)
          : rolled(place(base, {(red, 0): abs - 1}), red, 1);
      final moves = legalMoves(s).where((m) => m.toRel == abs);
      expect(moves, isNotEmpty, reason: 'safe $abs');
      expect(moves.first.isCapture, isFalse, reason: 'safe $abs');
      final (next, events) = moveOk(s, moves.first.tokenId);
      expect(events.whereType<TokenCaptured>(), isEmpty);
      expect(next.tokensOf(blue)[0].rel, blueRelAt(abs), reason: 'shares $abs');
    }
  });

  test('same-colour tokens stack and never capture each other', () {
    final s = rolled(place(newGame(), {(red, 0): 2, (red, 1): 5}), red, 3);
    final (next, events) = moveOk(s, 0);
    expect(events.whereType<TokenCaptured>(), isEmpty);
    expect(next.tokensOf(red)[0].rel, 5);
    expect(next.tokensOf(red)[1].rel, 5);
  });

  test('home columns and HOME never capture or get captured', () {
    final s = place(newGame(), {(blue, 0): 53, (green, 0): 56});
    for (var rel = 51; rel <= 56; rel++) {
      expect(CaptureRules.victims(s, red, rel), isEmpty);
    }
    for (var rel = 0; rel <= 50; rel++) {
      final victims = CaptureRules.victims(s, red, rel);
      expect(
        victims.where((v) => v.color == blue || v.color == green),
        isEmpty,
      );
    }
  });

  test('tokens in different home columns never interact', () {
    final s = place(newGame(), {(red, 0): 53, (blue, 0): 53});
    expect(BoardMap.cellFor(red, 53), isNot(BoardMap.cellFor(blue, 53)));
    final r = rolled(s, red, 2);
    final (next, events) = moveOk(r, 0);
    expect(events.whereType<TokenCaptured>(), isEmpty);
    expect(next.tokensOf(blue)[0].rel, 53);
  });
}

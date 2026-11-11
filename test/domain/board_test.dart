import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

void main() {
  const track = BoardConstants.track;

  group('main track', () {
    test('has exactly 52 unique cells inside the grid', () {
      expect(track, hasLength(52));
      expect(track.toSet(), hasLength(52));
      for (final c in track) {
        expect(c.row, inInclusiveRange(0, 14));
        expect(c.col, inInclusiveRange(0, 14));
      }
    });

    test('is a closed loop of adjacent cells, 51 → 0 included', () {
      for (var i = 0; i < 52; i++) {
        final a = track[i];
        final b = track[(i + 1) % 52];
        expect(a.isAdjacentTo(b), isTrue, reason: 'step $i → ${(i + 1) % 52}');
      }
    });

    test('steps are orthogonal except the four diagonal corner steps', () {
      final diagonal = [
        for (var i = 0; i < 52; i++)
          if (track[i].isDiagonalTo(track[(i + 1) % 52])) i,
      ];
      expect(diagonal, BoardConstants.diagonalSteps);
      expect(diagonal, [4, 17, 30, 43]);
    });

    test('never enters a yard or the centre', () {
      for (final c in track) {
        final inYard = (c.row < 6 || c.row > 8) && (c.col < 6 || c.col > 8);
        final inCentre = c.row >= 6 && c.row <= 8 && c.col >= 6 && c.col <= 8;
        expect(inYard || inCentre, isFalse, reason: '$c');
      }
    });
  });

  group('starts and turn order', () {
    test('starts are 0, 13, 26, 39: 13 apart', () {
      expect(PlayerColor.values.map((c) => c.startIndex), [0, 13, 26, 39]);
      expect(track[PlayerColor.red.startIndex], const BoardCell(13, 6));
      expect(track[PlayerColor.blue.startIndex], const BoardCell(6, 1));
      expect(track[PlayerColor.yellow.startIndex], const BoardCell(1, 8));
      expect(track[PlayerColor.green.startIndex], const BoardCell(8, 13));
    });

    test('turn order is Red → Blue → Yellow → Green → Red', () {
      expect(PlayerColor.red.next, PlayerColor.blue);
      expect(PlayerColor.blue.next, PlayerColor.yellow);
      expect(PlayerColor.yellow.next, PlayerColor.green);
      expect(PlayerColor.green.next, PlayerColor.red);
    });

    test('start cells go clockwise around the centre on screen', () {
      double angle(BoardCell c) => atan2(c.row - 7.0, c.col - 7.0) * 180 / pi;
      final angles = PlayerColor.values
          .map((c) => angle(track[c.startIndex]))
          .toList();
      var total = 0.0;
      for (var i = 0; i < 4; i++) {
        final d = (angles[(i + 1) % 4] - angles[i]) % 360;
        expect(d, inExclusiveRange(0, 180), reason: 'screen y grows down');
        total += d;
      }
      expect(total, closeTo(360, 1e-9));
    });

    test('movement along the track is clockwise', () {
      var total = 0.0;
      for (var i = 0; i < 52; i++) {
        final a = track[i];
        final b = track[(i + 1) % 52];
        final a1 = atan2(a.row - 7.0, a.col - 7.0);
        final a2 = atan2(b.row - 7.0, b.col - 7.0);
        var d = a2 - a1;
        if (d < -pi) d += 2 * pi;
        if (d > pi) d -= 2 * pi;
        total += d;
      }
      expect(total, closeTo(2 * pi, 1e-9));
    });
  });

  group('safe cells', () {
    test('are exactly the four starts and four stars', () {
      expect(SafeCells.indices, {0, 8, 13, 21, 26, 34, 39, 47});
      expect(
        [8, 21, 34, 47].map((i) => track[i]),
        const [
          BoardCell(8, 2),
          BoardCell(2, 6),
          BoardCell(6, 12),
          BoardCell(12, 8),
        ],
      );
    });

    test('each star is 8 steps after its colour start', () {
      for (final c in PlayerColor.values) {
        expect(SafeCells.isSafe(c.starIndex), isTrue);
        expect(c.starIndex - c.startIndex, 8);
      }
    });
  });

  group('home columns', () {
    test('match the spec table', () {
      expect(PlayerColor.red.homeColumn.first, const BoardCell(13, 7));
      expect(PlayerColor.red.homeColumn.last, const BoardCell(9, 7));
      expect(PlayerColor.blue.homeColumn.first, const BoardCell(7, 1));
      expect(PlayerColor.blue.homeColumn.last, const BoardCell(7, 5));
      expect(PlayerColor.yellow.homeColumn.first, const BoardCell(1, 7));
      expect(PlayerColor.yellow.homeColumn.last, const BoardCell(5, 7));
      expect(PlayerColor.green.homeColumn.first, const BoardCell(7, 13));
      expect(PlayerColor.green.homeColumn.last, const BoardCell(7, 9));
    });

    test('start next to the relative-50 cell and run in adjacent steps', () {
      const rel50 = {
        PlayerColor.red: BoardCell(14, 7),
        PlayerColor.blue: BoardCell(7, 0),
        PlayerColor.yellow: BoardCell(0, 7),
        PlayerColor.green: BoardCell(7, 14),
      };
      for (final c in PlayerColor.values) {
        expect(BoardMap.cellFor(c, 50), rel50[c]);
        final col = c.homeColumn;
        expect(col, hasLength(5));
        expect(rel50[c]!.isAdjacentTo(col.first), isTrue);
        for (var i = 0; i < 4; i++) {
          expect(col[i].isAdjacentTo(col[i + 1]), isTrue);
          expect(col[i].isDiagonalTo(col[i + 1]), isFalse);
        }
        expect(col.last.isAdjacentTo(c.homeCell), isTrue);
        expect(col.last.isDiagonalTo(c.homeCell), isFalse);
      }
    });

    test('do not overlap each other or the track', () {
      final all = [for (final c in PlayerColor.values) ...c.homeColumn];
      expect(all.toSet(), hasLength(20));
      expect(all.toSet().intersection(track.toSet()), isEmpty);
    });
  });

  group('board map', () {
    test('absolute index is (start + rel) mod 52', () {
      expect(BoardMap.absoluteIndex(PlayerColor.green, 0), 39);
      expect(BoardMap.absoluteIndex(PlayerColor.green, 13), 0);
      expect(BoardMap.absoluteIndex(PlayerColor.blue, 50), 11);
    });

    test('a token needs exactly 56 steps from its start to HOME', () {
      for (final c in PlayerColor.values) {
        final path = BoardMap.path(c, 0, 56);
        expect(path, hasLength(56));
        expect(path.last, c.homeCell);
        var prev = BoardMap.cellFor(c, 0);
        for (final cell in path) {
          expect(prev.isAdjacentTo(cell), isTrue, reason: '$c $prev → $cell');
          prev = cell;
        }
      }
    });
  });
}

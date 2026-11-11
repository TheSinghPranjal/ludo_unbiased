/// Board geometry from spec §1.1. This file is the single source of truth
/// for the engine, the Flame board and the wireframe generator.
library;

import 'package:meta/meta.dart';

/// One square of the 15 × 15 grid, 0-indexed from the top-left.
@immutable
final class BoardCell {
  /// Creates a cell at [row], [col].
  const BoardCell(this.row, this.col);

  /// Reads a cell written by [toJson].
  factory BoardCell.fromJson(Map<String, dynamic> json) =>
      BoardCell(json['r'] as int, json['c'] as int);

  /// Row, 0 at the top.
  final int row;

  /// Column, 0 at the left.
  final int col;

  /// True when [other] is one step away orthogonally or diagonally.
  bool isAdjacentTo(BoardCell other) {
    final dr = (row - other.row).abs();
    final dc = (col - other.col).abs();
    return (dr <= 1 && dc <= 1) && (dr + dc > 0);
  }

  /// True when the step to [other] is diagonal.
  bool isDiagonalTo(BoardCell other) =>
      (row - other.row).abs() == 1 && (col - other.col).abs() == 1;

  /// Compact JSON: `{"r": row, "c": col}`.
  Map<String, dynamic> toJson() => {'r': row, 'c': col};

  @override
  bool operator ==(Object other) =>
      other is BoardCell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';
}

/// Fixed numbers and tables for the board.
abstract final class BoardConstants {
  /// Grid width and height in cells.
  static const int gridSize = 15;

  /// Cells in the main loop.
  static const int trackLength = 52;

  /// Distance between two consecutive start cells.
  static const int startSpacing = 13;

  /// A colour's star safe cell is this many steps after its start.
  static const int starOffset = 8;

  /// Token progress value for a token in its base.
  static const int baseRel = -1;

  /// Last relative step on the main track before the home column.
  static const int lastTrackRel = 50;

  /// First relative step inside a colour's own home column.
  static const int firstHomeColumnRel = 51;

  /// Relative step of HOME (finished).
  static const int homeRel = 56;

  /// HOME cell of each colour, in colour order Red, Blue, Yellow, Green:
  /// the centre-triangle cell next to the end of its home column.
  static const List<BoardCell> homeCells = [
    BoardCell(8, 7),
    BoardCell(7, 6),
    BoardCell(6, 7),
    BoardCell(7, 8),
  ];

  /// The 52 main-track cells in movement order, starting at Red's start.
  static const List<BoardCell> track = [
    BoardCell(13, 6),
    BoardCell(12, 6),
    BoardCell(11, 6),
    BoardCell(10, 6),
    BoardCell(9, 6),
    BoardCell(8, 5),
    BoardCell(8, 4),
    BoardCell(8, 3),
    BoardCell(8, 2),
    BoardCell(8, 1),
    BoardCell(8, 0),
    BoardCell(7, 0),
    BoardCell(6, 0),
    BoardCell(6, 1),
    BoardCell(6, 2),
    BoardCell(6, 3),
    BoardCell(6, 4),
    BoardCell(6, 5),
    BoardCell(5, 6),
    BoardCell(4, 6),
    BoardCell(3, 6),
    BoardCell(2, 6),
    BoardCell(1, 6),
    BoardCell(0, 6),
    BoardCell(0, 7),
    BoardCell(0, 8),
    BoardCell(1, 8),
    BoardCell(2, 8),
    BoardCell(3, 8),
    BoardCell(4, 8),
    BoardCell(5, 8),
    BoardCell(6, 9),
    BoardCell(6, 10),
    BoardCell(6, 11),
    BoardCell(6, 12),
    BoardCell(6, 13),
    BoardCell(6, 14),
    BoardCell(7, 14),
    BoardCell(8, 14),
    BoardCell(8, 13),
    BoardCell(8, 12),
    BoardCell(8, 11),
    BoardCell(8, 10),
    BoardCell(8, 9),
    BoardCell(9, 8),
    BoardCell(10, 8),
    BoardCell(11, 8),
    BoardCell(12, 8),
    BoardCell(13, 8),
    BoardCell(14, 8),
    BoardCell(14, 7),
    BoardCell(14, 6),
  ];

  /// Track indices of the four diagonal corner steps (i → i + 1).
  static const List<int> diagonalSteps = [4, 17, 30, 43];

  /// Home columns in colour order Red, Blue, Yellow, Green; relative 51 → 55.
  static const List<List<BoardCell>> homeColumns = [
    [
      BoardCell(13, 7), BoardCell(12, 7), BoardCell(11, 7), //
      BoardCell(10, 7), BoardCell(9, 7),
    ],
    [
      BoardCell(7, 1), BoardCell(7, 2), BoardCell(7, 3), //
      BoardCell(7, 4), BoardCell(7, 5),
    ],
    [
      BoardCell(1, 7), BoardCell(2, 7), BoardCell(3, 7), //
      BoardCell(4, 7), BoardCell(5, 7),
    ],
    [
      BoardCell(7, 13), BoardCell(7, 12), BoardCell(7, 11), //
      BoardCell(7, 10), BoardCell(7, 9),
    ],
  ];

  /// Top-left cell of each yard, in colour order Red, Blue, Yellow, Green.
  static const List<BoardCell> yardOrigins = [
    BoardCell(9, 0),
    BoardCell(0, 0),
    BoardCell(0, 9),
    BoardCell(9, 9),
  ];
}

import 'package:ludo_unbiased/core/constants/board_constants.dart';

/// The four seats, declared in clockwise turn order: Red → Blue → Yellow →
/// Green.
enum PlayerColor {
  /// Bottom-left yard; starts at track index 0.
  red,

  /// Top-left yard; starts at track index 13.
  blue,

  /// Top-right yard; starts at track index 26.
  yellow,

  /// Bottom-right yard; starts at track index 39.
  green
  ;

  /// Absolute track index of this colour's start cell (relative step 0).
  int get startIndex => index * BoardConstants.startSpacing;

  /// Absolute track index of this colour's star safe cell.
  int get starIndex => startIndex + BoardConstants.starOffset;

  /// The next colour clockwise.
  PlayerColor get next => values[(index + 1) % values.length];

  /// Colour-blind symbol shown on tokens and cards.
  String get symbol => const ['●', '■', '▲', '★'][index];

  /// This colour's home column, relative steps 51 → 55.
  List<BoardCell> get homeColumn => BoardConstants.homeColumns[index];

  /// The centre-triangle cell a finished token rests on.
  BoardCell get homeCell => BoardConstants.homeCells[index];

  /// Top-left cell of this colour's yard.
  BoardCell get yardOrigin => BoardConstants.yardOrigins[index];

  /// Default seats for a game of [count] players: opposite colours for two.
  static List<PlayerColor> defaultSeats(int count) => switch (count) {
    2 => const [red, yellow],
    3 => const [red, blue, yellow],
    4 => values,
    _ => throw ArgumentError.value(count, 'count', 'must be 2, 3 or 4'),
  };
}

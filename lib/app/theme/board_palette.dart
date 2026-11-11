import 'package:flutter/material.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// Board and player colours (spec §1.9). Widgets and Flame components read
/// colours only from here and [ThemeData.extension].
@immutable
class BoardPalette extends ThemeExtension<BoardPalette> {
  /// Creates a palette.
  const BoardPalette({
    required this.red,
    required this.blue,
    required this.yellow,
    required this.green,
    required this.board,
    required this.cell,
    required this.grid,
    required this.star,
    required this.inner,
    required this.tokenRim,
  });

  /// Light mode, matching the reference board.
  static const light = BoardPalette(
    red: Color(0xFFD9342B),
    blue: Color(0xFF3E8EDE),
    yellow: Color(0xFFECCB3A),
    green: Color(0xFF3D9142),
    board: Color(0xFFDCE1E9),
    cell: Color(0xFFFFFFFF),
    grid: Color(0xFFC9CFD9),
    star: Color(0xFF7A8394),
    inner: Color(0xFFFFFFFF),
    tokenRim: null,
  );

  /// Dark mode: player colours 10% less saturated, light star outlines.
  static const dark = BoardPalette(
    red: Color(0xFFD03C34),
    blue: Color(0xFF468ED6),
    yellow: Color(0xFFE3C543),
    green: Color(0xFF418D46),
    board: Color(0xFF171A24),
    cell: Color(0xFF232838),
    grid: Color(0xFF343A4F),
    star: Color(0xFFE6E8F0),
    inner: Color(0xFF1D2030),
    tokenRim: Color(0xFFFFFFFF),
  );

  /// Red player colour.
  final Color red;

  /// Blue player colour.
  final Color blue;

  /// Yellow player colour.
  final Color yellow;

  /// Green player colour.
  final Color green;

  /// Board base behind the cells; shows through as grid lines.
  final Color board;

  /// Track cell fill.
  final Color cell;

  /// Grid line colour.
  final Color grid;

  /// Safe-cell star outline.
  final Color star;

  /// Yard inner square.
  final Color inner;

  /// Light rim around tokens and dice in dark mode; null in light mode.
  final Color? tokenRim;

  /// The colour for [c].
  Color of(PlayerColor c) => switch (c) {
    PlayerColor.red => red,
    PlayerColor.blue => blue,
    PlayerColor.yellow => yellow,
    PlayerColor.green => green,
  };

  /// Readable symbol colour on a [c] token.
  Color onToken(PlayerColor c) =>
      c == PlayerColor.yellow ? const Color(0xFF3B2F00) : Colors.white;

  @override
  BoardPalette copyWith({
    Color? red,
    Color? blue,
    Color? yellow,
    Color? green,
    Color? board,
    Color? cell,
    Color? grid,
    Color? star,
    Color? inner,
    Color? tokenRim,
  }) => BoardPalette(
    red: red ?? this.red,
    blue: blue ?? this.blue,
    yellow: yellow ?? this.yellow,
    green: green ?? this.green,
    board: board ?? this.board,
    cell: cell ?? this.cell,
    grid: grid ?? this.grid,
    star: star ?? this.star,
    inner: inner ?? this.inner,
    tokenRim: tokenRim ?? this.tokenRim,
  );

  @override
  BoardPalette lerp(BoardPalette? other, double t) {
    if (other == null) return this;
    return BoardPalette(
      red: Color.lerp(red, other.red, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      yellow: Color.lerp(yellow, other.yellow, t)!,
      green: Color.lerp(green, other.green, t)!,
      board: Color.lerp(board, other.board, t)!,
      cell: Color.lerp(cell, other.cell, t)!,
      grid: Color.lerp(grid, other.grid, t)!,
      star: Color.lerp(star, other.star, t)!,
      inner: Color.lerp(inner, other.inner, t)!,
      tokenRim: t < 0.5 ? tokenRim : other.tokenRim,
    );
  }
}

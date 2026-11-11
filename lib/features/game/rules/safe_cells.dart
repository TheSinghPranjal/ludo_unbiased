import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// Safe cells: the four start cells and the four star cells (spec §1.2).
/// No capture ever happens on them.
abstract final class SafeCells {
  /// Absolute track indices of all eight safe cells.
  static final Set<int> indices = {
    for (final c in PlayerColor.values) ...[c.startIndex, c.starIndex],
  };

  /// True when absolute track index [index] is safe.
  static bool isSafe(int index) => indices.contains(index);
}

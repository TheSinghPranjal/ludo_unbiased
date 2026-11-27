import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// Final placing (spec §1.2, Winning and ranking).
abstract final class RankRules {
  /// The full ranking, first place first.
  ///
  /// Finishers keep the order they finished in. The last player still
  /// playing comes next, above every leaver. Leavers rank below everyone,
  /// and a later leaver ranks above an earlier one.
  static List<PlayerColor> finalRanking({
    required List<PlayerColor> finishers,
    required List<PlayerColor> leavers,
    PlayerColor? lastUnfinished,
  }) => [
    ...finishers,
    ?lastUnfinished,
    ...leavers.reversed,
  ];
}

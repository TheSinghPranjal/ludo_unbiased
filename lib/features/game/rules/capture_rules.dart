import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/models/token.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

/// Who gets captured when a token lands (spec §1.2, Capturing).
abstract final class CaptureRules {
  /// Opponent tokens captured when [mover] lands on relative step [toRel].
  ///
  /// Landing on an unsafe main-track cell captures every opponent token on
  /// that cell, stacks included. Safe cells, home columns and HOME never
  /// capture, and a player never captures their own tokens.
  static List<TokenRef> victims(
    GameState state,
    PlayerColor mover,
    int toRel,
  ) {
    if (toRel < 0 || toRel > BoardConstants.lastTrackRel) return const [];
    final target = BoardMap.absoluteIndex(mover, toRel);
    if (SafeCells.isSafe(target)) return const [];
    return [
      for (final t in state.tokens)
        if (t.color != mover &&
            t.isOnTrack &&
            BoardMap.absoluteIndex(t.color, t.rel) == target)
          TokenRef(color: t.color, id: t.id),
    ];
  }
}

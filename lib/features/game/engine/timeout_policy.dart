import 'package:collection/collection.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/move.dart';

/// The move auto-play makes when there is exactly one effective choice, or
/// null when there is no move or a real choice to make.
///
/// Moves from the same position count as one choice; the lowest token index
/// moves.
Move? autoSingleMove(GameState state) {
  final groups = equivalentMoveGroups(legalMoves(state));
  return groups.length == 1 ? groups.single.first : null;
}

/// The move played when the turn timer expires with several choices
/// (spec §1.3), or null when there are no legal moves.
///
/// Priority: (1) reaches HOME, (2) captures, (3) leaves base, (4) lands on a
/// safe cell or in the home column, (5) the token furthest along. Ties go to
/// the lowest token index.
Move? timeoutMove(GameState state) {
  final moves = legalMoves(state);
  if (moves.isEmpty) return null;
  int tier(Move m) {
    if (m.reachesHome) return 0;
    if (m.isCapture) return 1;
    if (m.entersBase) return 2;
    if (m.landsSafe) return 3;
    return 4;
  }

  return moves.sorted((a, b) {
    final byTier = tier(a).compareTo(tier(b));
    if (byTier != 0) return byTier;
    if (tier(a) == 4) {
      final byProgress = b.fromRel.compareTo(a.fromRel);
      if (byProgress != 0) return byProgress;
    }
    return a.tokenId.compareTo(b.tokenId);
  }).first;
}

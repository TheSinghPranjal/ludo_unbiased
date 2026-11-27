import 'package:collection/collection.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/move.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/capture_rules.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

/// The legal moves for the current player's committed dice.
///
/// This is the only place legality is decided: UI highlights, AI, auto-play,
/// the timeout policy and command validation all call it.
///
/// Returns moves while the phase is `rolled`, or while a dice animation is
/// settling into `rolled`; otherwise an empty list.
List<Move> legalMoves(GameState state) {
  final dice = state.dice;
  final choosing =
      state.phase == GamePhase.rolled ||
      (state.phase == GamePhase.animating &&
          state.nextPhase == GamePhase.rolled);
  if (!choosing || dice == null) return const [];
  return movesFor(state, state.currentColor, dice);
}

/// Every move [color] could make with [dice], ignoring whose turn it is.
///
/// Rules (spec §1.2): a token leaves base only on a 6, onto its start cell;
/// every other face moves exactly that many steps; overshooting HOME (56)
/// is illegal; captures follow [CaptureRules].
List<Move> movesFor(GameState state, PlayerColor color, int dice) {
  final moves = <Move>[];
  for (final t in state.tokensOf(color)) {
    if (t.isHome) continue;
    final int to;
    if (t.isInBase) {
      if (dice != 6) continue;
      to = 0;
    } else {
      to = t.rel + dice;
      if (to > BoardConstants.homeRel) continue;
    }
    final onTrack = to <= BoardConstants.lastTrackRel;
    moves.add(
      Move(
        tokenId: t.id,
        fromRel: t.rel,
        toRel: to,
        captures: CaptureRules.victims(state, color, to),
        entersBase: t.isInBase,
        reachesHome: to == BoardConstants.homeRel,
        landsSafe:
            !onTrack || SafeCells.isSafe(BoardMap.absoluteIndex(color, to)),
      ),
    );
  }
  return moves;
}

/// Groups [moves] that are the same choice: tokens moving from the same
/// position end in the same place with the same effect.
///
/// One group means the player has no real choice, so auto-play may act.
List<List<Move>> equivalentMoveGroups(List<Move> moves) => groupBy<Move, int>(
  moves,
  (m) => m.fromRel,
).values.map((g) => g.sortedBy<num>((m) => m.tokenId)).toList();

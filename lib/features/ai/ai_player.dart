import 'dart:math';

import 'package:collection/collection.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/ai/ai_weights.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/move.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/safe_cells.dart';

/// A legal move with its score.
typedef ScoredMove = ({Move move, double score});

/// Chooses moves for computer seats (spec §1.6).
///
/// The AI never changes state itself: [choose] returns a token id, which the
/// controller submits to the engine like any other move request.
final class AiPlayer {
  /// Creates an AI using [weights] and, for Easy, [random].
  AiPlayer({this.weights = const AiWeights(), Random? random})
    : _random = random ?? Random();

  /// The scoring weights.
  final AiWeights weights;
  final Random _random;

  /// The token id to move, or null when there is no legal move.
  ///
  /// Normal picks the highest score (lowest token index on a tie). Easy picks
  /// at random among the three best.
  int? choose(GameState state, AiLevel level) {
    final ranked = rank(state);
    if (ranked.isEmpty) return null;
    if (level == AiLevel.normal) return ranked.first.move.tokenId;
    final top = ranked.take(3).toList();
    return top[_random.nextInt(top.length)].move.tokenId;
  }

  /// Every legal move with its score, best first.
  List<ScoredMove> rank(GameState state) {
    final moves = legalMoves(state);
    return [
      for (final m in moves) (move: m, score: score(state, m)),
    ].sorted((a, b) {
      final c = b.score.compareTo(a.score);
      return c != 0 ? c : a.move.tokenId.compareTo(b.move.tokenId);
    });
  }

  /// The score of [move] for the current player in [state].
  double score(GameState state, Move move) {
    final color = state.currentColor;
    final w = weights;
    var s = 0.0;
    for (final v in move.captures) {
      final victim = state.tokensOf(v.color).firstWhere((t) => t.id == v.id);
      s += w.capture + w.capturePerVictimStep * victim.rel;
    }
    if (move.reachesHome) s += w.reachHome;
    if (move.fromRel <= BoardConstants.lastTrackRel &&
        move.toRel >= BoardConstants.firstHomeColumnRel &&
        !move.reachesHome) {
      s += w.enterHomeColumn;
    }
    if (move.entersBase) {
      final inBase = state.tokensOf(color).where((t) => t.isInBase).length;
      s += w.leaveBase + w.leaveBasePerTokenInBase * (inBase - 1);
    }
    final onTrackAfter = move.toRel <= BoardConstants.lastTrackRel;
    if (onTrackAfter && move.landsSafe) s += w.safeLanding;
    if (onTrackAfter &&
        !move.landsSafe &&
        !move.isCapture &&
        _threatened(state, color, move.toRel)) {
      s += w.risk;
    }
    final fromTrack =
        move.fromRel >= 0 && move.fromRel <= BoardConstants.lastTrackRel;
    if (fromTrack) {
      final fromAbs = BoardMap.absoluteIndex(color, move.fromRel);
      if (!SafeCells.isSafe(fromAbs) &&
          _threatened(state, color, move.fromRel)) {
        s += w.escapeRisk;
      }
      final stacked = state
          .tokensOf(color)
          .where((t) => t.rel == move.fromRel)
          .length;
      if (stacked == 2 && !SafeCells.isSafe(fromAbs)) s += w.breakStack;
    }
    final steps = move.entersBase ? 1 : move.toRel - move.fromRel;
    return s + w.progressPerStep * steps;
  }

  /// True when an opponent on the track sits 1–6 cells behind [rel] on
  /// [color]'s route and could reach it without turning into its own column.
  bool _threatened(GameState state, PlayerColor color, int rel) {
    final target = BoardMap.absoluteIndex(color, rel);
    for (final t in state.tokens) {
      if (t.color == color || !t.isOnTrack) continue;
      final from = BoardMap.absoluteIndex(t.color, t.rel);
      final d = (target - from) % BoardConstants.trackLength;
      if (d >= 1 && d <= 6 && t.rel + d <= BoardConstants.lastTrackRel) {
        return true;
      }
    }
    return false;
  }
}

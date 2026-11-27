/// Ensures exactly one action per decision point (spec §1.3).
///
/// Every decision point has its own `turnSeq`. Whoever acts first, whether a
/// tap, the AI, the auto-move or the timer, claims it; later claims for the
/// same or an older `turnSeq` fail and do nothing.
class DecisionGuard {
  int _last = -1;

  /// The last claimed decision.
  int get lastClaimed => _last;

  /// True when [turnSeq] has not been claimed yet.
  bool canClaim(int turnSeq) => turnSeq > _last;

  /// Claims [turnSeq]; returns false when it was already claimed.
  bool claim(int turnSeq) {
    if (!canClaim(turnSeq)) return false;
    _last = turnSeq;
    return true;
  }
}

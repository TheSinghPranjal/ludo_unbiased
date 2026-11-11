/// Scoring weights for the AI (spec §1.6). All tuning lives here.
final class AiWeights {
  /// Creates weights; the defaults are the shipped tuning.
  const AiWeights({
    this.capture = 60,
    this.capturePerVictimStep = 0.8,
    this.reachHome = 70,
    this.enterHomeColumn = 28,
    this.leaveBase = 32,
    this.leaveBasePerTokenInBase = 6,
    this.safeLanding = 18,
    this.risk = -45,
    this.escapeRisk = 20,
    this.breakStack = -12,
    this.progressPerStep = 0.6,
  });

  /// Base reward for capturing.
  final double capture;

  /// Extra capture reward per step the victim had travelled.
  final double capturePerVictimStep;

  /// Reward for landing exactly on HOME.
  final double reachHome;

  /// Reward for moving from the main track into the home column.
  final double enterHomeColumn;

  /// Reward for leaving base on a 6.
  final double leaveBase;

  /// Extra leave-base reward for each other token still in base.
  final double leaveBasePerTokenInBase;

  /// Reward for landing on a safe cell.
  final double safeLanding;

  /// Penalty for landing 1–6 cells in front of an opponent on an unsafe cell.
  final double risk;

  /// Reward for moving a token that is currently under threat.
  final double escapeRisk;

  /// Penalty for leaving a protective two-token stack on an unsafe cell.
  final double breakStack;

  /// Reward per step of progress.
  final double progressPerStep;
}

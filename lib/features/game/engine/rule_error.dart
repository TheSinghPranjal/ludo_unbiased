/// Why the engine rejected a command. A rejected command never changes state.
enum RuleError {
  /// The game has ended.
  gameOver,

  /// The command does not fit the current phase (for example, a move during
  /// an animation or before rolling).
  wrongPhase,

  /// No player has that id.
  unknownPlayer,

  /// The player has left or was removed.
  playerRemoved,

  /// It is someone else's turn.
  notYourTurn,

  /// The token id is not 0–3.
  unknownToken,

  /// That token has no legal move for the current dice.
  illegalMove,

  /// The command repeats the player's current status.
  noChange,
}

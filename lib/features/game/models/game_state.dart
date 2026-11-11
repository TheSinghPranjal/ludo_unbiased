import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/models/token.dart';

part 'game_state.freezed.dart';
part 'game_state.g.dart';

/// Where the game is in its turn cycle.
enum GamePhase {
  /// Waiting for the current player to roll.
  awaitingRoll,

  /// Rolled; waiting for the current player to choose a move.
  rolled,

  /// A committed roll or move is animating. All commands are rejected until
  /// the engine settles the state into [GameState.nextPhase].
  animating,

  /// Finished. All commands are rejected.
  gameOver,
}

/// The complete, immutable state of one game.
///
/// It holds no secrets and no clock: the turn deadline belongs to the
/// controller, so two states with the same moves are equal everywhere.
@freezed
abstract class GameState with _$GameState {
  /// Creates a state.
  const factory GameState({
    required String gameId,
    required List<Player> players,
    required List<Token> tokens,
    required PlayerColor currentColor,
    required GamePhase phase,

    /// The phase to enter when the current animation settles.
    GamePhase? nextPhase,

    /// The committed roll the current player is choosing a move for.
    int? dice,

    /// Consecutive 6s rolled in the current turn.
    @Default(0) int sixesThisTurn,

    /// Increments at every decision point (roll, move, pass, removal).
    @Default(0) int turnSeq,

    /// Colours that finished, first place first.
    @Default(<PlayerColor>[]) List<PlayerColor> ranking,

    /// Colours removed during play, in the order they left.
    @Default(<PlayerColor>[]) List<PlayerColor> leavers,

    /// Number of events emitted since the game started.
    @Default(0) int eventSeq,
  }) = _GameState;

  const GameState._();

  /// Reads a state written by `toJson`.
  factory GameState.fromJson(Map<String, dynamic> json) =>
      _$GameStateFromJson(json);

  /// True once the game has ended.
  bool get isOver => phase == GamePhase.gameOver;

  /// The seat for [color], or null when nobody sits there.
  Player? playerOf(PlayerColor color) =>
      players.firstWhereOrNull((p) => p.color == color);

  /// The player with [id], or null.
  Player? playerById(PlayerId id) =>
      players.firstWhereOrNull((p) => p.id == id);

  /// The player whose turn it is.
  Player get currentPlayer => playerOf(currentColor)!;

  /// The four tokens of [color], ordered by id; empty once removed.
  List<Token> tokensOf(PlayerColor color) =>
      tokens.where((t) => t.color == color).sortedBy<num>((t) => t.id);

  /// Colours that still take turns, in clockwise order.
  List<PlayerColor> get activeColors => [
    for (final c in PlayerColor.values)
      if (playerOf(c)?.isActive ?? false) c,
  ];
}

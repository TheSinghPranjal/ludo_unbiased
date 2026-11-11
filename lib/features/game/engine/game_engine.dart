import 'package:collection/collection.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/core/utils/result.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/engine/rule_error.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/models/token.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';
import 'package:ludo_unbiased/features/game/rules/rank_rules.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

/// A committed command: the new state and the events it produced, in order.
typedef Commit = (GameState, List<GameEvent>);

/// The pure, deterministic Ludo rules engine (spec §3.5).
///
/// Every command returns either a [Commit] or a [RuleError]. A rejected
/// command never changes anything: the caller keeps its existing state.
/// Given the same dice, the same commands always produce the same states.
///
/// Successful `roll` and `move` commands leave the state in
/// [GamePhase.animating]; call [settle] once the animation has played. The
/// engine rejects commands while animating, so input is locked for taps, AI,
/// timers and network alike.
abstract final class GameEngine {
  /// A new game for [players] (2–4, unique colours). Red, or the first
  /// seated colour clockwise from Red, rolls first.
  static GameState newGame({
    required String gameId,
    required List<Player> players,
  }) {
    if (players.length < 2 || players.length > 4) {
      throw ArgumentError.value(players.length, 'players', 'must be 2–4');
    }
    final colors = players.map((p) => p.color).toSet();
    if (colors.length != players.length) {
      throw ArgumentError('Each player needs a different colour.');
    }
    if (players.map((p) => p.id).toSet().length != players.length) {
      throw ArgumentError('Each player needs a different id.');
    }
    final seated = PlayerColor.values.where(colors.contains).toList();
    return GameState(
      gameId: gameId,
      players: players.sortedBy<num>((p) => p.color.index),
      tokens: [
        for (final c in seated)
          for (var id = 0; id < 4; id++)
            Token(id: id, color: c, rel: BoardConstants.baseRel),
      ],
      currentColor: seated.first,
      phase: GamePhase.awaitingRoll,
    );
  }

  /// [playerId] rolls the dice.
  ///
  /// A 6 adds to the consecutive count; any other face resets it. The third
  /// consecutive 6 is not played and passes the turn. With legal moves the
  /// player must choose one; with none, a 6 still earns an extra roll and
  /// 1–5 passes the turn.
  static Result<Commit, RuleError> roll(
    GameState state,
    PlayerId playerId,
    DiceService dice,
  ) {
    final rejected = _checkActor(state, playerId);
    if (rejected != null) return Err(rejected);
    if (state.phase != GamePhase.awaitingRoll) {
      return const Err(RuleError.wrongPhase);
    }
    final value = dice.roll();
    if (value < 1 || value > 6) {
      throw StateError('DiceService returned $value');
    }
    final color = state.currentColor;
    final events = <GameEvent>[
      GameEvent.diceRolled(color: color, value: value),
    ];
    final sixes = value == 6 ? state.sixesThisTurn + 1 : 0;
    var next = state.copyWith(
      dice: value,
      sixesThisTurn: sixes,
      players: value == 6
          ? _updateStats(
              state.players,
              color,
              (s) => s.copyWith(sixes: s.sixes + 1),
            )
          : state.players,
    );
    final GamePhase settlesTo;
    if (sixes >= 3) {
      events.add(GameEvent.threeSixesForfeit(color: color));
      next = _passTurn(next, events, TurnPassReason.threeSixes);
      settlesTo = GamePhase.awaitingRoll;
    } else if (movesFor(next, color, value).isNotEmpty) {
      settlesTo = GamePhase.rolled;
    } else if (value == 6) {
      events.add(
        GameEvent.extraRoll(color: color, reason: ExtraRollReason.six),
      );
      next = next.copyWith(dice: null);
      settlesTo = GamePhase.awaitingRoll;
    } else {
      next = _passTurn(next, events, TurnPassReason.noMoves);
      settlesTo = GamePhase.awaitingRoll;
    }
    return Ok(_commit(state, next, settlesTo, events));
  }

  /// [playerId] moves token [tokenId] with the committed dice.
  ///
  /// The move must be one of [legalMoves]. Landing on an unsafe cell captures
  /// every opponent there. A 6, a capture or reaching HOME earns one extra
  /// roll (never more than one). Finishing all four tokens ranks the player
  /// and passes the turn; the game ends when one player is left.
  static Result<Commit, RuleError> move(
    GameState state,
    PlayerId playerId,
    int tokenId,
  ) {
    final rejected = _checkActor(state, playerId);
    if (rejected != null) return Err(rejected);
    if (state.phase != GamePhase.rolled) {
      return const Err(RuleError.wrongPhase);
    }
    if (tokenId < 0 || tokenId > 3) return const Err(RuleError.unknownToken);
    final move = legalMoves(state).firstWhereOrNull(
      (m) => m.tokenId == tokenId,
    );
    if (move == null) return const Err(RuleError.illegalMove);

    final color = state.currentColor;
    final events = <GameEvent>[
      GameEvent.tokenMoved(
        color: color,
        tokenId: tokenId,
        fromRel: move.fromRel,
        toRel: move.toRel,
        path: BoardMap.path(color, move.fromRel, move.toRel),
      ),
    ];
    final captured = move.captures.toSet();
    final at = BoardMap.cellFor(color, move.toRel);
    var tokens = [
      for (final t in state.tokens)
        if (t.color == color && t.id == tokenId)
          t.copyWith(rel: move.toRel)
        else if (captured.contains(TokenRef(color: t.color, id: t.id)))
          t.copyWith(rel: BoardConstants.baseRel)
        else
          t,
    ];
    var players = state.players;
    for (final v in move.captures) {
      events.add(
        GameEvent.tokenCaptured(
          color: v.color,
          tokenId: v.id,
          byColor: color,
          at: at,
        ),
      );
      players = _updateStats(
        players,
        v.color,
        (s) => s.copyWith(timesCaptured: s.timesCaptured + 1),
      );
    }
    if (move.isCapture) {
      players = _updateStats(
        players,
        color,
        (s) => s.copyWith(captures: s.captures + move.captures.length),
      );
    }
    if (move.reachesHome) {
      events.add(GameEvent.tokenHome(color: color, tokenId: tokenId));
      players = _updateStats(
        players,
        color,
        (s) => s.copyWith(tokensHome: s.tokensHome + 1),
      );
    }
    tokens = List.unmodifiable(tokens);
    var next = state.copyWith(tokens: tokens, players: players, dice: null);

    final finished = next.tokensOf(color).every((t) => t.isHome);
    if (finished) {
      final rank = next.ranking.length + 1;
      next = next.copyWith(
        ranking: [...next.ranking, color],
        players: _updatePlayer(
          next.players,
          color,
          (p) => p.copyWith(finishedRank: rank),
        ),
      );
      events.add(GameEvent.playerFinished(color: color, rank: rank));
      if (next.activeColors.length <= 1) {
        next = _endGame(next, events);
        return Ok(_commit(state, next, GamePhase.gameOver, events));
      }
      next = _passTurn(next, events, TurnPassReason.playerFinished);
      return Ok(_commit(state, next, GamePhase.awaitingRoll, events));
    }

    final reason = move.isCapture
        ? ExtraRollReason.capture
        : move.reachesHome
        ? ExtraRollReason.home
        : state.dice == 6
        ? ExtraRollReason.six
        : null;
    if (reason != null) {
      events.add(GameEvent.extraRoll(color: color, reason: reason));
    } else {
      next = _passTurn(next, events, TurnPassReason.turnEnded);
    }
    return Ok(_commit(state, next, GamePhase.awaitingRoll, events));
  }

  /// Moves an animating state into the phase it was waiting for. Any other
  /// state is returned unchanged.
  static GameState settle(GameState state) {
    if (state.phase != GamePhase.animating) return state;
    return state.copyWith(phase: state.nextPhase!, nextPhase: null);
  }

  /// Marks [playerId] connected or disconnected. Turn order is unchanged:
  /// a disconnected player's timer keeps running.
  static Result<Commit, RuleError> setConnection(
    GameState state,
    PlayerId playerId,
    SeatConnection connection,
  ) {
    if (connection == SeatConnection.removed) {
      throw ArgumentError('Use removePlayer to remove a player.');
    }
    final player = state.playerById(playerId);
    if (player == null) return const Err(RuleError.unknownPlayer);
    if (player.isRemoved) return const Err(RuleError.playerRemoved);
    if (player.connection == connection) return const Err(RuleError.noChange);
    final events = [
      GameEvent.playerConnection(color: player.color, connection: connection),
    ];
    final next = state.copyWith(
      players: _updatePlayer(
        state.players,
        player.color,
        (p) => p.copyWith(connection: connection),
      ),
      eventSeq: state.eventSeq + events.length,
    );
    return Ok((next, events));
  }

  /// Removes [playerId] after leaving or after the reconnect grace expired.
  ///
  /// Their tokens leave the board, they rank below everyone who finishes,
  /// and turn order skips them. When one player is left the game ends.
  static Result<Commit, RuleError> removePlayer(
    GameState state,
    PlayerId playerId,
  ) {
    if (state.isOver) return const Err(RuleError.gameOver);
    final player = state.playerById(playerId);
    if (player == null) return const Err(RuleError.unknownPlayer);
    if (player.isRemoved) return const Err(RuleError.playerRemoved);
    final color = player.color;
    final events = <GameEvent>[GameEvent.playerRemoved(color: color)];
    var next = state.copyWith(
      players: _updatePlayer(
        state.players,
        color,
        (p) => p.copyWith(connection: SeatConnection.removed),
      ),
    );
    if (player.isFinished) {
      return Ok((next.copyWith(eventSeq: state.eventSeq + 1), events));
    }
    next = next.copyWith(
      tokens: state.tokens.where((t) => t.color != color).toList(),
      leavers: [...state.leavers, color],
    );
    if (next.activeColors.length <= 1) {
      next = _endGame(next, events);
      return Ok((
        next.copyWith(
          phase: GamePhase.gameOver,
          nextPhase: null,
          turnSeq: state.turnSeq + 1,
          eventSeq: state.eventSeq + events.length,
        ),
        events,
      ));
    }
    if (state.currentColor == color) {
      next = _passTurn(next, events, TurnPassReason.playerRemoved);
      next = next.copyWith(
        phase: GamePhase.awaitingRoll,
        nextPhase: null,
        turnSeq: state.turnSeq + 1,
        eventSeq: state.eventSeq + events.length,
      );
      return Ok((next, events));
    }
    return Ok((
      next.copyWith(eventSeq: state.eventSeq + events.length),
      events,
    ));
  }

  /// An AI at [level] takes over [playerId]'s seat, keeping its tokens.
  static Result<Commit, RuleError> replaceWithAi(
    GameState state,
    PlayerId playerId,
    AiLevel level,
  ) {
    if (state.isOver) return const Err(RuleError.gameOver);
    final player = state.playerById(playerId);
    if (player == null) return const Err(RuleError.unknownPlayer);
    if (player.isRemoved) return const Err(RuleError.playerRemoved);
    final events = [
      GameEvent.playerReplacedByAi(color: player.color, level: level),
    ];
    final next = state.copyWith(
      players: _updatePlayer(
        state.players,
        player.color,
        (p) => p.copyWith(
          kind: PlayerKind.ai,
          aiLevel: level,
          connection: SeatConnection.connected,
        ),
      ),
      eventSeq: state.eventSeq + events.length,
    );
    return Ok((next, events));
  }

  static RuleError? _checkActor(GameState state, PlayerId playerId) {
    if (state.isOver) return RuleError.gameOver;
    final player = state.playerById(playerId);
    if (player == null) return RuleError.unknownPlayer;
    if (player.isRemoved) return RuleError.playerRemoved;
    if (player.color != state.currentColor) return RuleError.notYourTurn;
    return null;
  }

  static Commit _commit(
    GameState before,
    GameState after,
    GamePhase settlesTo,
    List<GameEvent> events,
  ) => (
    after.copyWith(
      phase: GamePhase.animating,
      nextPhase: settlesTo,
      turnSeq: before.turnSeq + 1,
      eventSeq: before.eventSeq + events.length,
    ),
    List.unmodifiable(events),
  );

  static GameState _passTurn(
    GameState state,
    List<GameEvent> events,
    TurnPassReason reason,
  ) {
    final from = state.currentColor;
    var to = from.next;
    while (!(state.playerOf(to)?.isActive ?? false)) {
      if (to == from) break;
      to = to.next;
    }
    events.add(GameEvent.turnPassed(from: from, to: to, reason: reason));
    return state.copyWith(currentColor: to, sixesThisTurn: 0, dice: null);
  }

  static GameState _endGame(GameState state, List<GameEvent> events) {
    final remaining = state.activeColors;
    final ranking = RankRules.finalRanking(
      finishers: state.ranking,
      leavers: state.leavers,
      lastUnfinished: remaining.firstOrNull,
    );
    var players = state.players;
    for (final (i, c) in ranking.indexed) {
      players = _updatePlayer(
        players,
        c,
        (p) => p.copyWith(finishedRank: i + 1),
      );
    }
    events.add(GameEvent.gameOver(ranking: ranking));
    return state.copyWith(ranking: ranking, players: players, dice: null);
  }

  static List<Player> _updatePlayer(
    List<Player> players,
    PlayerColor color,
    Player Function(Player) f,
  ) => [for (final p in players) p.color == color ? f(p) : p];

  static List<Player> _updateStats(
    List<Player> players,
    PlayerColor color,
    PlayerStats Function(PlayerStats) f,
  ) => _updatePlayer(players, color, (p) => p.copyWith(stats: f(p.stats)));
}

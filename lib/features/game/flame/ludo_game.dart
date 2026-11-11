// Flame's Component.add returns FutureOr by design; adding a child is
// fire-and-forget here, and the component mounts on the next tick.
// ignore_for_file: discarded_futures

import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/flame/animation_queue.dart';
import 'package:ludo_unbiased/features/game/flame/board_component.dart';
import 'package:ludo_unbiased/features/game/flame/board_layout.dart';
import 'package:ludo_unbiased/features/game/flame/highlight_component.dart';
import 'package:ludo_unbiased/features/game/flame/sprite_catalog.dart';
import 'package:ludo_unbiased/features/game/flame/token_component.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/rules/board_map.dart';

/// The Flame board (ARCHITECTURE.md §9).
///
/// It draws [GameState]s it is shown and plays engine events through
/// [animations]. It never changes game state: a tap on a movable token calls
/// [onMove], which sends a move request to the controller.
class LudoGame extends FlameGame {
  /// Creates the board.
  LudoGame({
    required this.onMove,
    this.onPickFromStack,
    this.mode = BoardMode.light,
    this.reduceMotion = false,
    this.speed = 1,
  }) : super(world: World(), camera: CameraComponent());

  /// Called with a token id when the player taps a movable token.
  final void Function(int tokenId) onMove;

  /// Called on long-press of a stack holding several movable tokens.
  final void Function(List<int> tokenIds)? onPickFromStack;

  /// Called on each hop, for sound and haptics.
  VoidCallback? onStep;

  /// Called when a capture plays.
  VoidCallback? onCapture;

  /// Called when a token reaches HOME.
  VoidCallback? onHome;

  /// Light or dark sprites; switch at any time.
  BoardMode mode;

  /// Replaces arcs, pulses and particles with plain moves; same timing.
  bool reduceMotion;

  /// Animation speed for hops and FX; 1 is normal.
  double speed;

  /// Loaded sprites for both modes.
  late final SpriteCatalog sprites;

  /// Plays engine events in order.
  late final AnimationQueue animations = AnimationQueue(this);

  final Map<(PlayerColor, int), TokenComponent> _tokens = {};
  final List<GhostComponent> _ghosts = [];
  GameState? _state;
  Set<PlayerColor> _controlled = const {};

  /// Every token on the board.
  Iterable<TokenComponent> get tokens => _tokens.values;

  /// Ghost markers currently shown.
  List<GhostComponent> get ghosts => List.unmodifiable(_ghosts);

  /// The token component for [color] / [id], or null once removed.
  TokenComponent? tokenFor(PlayerColor color, int id) => _tokens[(color, id)];

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    sprites = SpriteCatalog(images);
    await sprites.load();
    camera.viewfinder
      ..visibleGameSize = Vector2.all(BoardLayout.size)
      ..position = Vector2.zero()
      ..anchor = Anchor.topLeft;
    await world.add(BoardComponent());
    final s = _state;
    if (s != null) showState(s, _controlled);
  }

  /// Shows [state]. [controlled] are the colours this device plays, which
  /// get highlights. Tokens that are animating are left to the queue.
  void showState(GameState state, Set<PlayerColor> controlled) {
    _state = state;
    _controlled = controlled;
    if (!isLoaded) return;
    _syncComponents(state);
    if (state.phase != GamePhase.animating && !animations.isBusy) {
      _layout(state);
    }
    _highlight();
  }

  /// Called by the queue when it drains: settle every token in place.
  void onQueueIdle() {
    final s = _state;
    if (s == null || animations.isBusy) return;
    _layout(s);
    _highlight();
  }

  /// A token was tapped: move it, or the lowest movable token in its stack.
  void handleTokenTap(TokenComponent t) {
    final ids = _movableAt(t);
    if (ids.isNotEmpty) onMove(ids.first);
  }

  /// A token was long-pressed: offer a choice when the stack has several.
  void handleTokenLongPress(TokenComponent t) {
    final ids = _movableAt(t);
    if (ids.length > 1 && onPickFromStack != null) {
      onPickFromStack!(ids);
    } else if (ids.isNotEmpty) {
      onMove(ids.first);
    }
  }

  List<int> _movableAt(TokenComponent t) {
    final s = _state;
    if (s == null) return const [];
    final here = t.position;
    return tokens
        .where(
          (o) =>
              o.color == s.currentColor &&
              o.movable &&
              o.position.distanceTo(here) < 0.45,
        )
        .map((o) => o.tokenId)
        .sorted((a, b) => a.compareTo(b));
  }

  void _syncComponents(GameState s) {
    final wanted = {for (final t in s.tokens) (t.color, t.id)};
    for (final key in _tokens.keys.toList()) {
      if (!wanted.contains(key)) _tokens.remove(key)!.removeFromParent();
    }
    for (final t in s.tokens) {
      _tokens.putIfAbsent((t.color, t.id), () {
        final c = TokenComponent(color: t.color, tokenId: t.id)
          ..position = BoardLayout.restingPlace(t);
        world.add(c);
        return c;
      });
    }
  }

  void _layout(GameState s) {
    final groups = groupBy(
      s.tokens,
      (t) => t.isInBase
          ? 'base-${t.color.name}-${t.id}'
          : BoardMap.cellFor(t.color, t.rel).toString(),
    );
    for (final group in groups.values) {
      final offsets = BoardLayout.stackOffsets(group.length);
      final size = BoardLayout.stackTokenSize(group.length);
      for (final (i, t) in group.indexed) {
        final c = _tokens[(t.color, t.id)];
        if (c == null || c.animating) continue;
        c
          ..position = BoardLayout.restingPlace(t) + offsets[i % offsets.length]
          ..size = Vector2.all(size)
          ..stackCount = group.length
          ..showsBadge = i == group.length - 1;
      }
    }
  }

  void _highlight() {
    for (final g in _ghosts) {
      g.removeFromParent();
    }
    _ghosts.clear();
    for (final t in tokens) {
      t.movable = false;
    }
    final s = _state;
    if (s == null ||
        s.phase != GamePhase.rolled ||
        animations.isBusy ||
        !_controlled.contains(s.currentColor)) {
      return;
    }
    final seen = <BoardCell>{};
    for (final m in legalMoves(s)) {
      _tokens[(s.currentColor, m.tokenId)]?.movable = true;
      final cell = BoardMap.cellFor(s.currentColor, m.toRel);
      if (seen.add(cell)) {
        final g = GhostComponent(
          color: s.currentColor,
          at: BoardLayout.centreOf(cell),
        );
        _ghosts.add(g);
        world.add(g);
      }
    }
  }
}

import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:ludo_unbiased/features/game/controllers/game_controller.dart';
import 'package:ludo_unbiased/features/game/flame/flame_animation_gate.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/flame/sprite_catalog.dart';
import 'package:ludo_unbiased/features/game/services/animation_gate.dart';

/// Hosts the Flame board for [controller] and keeps it in step with the
/// controller's state, the theme and the app lifecycle.
class BoardView extends StatefulWidget {
  /// Creates the view.
  const BoardView({
    required this.controller,
    this.onPickFromStack,
    this.diceLanded,
    this.speed = 1,
    super.key,
  });

  /// The game being shown.
  final GameController controller;

  /// Long-press on a stack with several movable tokens.
  final void Function(List<int> tokenIds)? onPickFromStack;

  /// Completes when the dice widget has landed; see [FlameAnimationGate].
  final Future<void> Function()? diceLanded;

  /// Animation speed for hops and FX.
  final double speed;

  @override
  State<BoardView> createState() => BoardViewState();
}

/// State for [BoardView]; exposes the game for the screen and tests.
class BoardViewState extends State<BoardView> with WidgetsBindingObserver {
  /// The Flame game.
  late final LudoGame game;

  GameController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    game = LudoGame(
      onMove: (id) => unawaited(_c.requestMove(id)),
      onPickFromStack: widget.onPickFromStack,
      speed: widget.speed,
    );
    _c.state.addListener(_sync);
    WidgetsBinding.instance.addObserver(this);
    _bindBoardGate();
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game
      ..mode = Theme.of(context).brightness == Brightness.dark
          ? BoardMode.dark
          : BoardMode.light
      ..reduceMotion = MediaQuery.disableAnimationsOf(context);
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    game.speed = widget.speed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bindBoardGate();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Flame stops ticking in the background; never let the game wait on it.
      _c.bindAnimationGate(const TimedAnimationGate());
      game.animations.flush();
    }
  }

  void _bindBoardGate() => _c.bindAnimationGate(
    FlameAnimationGate(game, diceLanded: widget.diceLanded),
  );

  void _sync() => game.showState(_c.state.value, _c.controlledColors);

  @override
  void dispose() {
    _c.state.removeListener(_sync);
    WidgetsBinding.instance.removeObserver(this);
    _c.bindAnimationGate(const TimedAnimationGate());
    game.animations.flush();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GameWidget(game: game),
    );
  }
}

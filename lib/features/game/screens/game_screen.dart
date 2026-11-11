import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/features/game/controllers/game_controller.dart';
import 'package:ludo_unbiased/features/game/controllers/local_game_controller.dart';
import 'package:ludo_unbiased/features/game/engine/legal_moves.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/status_messages.dart';
import 'package:ludo_unbiased/features/game/widgets/basic_board.dart';

/// The Game screen. Milestone 4 replaces the layout with the full design.
class GameScreen extends ConsumerWidget {
  /// Creates the screen.
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(activeGameProvider);
    if (controller == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Back to Home'),
          ),
        ),
      );
    }
    return _GameView(key: ObjectKey(controller), controller: controller);
  }
}

class _GameView extends ConsumerStatefulWidget {
  const _GameView({required this.controller, super.key});

  final GameController controller;

  @override
  ConsumerState<_GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<_GameView> {
  late final StreamSubscription<List<GameEvent>> _sub;
  String _status = '';
  int? _lastDice;

  GameController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _status = "${c.state.value.currentPlayer.name}'s turn";
    _sub = c.events.listen((events) {
      final text = statusFor(events, c.state.value);
      final dice = events.whereType<DiceRolled>().lastOrNull;
      setState(() {
        if (text != null) _status = text;
        if (dice != null) _lastDice = dice.value;
      });
    });
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    super.dispose();
  }

  Future<void> _openPause() async {
    c.pause();
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paused'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave game'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Resume'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (leave ?? false) {
      ref.read(activeGameProvider.notifier).end();
      context.go('/');
    } else {
      c.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<GameState>(
          valueListenable: c.state,
          builder: (context, s, _) {
            final mine = c.controlledColors.contains(s.currentColor);
            final movable = mine
                ? legalMoves(s).map((m) => m.tokenId).toSet()
                : <int>{};
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton.outlined(
                        tooltip: 'Pause',
                        onPressed: s.isOver ? null : _openPause,
                        icon: const Icon(Icons.pause),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<int>(
                        valueListenable: c.remainingMs,
                        builder: (context, ms, _) => Text(
                          s.isOver ? '' : '${(ms / 1000).ceil()} s',
                          style: TextStyle(color: colors.text2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _Seats(state: s),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: BasicBoard(
                        state: s,
                        movable: movable,
                        onTokenTap: c.requestMove,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    key: const Key('status'),
                    style: TextStyle(color: colors.text, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (s.isOver)
                    _Results(state: s, controller: c)
                  else
                    FilledButton.icon(
                      key: const Key('roll'),
                      onPressed: mine && s.phase == GamePhase.awaitingRoll
                          ? c.requestRoll
                          : null,
                      icon: const Icon(Icons.casino),
                      label: Text(
                        _lastDice == null ? 'Roll' : 'Roll  (last $_lastDice)',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Seats extends StatelessWidget {
  const _Seats({required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.board;
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (final p in state.players)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: palette.of(p.color),
                width: p.color == state.currentColor ? 3 : 1,
              ),
            ),
            child: Text(
              '${p.color.symbol} ${p.name}'
              '${p.kind == PlayerKind.ai ? ' (AI)' : ''} '
              '· ${p.stats.tokensHome}/4',
              style: TextStyle(color: colors.text),
            ),
          ),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.state, required this.controller});

  final GameState state;
  final GameController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = controller;
    return Column(
      children: [
        for (final (i, color) in state.ranking.indexed)
          Text('${i + 1}. ${state.playerOf(color)!.name}'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (c is LocalGameController)
              FilledButton(
                onPressed: () =>
                    ref.read(activeGameProvider.notifier).startLocal(c.seats),
                child: const Text('Play Again'),
              ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                ref.read(activeGameProvider.notifier).end();
                context.go('/');
              },
              child: const Text('Home'),
            ),
          ],
        ),
      ],
    );
  }
}

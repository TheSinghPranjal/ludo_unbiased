import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/features/game/controllers/local_game_controller.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// Local Setup: player count and, per seat, name and Human or AI.
class LocalSetupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const LocalSetupScreen({super.key});

  @override
  ConsumerState<LocalSetupScreen> createState() => _LocalSetupScreenState();
}

class _LocalSetupScreenState extends ConsumerState<LocalSetupScreen> {
  int _count = 4;
  final Map<PlayerColor, TextEditingController> _names = {
    for (final c in PlayerColor.values) c: TextEditingController(),
  };
  bool _named = false;
  final Map<PlayerColor, PlayerKind> _kinds = {
    for (final c in PlayerColor.values) c: PlayerKind.human,
  };
  final Map<PlayerColor, AiLevel> _levels = {
    for (final c in PlayerColor.values) c: AiLevel.normal,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Default names are the colour names in the app's language.
    if (_named) return;
    _named = true;
    final l = context.l10n;
    for (final MapEntry(key: c, value: t) in _names.entries) {
      t.text = l.colorName(c);
    }
  }

  @override
  void dispose() {
    for (final t in _names.values) {
      t.dispose();
    }
    super.dispose();
  }

  void _start() {
    final seats = <SeatConfig>[
      for (final c in PlayerColor.defaultSeats(_count))
        (
          color: c,
          name: _names[c]!.text.trim().isEmpty
              ? context.l10n.colorName(c)
              : _names[c]!.text.trim(),
          kind: _kinds[c]!,
          aiLevel: _kinds[c] == PlayerKind.ai ? _levels[c] : null,
        ),
    ];
    ref.read(activeGameProvider.notifier).startLocal(seats);
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final seats = PlayerColor.defaultSeats(_count);
    final l = context.l10n;
    // Android back returns Home instead of closing the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.localGame),
          leading: BackButton(onPressed: () => context.go('/')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 4, label: Text('4')),
              ],
              selected: {_count},
              onSelectionChanged: (s) => setState(() => _count = s.first),
            ),
            const SizedBox(height: 16),
            for (final c in seats)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _names[c],
                        maxLength: 16,
                        decoration: InputDecoration(
                          labelText: [
                            c.symbol,
                            l.playerNameLabel(l.colorName(c)),
                          ].join(' '),
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<PlayerKind>(
                        segments: [
                          ButtonSegment(
                            value: PlayerKind.human,
                            label: Text(l.human),
                          ),
                          ButtonSegment(
                            value: PlayerKind.ai,
                            label: Text(l.ai),
                          ),
                        ],
                        selected: {_kinds[c]!},
                        onSelectionChanged: (s) =>
                            setState(() => _kinds[c] = s.first),
                      ),
                      if (_kinds[c] == PlayerKind.ai) ...[
                        const SizedBox(height: 8),
                        SegmentedButton<AiLevel>(
                          segments: [
                            ButtonSegment(
                              value: AiLevel.easy,
                              label: Text(l.easy),
                            ),
                            ButtonSegment(
                              value: AiLevel.normal,
                              label: Text(l.normal),
                            ),
                          ],
                          selected: {_levels[c]!},
                          onSelectionChanged: (s) =>
                              setState(() => _levels[c] = s.first),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('startGame'),
              onPressed: _start,
              child: Text(l.startGame),
            ),
          ],
        ),
      ),
    );
  }
}

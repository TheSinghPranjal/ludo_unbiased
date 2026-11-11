import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';

/// Home: start or continue a game.
class HomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSave = ref.watch(savedGameRepositoryProvider).hasSave;
    final game = ref.read(activeGameProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Ludo Unbiased',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 32),
                if (hasSave) ...[
                  FilledButton.tonal(
                    onPressed: () {
                      if (game.resumeSaved()) context.go('/game');
                    },
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  key: const Key('quickPlay'),
                  onPressed: () {
                    game.startLocal(const [
                      (
                        color: PlayerColor.red,
                        name: 'You',
                        kind: PlayerKind.human,
                        aiLevel: null,
                      ),
                      (
                        color: PlayerColor.yellow,
                        name: 'Moss',
                        kind: PlayerKind.ai,
                        aiLevel: AiLevel.normal,
                      ),
                    ]);
                    context.go('/game');
                  },
                  child: const Text('Quick Play vs AI'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/local-setup'),
                  child: const Text('Play Local'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

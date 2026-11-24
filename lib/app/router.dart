import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/features/game/screens/game_screen.dart';
import 'package:ludo_unbiased/features/help/how_to_play_screen.dart';
import 'package:ludo_unbiased/features/home/home_screen.dart';
import 'package:ludo_unbiased/features/home/local_setup_screen.dart';
import 'package:ludo_unbiased/features/settings/screens/settings_screen.dart';

/// App routes (ARCHITECTURE.md §10). Settings and How to Play are pushed,
/// so Back returns to wherever they were opened from, including a game.
GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/local-setup', builder: (_, _) => const LocalSetupScreen()),
    GoRoute(path: '/game', builder: (_, _) => const GameScreen()),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/how-to-play', builder: (_, _) => const HowToPlayScreen()),
  ],
);

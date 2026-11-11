import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/features/game/screens/game_screen.dart';
import 'package:ludo_unbiased/features/home/home_screen.dart';
import 'package:ludo_unbiased/features/home/local_setup_screen.dart';

/// App routes (ARCHITECTURE.md §10).
GoRouter buildRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/local-setup', builder: (_, _) => const LocalSetupScreen()),
    GoRoute(path: '/game', builder: (_, _) => const GameScreen()),
  ],
);

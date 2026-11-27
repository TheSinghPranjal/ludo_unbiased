import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/app/widgets/fade_slide_in.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// Home: start or continue a game, over the illustrated title scene.
class HomeScreen extends ConsumerWidget {
  /// Creates the screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSave = ref.watch(savedGameRepositoryProvider).hasSave;
    final game = ref.read(activeGameProvider.notifier);
    final l = context.l10n;
    var i = 0;
    Widget enter(Widget w) => FadeSlideIn.staggered(index: i++, child: w);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/backgrounds/home_bg.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
            // The art already carries the title; this names it for readers.
            Semantics(header: true, label: l.appTitle),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        enter(
                          HomeButton(
                            key: const Key('quickPlay'),
                            style: HomeButtonStyle.gold,
                            label: l.newGame,
                            leading: const PlayTriangle(),
                            onPressed: () {
                              game.startLocal([
                                (
                                  color: PlayerColor.red,
                                  name: l.you,
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
                          ),
                        ),
                        if (hasSave) ...[
                          const SizedBox(height: 16),
                          enter(
                            HomeButton(
                              key: const Key('continueGame'),
                              style: HomeButtonStyle.blue,
                              compact: true,
                              label: l.continueGame,
                              leading: Icon(
                                Icons.history_rounded,
                                size: 28,
                                color: context.scene.onButton,
                              ),
                              onPressed: () {
                                if (game.resumeSaved()) context.go('/game');
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        enter(
                          HomeButton(
                            style: HomeButtonStyle.outline,
                            label: l.playLocal,
                            leading: Icon(
                              Icons.groups_rounded,
                              size: 36,
                              color: context.scene.onGhost,
                            ),
                            onPressed: () => context.go('/local-setup'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        enter(
                          Row(
                            children: [
                              Expanded(
                                child: HomeButton(
                                  key: const Key('openSettings'),
                                  style: HomeButtonStyle.outline,
                                  compact: true,
                                  label: l.settings,
                                  leading: Icon(
                                    Icons.settings_rounded,
                                    size: 26,
                                    color: context.scene.onGhost,
                                  ),
                                  onPressed: () => unawaited(
                                    context.push<void>('/settings'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: HomeButton(
                                  key: const Key('openHowToPlay'),
                                  style: HomeButtonStyle.outline,
                                  compact: true,
                                  label: l.howToPlay,
                                  leading: Icon(
                                    Icons.menu_book_rounded,
                                    size: 26,
                                    color: context.scene.onGhost,
                                  ),
                                  onPressed: () => unawaited(
                                    context.push<void>('/how-to-play'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The three looks of a Home button.
enum HomeButtonStyle {
  /// Gold call to action (New Game).
  gold,

  /// Glossy blue (Continue).
  blue,

  /// White, outlined (Play Local).
  outline,
}

/// A big rounded Home button with an icon and a label.
class HomeButton extends ConsumerStatefulWidget {
  /// Creates the button.
  const HomeButton({
    required this.style,
    required this.label,
    required this.leading,
    required this.onPressed,
    this.compact = false,
    super.key,
  });

  /// Smaller height and text, for the secondary row.
  final bool compact;

  /// Look.
  final HomeButtonStyle style;

  /// Label.
  final String label;

  /// Icon before the label.
  final Widget leading;

  /// Tap handler.
  final VoidCallback onPressed;

  @override
  ConsumerState<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends ConsumerState<HomeButton> {
  bool _down = false;

  void _tap() {
    ref.read(audioServiceProvider).play(Sfx.uiTap);
    ref.read(hapticsProvider).tick();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final (List<Color>? fill, Color text, Color edge) = switch (widget.style) {
      HomeButtonStyle.gold => ([s.ctaTop, s.ctaBottom], s.onCta, s.goldDark),
      HomeButtonStyle.blue => (
        [s.buttonTop, s.buttonBottom],
        s.onButton,
        s.buttonBottom,
      ),
      HomeButtonStyle.outline => (null, s.onGhost, s.onGhost),
    };
    final height = widget.compact
        ? 52.0
        : widget.style == HomeButtonStyle.gold
        ? 70.0
        : 62.0;
    final radius = BorderRadius.circular(height / 2);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _tap,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? .96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: radius,
              color: fill == null ? s.ghost : null,
              gradient: fill == null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: fill,
                    ),
              border: Border.all(
                color: edge,
                width: fill == null ? 2.5 : 3,
              ),
              boxShadow: [
                if (fill != null)
                  BoxShadow(
                    color: fill.last.withValues(alpha: .45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                BoxShadow(
                  color: s.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Glossy top highlight.
                if (fill != null)
                  Positioned(
                    left: 18,
                    right: 18,
                    top: 5,
                    height: height * .32,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: s.onButton.withValues(alpha: .28),
                      ),
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.compact ? 12 : 20,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.leading,
                          SizedBox(width: widget.compact ? 8 : 16),
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontWeight: FontWeight.w700,
                              fontSize: widget.compact
                                  ? 18
                                  : widget.style == HomeButtonStyle.gold
                                  ? 30
                                  : 24,
                              color: text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Red play triangle with a navy outline, for gold call-to-action buttons.
class PlayTriangle extends StatelessWidget {
  /// Creates the icon.
  const PlayTriangle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.play_arrow_rounded, size: 50, color: s.onCta),
        Icon(Icons.play_arrow_rounded, size: 42, color: s.ctaIcon),
      ],
    );
  }
}

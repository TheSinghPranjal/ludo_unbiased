import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// Display font for the Game screen's chrome.
const _display = 'Fredoka';

/// Outlined, two-tone game title.
class GameTitle extends StatelessWidget {
  /// Creates the title.
  const GameTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    Widget word(String text, double size, Color fill) => Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: _display,
            fontWeight: FontWeight.w700,
            fontSize: size,
            height: 1,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * .18
              ..strokeJoin = StrokeJoin.round
              ..color = s.titleStroke,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontFamily: _display,
            fontWeight: FontWeight.w700,
            fontSize: size,
            height: 1,
            color: fill,
            shadows: [
              Shadow(color: s.shadow, offset: const Offset(0, 2)),
            ],
          ),
        ),
      ],
    );
    return Semantics(
      header: true,
      label: context.l10n.appTitle,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            word('Ludo', 30, s.titleFill),
            const SizedBox(height: 2),
            word('Unbiased', 20, s.titleFill2),
          ],
        ),
      ),
    );
  }
}

/// Round glossy icon button (Pause).
class GlossyCircleButton extends StatelessWidget {
  /// Creates the button.
  const GlossyCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 52,
    super.key,
  });

  /// Icon.
  final IconData icon;

  /// Tooltip and semantics label.
  final String tooltip;

  /// Tap handler; null disables.
  final VoidCallback? onPressed;

  /// Diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final on = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: _Pressable(
        onPressed: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: s.onButton, width: 3),
            gradient: RadialGradient(
              center: const Alignment(-.3, -.5),
              radius: .9,
              colors: on
                  ? [s.buttonTop, s.buttonBottom]
                  : [s.disabledTop, s.disabledBottom],
            ),
            boxShadow: [
              BoxShadow(
                color: s.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: s.onButton, size: size * .5),
        ),
      ),
    );
  }
}

/// Rounded-square glossy button with a gold rim (side controls).
class GlossySquareButton extends StatelessWidget {
  /// Creates the button.
  const GlossySquareButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 60,
    super.key,
  });

  /// Icon.
  final IconData icon;

  /// Tooltip and semantics label.
  final String tooltip;

  /// Tap handler; null disables.
  final VoidCallback? onPressed;

  /// Edge length.
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final on = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: _Pressable(
        onPressed: onPressed,
        child: _GoldRim(
          radius: size * .3,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * .26),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: on
                    ? [s.sideTop, s.sideBottom]
                    : [s.disabledTop, s.disabledBottom],
              ),
            ),
            child: Icon(icon, color: s.onButton, size: size * .52),
          ),
        ),
      ),
    );
  }
}

/// Timer chip: stopwatch and seconds left.
class TimerChip extends StatelessWidget {
  /// Creates the chip.
  const TimerChip({required this.seconds, super.key});

  /// Seconds left.
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return Semantics(
      label: context.l10n.turnTimer(seconds),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 14, 6),
        decoration: BoxDecoration(
          color: s.hud,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: s.onHud.withValues(alpha: .7), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: s.titleFill, size: 22),
            const SizedBox(width: 6),
            ExcludeSemantics(
              child: Text(
                '$seconds s',
                style: TextStyle(
                  fontFamily: _display,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: s.onHud,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar asset for [p]: the robot for AI seats, an animal per colour else.
String avatarFor(Player p) {
  if (p.kind == PlayerKind.ai) return 'assets/images/cards/avatar_09_robot.png';
  return switch (p.color) {
    PlayerColor.red => 'assets/images/cards/avatar_01_fox.png',
    PlayerColor.blue => 'assets/images/cards/avatar_02_owl.png',
    PlayerColor.yellow => 'assets/images/cards/avatar_11_chick.png',
    PlayerColor.green => 'assets/images/cards/avatar_05_frog.png',
  };
}

/// A player's pill: avatar, symbol, name and tokens home.
class SeatPill extends StatelessWidget {
  /// Creates the pill.
  const SeatPill({required this.player, required this.active, super.key});

  /// The seat.
  final Player player;

  /// True on the current player's turn.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final colour = context.board.of(player.color);
    final p = player;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(3, 3, 14, 3),
      decoration: BoxDecoration(
        color: s.pill,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colour, width: active ? 4 : 2),
        boxShadow: [
          if (active)
            BoxShadow(color: colour.withValues(alpha: .6), blurRadius: 12),
          BoxShadow(
            color: s.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: p.isActive || p.isFinished ? 1 : .55,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colour, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(avatarFor(p), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${p.color.symbol} ${p.name}'
                '${p.kind == PlayerKind.ai ? ' ${context.l10n.aiSuffix}' : ''} '
                '· ${p.stats.tokensHome}/4',
                style: TextStyle(
                  fontFamily: _display,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: s.onPill,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The turn banner with rays on both sides.
class TurnBanner extends StatelessWidget {
  /// Creates the banner.
  const TurnBanner({required this.text, required this.textKey, super.key});

  /// Status text.
  final String text;

  /// Key for the text widget (tests look it up).
  final Key textKey;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Rays(color: s.goldLight, mirrored: true),
        const SizedBox(width: 6),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: BoxDecoration(
              color: s.banner,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: s.goldLight, width: 2),
              boxShadow: [
                BoxShadow(
                  color: s.goldLight.withValues(alpha: .5),
                  blurRadius: 14,
                ),
              ],
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                // Only the incoming line keeps its place in the layout.
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final p in previous) Positioned.fill(child: p),
                    ?current,
                  ],
                ),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, .35),
                      end: Offset.zero,
                    ).animate(a),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(text),
                  child: Text(
                    text,
                    key: textKey,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: _display,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: s.onBanner,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _Rays(color: s.goldLight, mirrored: false),
      ],
    );
  }
}

class _Rays extends StatelessWidget {
  const _Rays({required this.color, required this.mirrored});

  final Color color;
  final bool mirrored;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 18,
    height: 30,
    child: CustomPaint(painter: _RaysPainter(color, flip: mirrored)),
  );
}

class _RaysPainter extends CustomPainter {
  _RaysPainter(this.color, {required this.flip});

  final Color color;
  final bool flip;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final x0 = flip ? size.width : 0.0;
    final x1 = flip ? 2.0 : size.width - 2;
    final h = size.height;
    canvas
      ..drawLine(Offset(x0, h * .5), Offset(x1, h * .5), p)
      ..drawLine(Offset(x0, h * .4), Offset(x1, h * .1), p)
      ..drawLine(Offset(x0, h * .6), Offset(x1, h * .9), p);
  }

  @override
  bool shouldRepaint(_RaysPainter old) =>
      old.color != color || old.flip != flip;
}

/// Big glossy pill with a gold rim: the Roll button. Its dice tumbles for
/// [Timing.diceAnimation] each time [rollSerial] changes, then lands on
/// [diceFace].
class RollButton extends StatefulWidget {
  /// Creates the button.
  const RollButton({
    required this.onPressed,
    required this.diceFace,
    this.rollSerial = 0,
    this.onLanded,
    super.key,
  });

  /// Tap handler; null when it is not this device's roll.
  final VoidCallback? onPressed;

  /// Face shown at rest (the last roll, or 5).
  final int diceFace;

  /// Bumped by the screen on every roll; a change starts the tumble.
  final int rollSerial;

  /// Called when the tumble ends.
  final VoidCallback? onLanded;

  @override
  State<RollButton> createState() => _RollButtonState();
}

class _RollButtonState extends State<RollButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tumble =
      AnimationController(vsync: this, duration: Timing.diceAnimation)
        ..addListener(_cycleFace)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) {
            setState(() => _shownFace = widget.diceFace);
            widget.onLanded?.call();
          }
        });
  final _random = Random();
  late int _shownFace = widget.diceFace;
  int _lastStep = -1;

  @override
  void didUpdateWidget(RollButton old) {
    super.didUpdateWidget(old);
    if (widget.rollSerial != old.rollSerial) {
      _lastStep = -1;
      unawaited(_tumble.forward(from: 0));
    } else if (!_tumble.isAnimating) {
      _shownFace = widget.diceFace;
    }
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  /// Flicks through faces, slowing down as the dice settles. With reduced
  /// motion the face only changes when it lands; the timing is the same.
  void _cycleFace() {
    if (_reduceMotion || _tumble.value >= 1) return;
    // Eased progress bunches the flicks early and spreads them out late.
    final step = (Curves.easeOutCubic.transform(_tumble.value) * 12).floor();
    if (step == _lastStep) return;
    _lastStep = step;
    var next = _random.nextInt(6) + 1;
    if (next == _shownFace) next = next % 6 + 1;
    setState(() => _shownFace = next);
  }

  @override
  void dispose() {
    _tumble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final on = widget.onPressed != null;
    final mode = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    final label = context.l10n.roll;
    return Semantics(
      label: label,
      child: _Pressable(
        onPressed: widget.onPressed,
        child: _GoldRim(
          radius: 40,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: on
                    ? [s.buttonTop, s.buttonBottom]
                    : [s.disabledTop, s.disabledBottom],
              ),
            ),
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _tumble,
                      builder: (context, child) {
                        if (!_tumble.isAnimating || _reduceMotion) {
                          return child!;
                        }
                        final t = _tumble.value;
                        // Two decelerating turns and a hop that settles.
                        final hop = sin(t * pi);
                        return Transform.translate(
                          offset: Offset(0, -10 * hop),
                          child: Transform.rotate(
                            angle: Curves.easeOutCubic.transform(t) * 4 * pi,
                            child: Transform.scale(
                              scale: 1 + .18 * hop,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/dice/dice_face_${_shownFace}_$mode.png',
                        width: 42,
                        height: 42,
                        gaplessPlayback: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: _display,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        color: s.onButton,
                        shadows: [
                          Shadow(color: s.shadow, offset: const Offset(0, 2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold frame around the board.
class BoardFrame extends StatelessWidget {
  /// Creates the frame.
  const BoardFrame({required this.child, super.key});

  /// The board.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [s.goldLight, s.goldDark, s.goldLight, s.goldDark],
            stops: const [0, .4, .7, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: s.shadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: child,
        ),
      ),
    );
  }
}

/// A cream panel with a gold rim (results, dialogs).
class GoldPanel extends StatelessWidget {
  /// Creates the panel.
  const GoldPanel({required this.child, super.key});

  /// Contents.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return _GoldRim(
      radius: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.banner,
          borderRadius: BorderRadius.circular(18),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontFamily: _display,
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: s.onBanner,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A smaller glossy pill button with a text label.
class GlossyPillButton extends StatelessWidget {
  /// Creates the button.
  const GlossyPillButton({
    required this.label,
    required this.onPressed,
    this.secondary = false,
    super.key,
  });

  /// Label.
  final String label;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Uses the side-button colours.
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return Semantics(
      child: _Pressable(
        onPressed: onPressed,
        child: _GoldRim(
          radius: 26,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: secondary
                    ? [s.sideTop, s.sideBottom]
                    : [s.buttonTop, s.buttonBottom],
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: _display,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: s.onButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldRim extends StatelessWidget {
  const _GoldRim({required this.radius, required this.child});

  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [s.goldLight, s.goldDark],
        ),
        boxShadow: [
          BoxShadow(
            color: s.shadow,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Shrinks slightly while pressed, dims when disabled, and gives a tap
/// sound and tick.
class _Pressable extends ConsumerStatefulWidget {
  const _Pressable({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  ConsumerState<_Pressable> createState() => _PressableState();
}

class _PressableState extends ConsumerState<_Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  void _tap() {
    final f = widget.onPressed;
    if (f == null) return;
    ref.read(audioServiceProvider).play(Sfx.uiTap);
    ref.read(hapticsProvider).tick();
    f();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: on,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: on ? _tap : null,
        onTapDown: on ? (_) => _set(true) : null,
        onTapUp: on ? (_) => _set(false) : null,
        onTapCancel: on ? () => _set(false) : null,
        child: AnimatedScale(
          scale: _down ? .94 : 1,
          duration: Duration(milliseconds: _down ? 80 : 180),
          curve: _down ? Curves.easeOut : Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: on ? 1 : .7,
            duration: const Duration(milliseconds: 200),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

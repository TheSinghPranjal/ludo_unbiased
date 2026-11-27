import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/app/widgets/laurel.dart';
import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// Display font for the Game screen's chrome.
const _display = 'Fredoka';

/// Outlined game title: a crown over "Ludo", "Unbiased" on a purple
/// ribbon, framed by laurels.
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Laurel(
              color: s.hillNear,
              mirrored: false,
              width: 18,
              height: 44,
            ),
            const SizedBox(width: 2),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 22,
                  child: CustomPaint(
                    painter: _CrownPainter(s.goldLight, s.goldDark, s.ctaIcon),
                  ),
                ),
                word('Ludo', 32, s.titleFill),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: s.titleStroke, width: 2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [s.sideTop, s.sideBottom],
                    ),
                  ),
                  child: word('Unbiased', 18, s.titleFill2),
                ),
              ],
            ),
            const SizedBox(width: 2),
            Laurel(
              color: s.hillNear,
              mirrored: true,
              width: 18,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  _CrownPainter(this.light, this.dark, this.jewel);

  final Color light;
  final Color dark;
  final Color jewel;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Path()
      ..moveTo(w * .1, h * .95)
      ..lineTo(w * .04, h * .3)
      ..lineTo(w * .3, h * .6)
      ..lineTo(w * .5, h * .12)
      ..lineTo(w * .7, h * .6)
      ..lineTo(w * .96, h * .3)
      ..lineTo(w * .9, h * .95)
      ..close();
    canvas
      ..drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [light, dark],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        body,
        Paint()
          ..color = dark
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeJoin = StrokeJoin.round,
      );
    final ball = Paint()..color = light;
    for (final x in const [.04, .5, .96]) {
      canvas.drawCircle(Offset(w * x, h * (x == .5 ? .12 : .3)), 2.6, ball);
    }
    canvas.drawCircle(Offset(w * .5, h * .72), 3, Paint()..color = jewel);
  }

  @override
  bool shouldRepaint(_CrownPainter old) =>
      old.light != light || old.dark != dark || old.jewel != jewel;
}

/// A small stack of gold coins (decoration on seat pills and the stage).
class CoinStack extends StatelessWidget {
  /// Creates the stack.
  const CoinStack({this.size = 24, this.coins = 3, super.key});

  /// Width; height follows the number of coins.
  final double size;

  /// Number of coins in the stack.
  final int coins;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size * (.42 + coins * .2),
        child: CustomPaint(
          painter: _CoinsPainter(coins, s.goldLight, s.goldDark),
        ),
      ),
    );
  }
}

class _CoinsPainter extends CustomPainter {
  _CoinsPainter(this.coins, this.light, this.dark);

  final int coins;
  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final ch = w * .42;
    final step = w * .2;
    for (var i = 0; i < coins; i++) {
      final top = size.height - ch - step - i * step;
      final face = Rect.fromLTWH(0, top, w, ch);
      // Rim (the coin's edge), then its face.
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, top + ch / 2, w, step),
            Radius.circular(w * .1),
          ),
          Paint()..color = dark,
        )
        ..drawOval(face.translate(0, step), Paint()..color = dark)
        ..drawOval(
          face,
          Paint()
            ..shader = LinearGradient(
              colors: [light, dark],
            ).createShader(face),
        )
        ..drawOval(
          face.deflate(w * .12),
          Paint()
            ..color = dark.withValues(alpha: .45)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
    }
  }

  @override
  bool shouldRepaint(_CoinsPainter old) =>
      old.coins != coins || old.light != light || old.dark != dark;
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
    final style = TextStyle(
      fontFamily: _display,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: s.onPill,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(3, 3, 10, 3),
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
            const SizedBox(width: 6),
            // The name shortens to fit; the score always shows.
            Flexible(
              child: Text(
                '${p.color.symbol} ${p.name}'
                '${p.kind == PlayerKind.ai ? ' ${context.l10n.aiSuffix}' : ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
            Text(' · ${p.stats.tokensHome}/4', style: style),
            const SizedBox(width: 4),
            const CoinStack(size: 18),
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

/// The stage under the board: the last roll's dice in a burst of light,
/// flanked by the four pawns and stacks of coins.
class DiceStage extends StatelessWidget {
  /// Creates the stage.
  const DiceStage({required this.face, super.key});

  /// Dice face to show (1-6).
  final int face;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final mode = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, box) {
          final h = min<double>(box.maxHeight, 120);
          final dice = h * 1.05;
          final pawn = h * .95;
          // The pawn art is narrow within its square: crop the sides.
          Widget token(PlayerColor c) => Image.asset(
            'assets/images/tokens/token_${c.name}_idle_$mode.png',
            width: pawn * .62,
            height: pawn,
            fit: BoxFit.cover,
          );
          return Center(
            child: SizedBox(
              height: h,
              child: FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    token(PlayerColor.red),
                    token(PlayerColor.blue),
                    CoinStack(size: h * .36),
                    SizedBox(width: h * .08),
                    SizedBox(
                      width: dice * 1.15,
                      height: h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          OverflowBox(
                            maxWidth: h * 1.8,
                            maxHeight: h * 1.8,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    s.goldLight,
                                    s.goldLight.withValues(alpha: .5),
                                    s.goldLight.withValues(alpha: 0),
                                  ],
                                  stops: const [0, .35, 1],
                                ),
                              ),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 260),
                            transitionBuilder: (child, a) =>
                                ScaleTransition(scale: a, child: child),
                            child: Image.asset(
                              'assets/images/dice/dice_face_${face}_$mode.png',
                              key: ValueKey(face),
                              width: dice,
                              height: dice,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: h * .08),
                    CoinStack(size: h * .36),
                    token(PlayerColor.green),
                    token(PlayerColor.yellow),
                  ],
                ),
              ),
            ),
          );
        },
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

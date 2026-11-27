import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/app/widgets/fade_slide_in.dart';
import 'package:ludo_unbiased/app/widgets/laurel.dart';
import 'package:ludo_unbiased/features/game/controllers/local_game_controller.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/home/home_screen.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

const _display = 'Fredoka';

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

  void _tick() {
    ref.read(audioServiceProvider).play(Sfx.uiTap);
    ref.read(hapticsProvider).tick();
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
    var i = 0;
    Widget enter(Widget w) => FadeSlideIn.staggered(index: i++, child: w);
    // Android back returns Home instead of closing the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/');
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              const _SetupBackdrop(),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                      children: [
                        _Header(
                          title: l.localGame,
                          onBack: () {
                            _tick();
                            context.go('/');
                          },
                        ),
                        const SizedBox(height: 18),
                        enter(
                          _Segmented<int>(
                            height: 60,
                            glow: true,
                            values: const [2, 3, 4],
                            selected: _count,
                            label: (n) => '$n',
                            onChanged: (n) {
                              _tick();
                              setState(() => _count = n);
                            },
                          ),
                        ),
                        const SizedBox(height: 18),
                        for (final c in seats) ...[
                          enter(
                            _SeatCard(
                              key: ValueKey(c),
                              color: c,
                              controller: _names[c]!,
                              kind: _kinds[c]!,
                              level: _levels[c]!,
                              onKind: (k) {
                                _tick();
                                setState(() => _kinds[c] = k);
                              },
                              onLevel: (v) {
                                _tick();
                                setState(() => _levels[c] = v);
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        const SizedBox(height: 10),
                        enter(
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: HomeButton(
                              key: const Key('startGame'),
                              style: HomeButtonStyle.gold,
                              label: l.startGame,
                              leading: const PlayTriangle(),
                              onPressed: _start,
                            ),
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
    );
  }
}

/// Back button and the ribbon title.
class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final mode = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Gold ribbon behind the title.
          Positioned(
            left: 52,
            right: 52,
            top: 66,
            height: 56,
            child: CustomPaint(
              painter: _RibbonPainter(s.goldLight, s.goldDark, s.shadow),
            ),
          ),
          Positioned(
            top: 2,
            child: Image.asset(
              'assets/images/dice/dice_face_5_$mode.png',
              width: 40,
              height: 40,
              excludeFromSemantics: true,
            ),
          ),
          Positioned(
            top: 40,
            left: 52,
            right: 52,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Laurel(color: s.goldLight, mirrored: false),
                  const SizedBox(width: 6),
                  Semantics(
                    header: true,
                    child: _StrokedText(title, size: 40),
                  ),
                  const SizedBox(width: 6),
                  Laurel(color: s.goldLight, mirrored: true),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 10,
            child: _BackButton(onPressed: onBack),
          ),
        ],
      ),
    );
  }
}

/// White title text with a thick navy outline.
class _StrokedText extends StatelessWidget {
  const _StrokedText(this.text, {required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    TextStyle base() => TextStyle(
      fontFamily: _display,
      fontWeight: FontWeight.w700,
      fontSize: size,
      height: 1,
    );
    return Stack(
      children: [
        Text(
          text,
          style: base().copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * .2
              ..strokeJoin = StrokeJoin.round
              ..color = s.titleStroke,
          ),
        ),
        Text(
          text,
          style: base().copyWith(
            color: s.titleFill2,
            shadows: [Shadow(color: s.shadow, offset: const Offset(0, 3))],
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: GestureDetector(
        key: const Key('setupBack'),
        onTap: onPressed,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: s.pill,
            boxShadow: [
              BoxShadow(
                color: s.shadow,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.chevron_left_rounded, size: 34, color: s.onGhost),
        ),
      ),
    );
  }
}

/// A glossy segmented toggle: the selected segment is blue with a check.
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
    this.icon,
    this.height = 48,
    this.glow = false,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final IconData Function(T)? icon;
  final ValueChanged<T> onChanged;
  final double height;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final radius = BorderRadius.circular(height / 2);
    final idle = Color.lerp(s.pill, s.buttonTop, .1)!;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: idle,
        border: Border.all(
          color: glow ? s.goldLight : s.onGhost.withValues(alpha: .18),
          width: glow ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: s.goldLight.withValues(alpha: .45),
              blurRadius: 14,
            ),
          BoxShadow(color: s.shadow, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          children: [
            for (final (n, v) in values.indexed) ...[
              if (n > 0)
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: s.onGhost.withValues(alpha: .15),
                ),
              Expanded(child: _segment(context, v, idle)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _segment(BuildContext context, T v, Color idle) {
    final s = context.scene;
    final on = v == selected;
    final fg = on ? s.onButton : s.onGhost;
    final size = height >= 56 ? 24.0 : 17.0;
    return Semantics(
      button: true,
      selected: on,
      label: label(v),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: on ? null : () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: on
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [s.buttonTop, s.buttonBottom],
                  )
                : null,
          ),
          child: ExcludeSemantics(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (on) ...[
                        Icon(Icons.check_rounded, color: fg, size: size),
                        const SizedBox(width: 6),
                      ],
                      if (icon != null) ...[
                        Icon(icon!(v), color: fg, size: size),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        label(v),
                        style: TextStyle(
                          fontFamily: _display,
                          fontWeight: FontWeight.w700,
                          fontSize: size,
                          color: fg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One seat: token art, name field, Human/AI and, for AI, its level.
class _SeatCard extends StatelessWidget {
  const _SeatCard({
    required this.color,
    required this.controller,
    required this.kind,
    required this.level,
    required this.onKind,
    required this.onLevel,
    super.key,
  });

  final PlayerColor color;
  final TextEditingController controller;
  final PlayerKind kind;
  final AiLevel level;
  final ValueChanged<PlayerKind> onKind;
  final ValueChanged<AiLevel> onLevel;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final b = context.board;
    final l = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = switch (color) {
      PlayerColor.red => b.red,
      PlayerColor.blue => b.blue,
      PlayerColor.yellow => b.yellow,
      PlayerColor.green => b.green,
    };
    final mode = dark ? 'dark' : 'light';
    final radius = BorderRadius.circular(26);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: tint.withValues(alpha: .55), width: 2.5),
        gradient: LinearGradient(
          colors: [
            Color.lerp(s.pill, tint, dark ? .3 : .16)!,
            Color.lerp(s.pill, tint, dark ? .08 : .03)!,
          ],
        ),
        boxShadow: [
          BoxShadow(color: tint.withValues(alpha: .35), blurRadius: 14),
          BoxShadow(color: s.shadow, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Token on a soft coloured panel.
              Container(
                width: 96,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      tint.withValues(alpha: .28),
                      tint.withValues(alpha: .06),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/tokens/token_${color.name}_idle_$mode.png',
                  width: 118,
                  height: 118,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          _SeatMark(color: color, tint: tint),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l.playerNameLabel(l.colorName(color)),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: s.onPill.withValues(alpha: .7),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _NameField(controller: controller, label: color),
                      const SizedBox(height: 10),
                      _Segmented<PlayerKind>(
                        values: const [PlayerKind.human, PlayerKind.ai],
                        selected: kind,
                        label: (k) => k == PlayerKind.human ? l.human : l.ai,
                        icon: (k) => k == PlayerKind.human
                            ? Icons.person_rounded
                            : Icons.smart_toy_rounded,
                        onChanged: onKind,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: kind == PlayerKind.ai
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _Segmented<AiLevel>(
                                  height: 40,
                                  values: const [AiLevel.easy, AiLevel.normal],
                                  selected: level,
                                  label: (v) =>
                                      v == AiLevel.easy ? l.easy : l.normal,
                                  onChanged: onLevel,
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.label});

  final TextEditingController controller;
  final PlayerColor label;

  @override
  Widget build(BuildContext context) {
    final s = context.scene;
    final l = context.l10n;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: s.onGhost.withValues(alpha: .18)),
    );
    return TextField(
      controller: controller,
      maxLength: 16,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        fontFamily: _display,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: s.onPill,
      ),
      decoration: InputDecoration(
        // Visible label is drawn above; this names the field for readers.
        semanticCounterText: '',
        hintText: l.colorName(label),
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: s.pill.withValues(alpha: .85),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: s.buttonTop, width: 2),
        ),
      ),
    );
  }
}

/// Deep blue sky with soft rays, and the board's colours along the floor.
class _SetupBackdrop extends StatelessWidget {
  const _SetupBackdrop();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final b = context.board;
    return CustomPaint(
      painter: _BackdropPainter(
        top: dark ? const Color(0xFF0B1433) : const Color(0xFF2E4BC6),
        bottom: dark ? const Color(0xFF1A2456) : const Color(0xFF3A2E9E),
        ray: Colors.white.withValues(alpha: dark ? .04 : .07),
        floor: [b.red, b.green, b.yellow, b.blue],
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.top,
    required this.bottom,
    required this.ray,
    required this.floor,
  });

  final Color top;
  final Color bottom;
  final Color ray;
  final List<Color> floor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(rect),
    );
    // Sunburst from behind the title.
    final c = Offset(size.width / 2, 90);
    final r = size.longestSide * 1.2;
    final p = Paint()..color = ray;
    const n = 18;
    for (var k = 0; k < n; k++) {
      final a = k * 2 * pi / n;
      const w = pi / n / 2;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + r * cos(a - w), c.dy + r * sin(a - w))
          ..lineTo(c.dx + r * cos(a + w), c.dy + r * sin(a + w))
          ..close(),
        p,
      );
    }
    // A glow behind the title.
    canvas.drawCircle(
      c,
      160,
      Paint()
        ..shader = RadialGradient(
          colors: [ray.withValues(alpha: .35), ray.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: c, radius: 160)),
    );
    // Board-coloured wedges fading in along the bottom edge.
    final h = size.height;
    final band = h * .12;
    final w = size.width / floor.length;
    for (final (k, col) in floor.indexed) {
      final x = k * w;
      canvas.drawPath(
        Path()
          ..moveTo(x + w * .15, h)
          ..lineTo(x + w * .5, h - band)
          ..lineTo(x + w * .85, h)
          ..close(),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [col.withValues(alpha: .55), col.withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(x, h - band, w, band)),
      );
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.top != top || old.bottom != bottom || old.ray != ray;
}

/// Gold banner ribbon with folded tails.
class _RibbonPainter extends CustomPainter {
  _RibbonPainter(this.light, this.dark, this.shadow);

  final Color light;
  final Color dark;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tail = Paint()..color = dark;
    // Tails, peeking out below each end.
    canvas
      ..drawPath(
        Path()
          ..moveTo(w * .06, h * .35)
          ..lineTo(0, h * .95)
          ..lineTo(w * .1, h * .8)
          ..lineTo(w * .16, h)
          ..lineTo(w * .2, h * .4)
          ..close(),
        tail,
      )
      ..drawPath(
        Path()
          ..moveTo(w * .94, h * .35)
          ..lineTo(w, h * .95)
          ..lineTo(w * .9, h * .8)
          ..lineTo(w * .84, h)
          ..lineTo(w * .8, h * .4)
          ..close(),
        tail,
      );
    // Body: a shallow downward arc.
    final body = Path()
      ..moveTo(w * .08, h * .1)
      ..quadraticBezierTo(w * .5, h * .35, w * .92, h * .1)
      ..lineTo(w * .92, h * .72)
      ..quadraticBezierTo(w * .5, h * .98, w * .08, h * .72)
      ..close();
    canvas
      ..drawShadow(body, shadow, 4, false)
      ..drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [light, dark],
          ).createShader(Offset.zero & size),
      );
  }

  @override
  bool shouldRepaint(_RibbonPainter old) =>
      old.light != light || old.dark != dark;
}

/// The seat's colour-blind shape (circle, square, triangle, star), filled.
class _SeatMark extends StatelessWidget {
  const _SeatMark({required this.color, required this.tint});

  final PlayerColor color;
  final Color tint;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 16,
    child: color == PlayerColor.green
        ? Icon(Icons.star_rounded, size: 18, color: tint)
        : CustomPaint(painter: _MarkPainter(color, tint)),
  );
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.color, this.tint);

  final PlayerColor color;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = tint;
    final r = Offset.zero & size;
    switch (color) {
      case PlayerColor.red:
        canvas.drawOval(r.deflate(1), p);
      case PlayerColor.blue:
        canvas.drawRRect(
          RRect.fromRectAndRadius(r.deflate(1.5), const Radius.circular(3)),
          p,
        );
      case PlayerColor.yellow:
        canvas.drawPath(
          Path()
            ..moveTo(size.width / 2, 1)
            ..lineTo(size.width - 0.5, size.height - 1.5)
            ..lineTo(0.5, size.height - 1.5)
            ..close(),
          p,
        );
      case PlayerColor.green:
        break;
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) =>
      old.color != color || old.tint != tint;
}

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:ludo_unbiased/features/game/flame/board_layout.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// One token on the board. Its resting position comes from
/// [BoardLayout]; the animation queue moves it during events.
class TokenComponent extends PositionComponent
    with HasGameReference<LudoGame>, TapCallbacks {
  /// Creates token [tokenId] of [color].
  TokenComponent({required this.color, required this.tokenId})
    : super(
        anchor: Anchor.center,
        size: Vector2.all(BoardLayout.tokenSize),
        priority: 10,
      );

  /// Owner colour.
  final PlayerColor color;

  /// Token id 0–3.
  final int tokenId;

  /// True when this token is a legal move for the current player.
  bool movable = false;

  /// True while the queue is moving it; layout leaves it alone.
  bool animating = false;

  /// 0–1 lift during a hop; drawn as a bigger shadow and a lifted sprite.
  double lift = 0;

  /// How many tokens share its place (for the count badge).
  int stackCount = 1;

  /// True for the token that shows the stack's count badge.
  bool showsBadge = false;

  double _pulse = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (movable) _pulse = (_pulse + dt * 2.2) % 1;
  }

  @override
  void render(Canvas canvas) {
    final mode = game.mode;
    final s = game.sprites;
    final shadowShift = Vector2(0, 0.05 + lift * 0.18);
    s
        .get('token_shadow', mode)
        .render(
          canvas,
          position: shadowShift,
          size: size * (1 - lift * 0.15),
        );
    final state = lift > 0
        ? 'hop'
        : movable
        ? 'movable'
        : 'idle';
    final pulse = movable && !game.reduceMotion
        ? 1 + 0.06 * sin(_pulse * 2 * pi)
        : 1.0;
    final drawSize = size * pulse;
    final lifted = Vector2(0, -lift * 0.22) - (drawSize - size) / 2;
    s
        .get('token_${color.name}_$state', mode)
        .render(canvas, position: lifted, size: drawSize);
    if (showsBadge && stackCount >= 3) {
      s
          .get('token_stack_badge_${min(stackCount, 4)}', mode)
          .render(
            canvas,
            position: Vector2(size.x * 0.62, -size.y * 0.05),
            size: size * 0.42,
          );
    }
  }

  @override
  void onTapDown(TapDownEvent event) => game.handleTokenTap(this);

  @override
  void onLongTapDown(TapDownEvent event) => game.handleTokenLongPress(this);
}

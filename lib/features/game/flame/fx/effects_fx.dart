// Flame's Component.add returns FutureOr by design; adding a child is
// fire-and-forget here, and the component mounts on the next tick.
// ignore_for_file: discarded_futures

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:ludo_unbiased/features/game/flame/sprite_catalog.dart';

/// The capture puff: six frames played once at the capture cell.
SpriteAnimationComponent capturePuff(SpriteCatalog s, Vector2 at) =>
    SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(
        [
          for (var k = 1; k <= 6; k++)
            s.get('fx_capture_puff_0$k', BoardMode.light),
        ],
        stepTime: 0.04,
        loop: false,
      ),
      position: at,
      anchor: Anchor.center,
      size: Vector2.all(2.4),
      removeOnFinish: true,
      priority: 20,
    );

/// A sparkle that grows and fades where a token reaches HOME.
SpriteComponent homeSparkle(SpriteCatalog s, Vector2 at) {
  final c = SpriteComponent(
    sprite: s.get('fx_sparkle', BoardMode.light),
    position: at,
    anchor: Anchor.center,
    size: Vector2.all(0.6),
    priority: 20,
  );
  c.addAll([
    ScaleEffect.to(Vector2.all(2.6), EffectController(duration: 0.4)),
    OpacityEffect.fadeOut(
      EffectController(duration: 0.4),
      onComplete: c.removeFromParent,
    ),
  ]);
  return c;
}

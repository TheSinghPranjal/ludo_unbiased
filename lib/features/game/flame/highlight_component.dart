import 'dart:ui';

import 'package:flame/components.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// A destination marker on the cell a legal move would land on.
class GhostComponent extends PositionComponent with HasGameReference<LudoGame> {
  /// Creates a ghost for [color] centred on [at].
  GhostComponent({required this.color, required Vector2 at})
    : super(
        position: at,
        anchor: Anchor.center,
        size: Vector2.all(1.16),
        priority: 5,
      );

  /// Colour of the moving token.
  final PlayerColor color;

  @override
  void render(Canvas canvas) => game.sprites
      .get('token_${color.name}_ghost', game.mode)
      .render(canvas, size: size);
}

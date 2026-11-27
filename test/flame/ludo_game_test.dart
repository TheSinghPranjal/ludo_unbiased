import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/engine/game_engine.dart';
import 'package:ludo_unbiased/features/game/flame/board_layout.dart';
import 'package:ludo_unbiased/features/game/flame/ludo_game.dart';
import 'package:ludo_unbiased/features/game/flame/sprite_catalog.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';

import '../helpers/game_builders.dart';

/// Runs the game loop for [seconds], letting futures resolve between frames.
Future<void> advance(
  LudoGame g,
  double seconds, [
  void Function()? each,
]) async {
  for (var t = 0.0; t < seconds; t += 1 / 60) {
    g.update(1 / 60);
    each?.call();
    await Future<void>.delayed(Duration.zero);
  }
}

/// Commits a move for the current player and returns the animating state.
(GameState, List<GameEvent>) commitMove(GameState s, int tokenId) =>
    GameEngine.move(s, pid(s.currentColor), tokenId).value;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('board layout', () {
    test('cell centres sit in the middle of their cell', () {
      expect(BoardLayout.cellCentre(13, 6), Vector2(6.5, 13.5));
      expect(BoardLayout.yardSlot(red, 0), Vector2(2, 11));
    });

    test('stacked tokens get distinct offsets inside the cell', () {
      for (var n = 1; n <= 4; n++) {
        final o = BoardLayout.stackOffsets(n);
        expect(o.toSet().length, n == 1 ? 1 : n);
        for (final v in o) {
          expect(v.length, lessThan(0.3));
        }
      }
    });

    test('a finished token rests in its own centre-triangle cell', () {
      final t = newGame().tokensOf(green).first.copyWith(rel: 56);
      expect(BoardLayout.restingPlace(t), BoardLayout.centreOf(green.homeCell));
    });

    test('sprite paths pick the mode variant', () {
      expect(
        SpriteCatalog.path('token_red_idle', BoardMode.dark),
        'tokens/3.0x/token_red_idle_dark.png',
      );
      expect(
        SpriteCatalog.path('board_bg', BoardMode.light),
        'board/board_bg_light.png',
      );
      expect(
        SpriteCatalog.path('fx_sparkle', BoardMode.dark),
        'fx/3.0x/fx_sparkle.png',
      );
    });
  });

  group('LudoGame', () {
    final moved = <int>[];
    final picked = <List<int>>[];
    LudoGame create() =>
        LudoGame(onMove: moved.add, onPickFromStack: picked.add);

    setUp(() {
      moved.clear();
      picked.clear();
    });

    testWithGame<LudoGame>('places every token at its resting place', create, (
      game,
    ) async {
      game.showState(place(newGame(), {(red, 0): 12}), {red});
      await game.ready();
      expect(game.tokens, hasLength(16));
      expect(
        game.tokenFor(red, 0)!.position,
        BoardLayout.centreOf(BoardConstants.track[12]),
      );
      expect(game.tokenFor(blue, 2)!.position, BoardLayout.yardSlot(blue, 2));
    });

    testWithGame<LudoGame>(
      'highlights movable tokens and ghosts destinations',
      create,
      (
        game,
      ) async {
        final s = rolled(place(newGame(), {(red, 0): 12}), red, 6);
        game.showState(s, {red});
        await game.ready();
        expect(game.tokens.where((t) => t.movable), hasLength(4));
        expect(game.ghosts, hasLength(2), reason: 'start cell + rel 18');
        game.showState(s, {blue});
        expect(game.tokens.where((t) => t.movable), isEmpty);
        expect(game.ghosts, isEmpty, reason: "not this device's turn");
      },
    );

    testWithGame<LudoGame>('taps route only movable tokens to onMove', create, (
      game,
    ) async {
      game.showState(rolled(place(newGame(), {(red, 0): 12}), red, 3), {red});
      await game.ready();
      game
        ..handleTokenTap(game.tokenFor(blue, 0)!)
        ..handleTokenTap(game.tokenFor(red, 1)!);
      expect(moved, isEmpty, reason: 'blue is not current; red 1 is in base');
      game.handleTokenTap(game.tokenFor(red, 0)!);
      expect(moved, [0]);
    });

    testWithGame<LudoGame>(
      'a stack: tap moves the first, long-press offers a pick',
      create,
      (
        game,
      ) async {
        final s = rolled(
          place(newGame(), {(red, 2): 12, (red, 3): 12}),
          red,
          3,
        );
        game.showState(s, {red});
        await game.ready();
        game.handleTokenTap(game.tokenFor(red, 3)!);
        expect(moved, [2]);
        game.handleTokenLongPress(game.tokenFor(red, 3)!);
        expect(picked, [
          [2, 3],
        ]);
      },
    );

    testWithGame<LudoGame>(
      'stacks of 3+ cluster and show one count badge',
      create,
      (
        game,
      ) async {
        final s = place(newGame(), {(red, 0): 12, (red, 1): 12, (red, 2): 12});
        game.showState(s, {red});
        await game.ready();
        final stack = [0, 1, 2].map((id) => game.tokenFor(red, id)!).toList();
        expect(stack.map((t) => t.position).toSet(), hasLength(3));
        expect(stack.where((t) => t.showsBadge), hasLength(1));
        for (final t in stack) {
          expect(t.size.x, closeTo(0.8, 1e-6));
        }
      },
    );

    testWithGame<LudoGame>(
      'hops cell by cell, including the diagonal corner',
      create,
      (
        game,
      ) async {
        final s = rolled(place(newGame(), {(red, 0): 29}), red, 3);
        game.showState(s, {red});
        await game.ready();
        final (animating, events) = commitMove(s, 0);
        game.showState(animating, {red});
        final t = game.tokenFor(red, 0)!;
        final visited = <Vector2>[];
        var done = false;
        unawaited(game.animations.play(events).then((_) => done = true));
        await advance(game, 0.3, () => visited.add(t.position.clone()));
        expect(done, isFalse, reason: '3 hops take 450 ms');
        await advance(game, 0.3, () => visited.add(t.position.clone()));
        expect(done, isTrue);
        expect(t.position, BoardLayout.centreOf(BoardConstants.track[32]));
        final corner = BoardLayout.centreOf(BoardConstants.track[31]);
        expect(visited.any((p) => p.distanceTo(corner) < 0.05), isTrue);
        expect(t.lift, 0);
      },
    );

    testWithGame<LudoGame>(
      'a captured token flies back to its yard slot',
      create,
      (
        game,
      ) async {
        final s = rolled(
          place(newGame(), {(red, 0): 2, (blue, 0): 44}),
          red,
          3,
        );
        game.showState(s, {red});
        await game.ready();
        final (animating, events) = commitMove(s, 0);
        expect(events.whereType<TokenCaptured>(), hasLength(1));
        game.showState(animating, {red});
        var done = false;
        unawaited(game.animations.play(events).then((_) => done = true));
        await advance(game, 1.2);
        expect(done, isTrue);
        expect(game.tokenFor(blue, 0)!.position, BoardLayout.yardSlot(blue, 0));
      },
    );

    testWithGame<LudoGame>(
      'batches play in order; flush finishes at once',
      create,
      (
        game,
      ) async {
        final s = rolled(place(newGame(), {(red, 0): 10}), red, 5);
        game.showState(s, {red});
        await game.ready();
        final (animating, events) = commitMove(s, 0);
        game.showState(animating, {red});
        final order = <int>[];
        unawaited(game.animations.play(events).then((_) => order.add(1)));
        unawaited(game.animations.play(const []).then((_) => order.add(2)));
        await advance(game, 0.1);
        expect(order, isEmpty);
        expect(game.animations.isBusy, isTrue);
        game.animations.flush();
        await advance(game, 0.05);
        expect(order, [1, 2]);
        expect(game.animations.isBusy, isFalse);
        expect(
          game.tokenFor(red, 0)!.position,
          BoardLayout.centreOf(BoardConstants.track[15]),
        );
      },
    );

    testWithGame<LudoGame>('renders in both modes without reloading', create, (
      game,
    ) async {
      game.showState(rolled(place(newGame(), {(red, 0): 12}), red, 6), {red});
      await game.ready();
      for (final m in BoardMode.values) {
        game.mode = m;
        final recorder = PictureRecorder();
        game.render(Canvas(recorder));
        recorder.endRecording().dispose();
      }
    });
  });
}

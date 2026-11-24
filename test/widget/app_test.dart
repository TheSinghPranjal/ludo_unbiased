import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/app/app.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  List<int> dice, {
  Map<String, Object> prefs = const {},
  AudioBackend? audio,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      diceServiceProvider.overrideWithValue(ScriptedDiceService(dice)),
      audioBackendProvider.overrideWithValue(audio ?? SilentAudioBackend()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const LudoApp()),
  );
  return container;
}

void main() {
  testWidgets('Home offers Quick Play and Play Local', (tester) async {
    await pumpApp(tester, []);
    expect(find.text('Quick Play vs AI'), findsOneWidget);
    expect(find.text('Play Local'), findsOneWidget);
    expect(find.text('Continue'), findsNothing);
  });

  testWidgets('Quick Play starts a game; rolling updates the status', (
    tester,
  ) async {
    final container = await pumpApp(tester, [3]);
    await tester.tap(find.byKey(const Key('quickPlay')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('roll')), findsOneWidget);
    await tester.tap(find.byKey(const Key('roll')));
    await tester.pump();
    expect(find.text("No moves for You. Moss's turn."), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    final game = container.read(activeGameProvider)!;
    expect(game.state.value.currentPlayer.name, 'Moss');
    container.read(activeGameProvider.notifier).end();
    await tester.pump();
  });

  testWidgets('Play Local opens setup and starts a 4-player game', (
    tester,
  ) async {
    final container = await pumpApp(tester, []);
    await tester.tap(find.text('Play Local'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('startGame')),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.byKey(const Key('startGame')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final game = container.read(activeGameProvider)!;
    expect(game.state.value.players, hasLength(4));
    container.read(activeGameProvider.notifier).end();
    await tester.pump();
  });

  testWidgets('Back asks to confirm, Stay keeps the game, Leave goes Home', (
    tester,
  ) async {
    final container = await pumpApp(tester, []);
    await tester.tap(find.byKey(const Key('quickPlay')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const Key('back')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Leave game?'), findsOneWidget);
    await tester.tap(find.text('Stay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Leave game?'), findsNothing);
    expect(container.read(activeGameProvider), isNotNull);

    await tester.tap(find.byKey(const Key('back')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('confirmLeave')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(activeGameProvider), isNull);
    expect(find.text('Quick Play vs AI'), findsOneWidget);
  });
}

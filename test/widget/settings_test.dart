import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/features/game/services/status_messages.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

import '../helpers/game_builders.dart';
import 'app_test.dart' show pumpApp;

void main() {
  testWidgets('Home opens Settings and How to Play', (tester) async {
    await pumpApp(tester, []);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('openHowToPlay')));
    await tester.pumpAndSettle();
    expect(find.text('Roll a 6 to leave base'), findsOneWidget);
  });

  testWidgets('choosing Hindi relabels the app at once', (tester) async {
    final container = await pumpApp(tester, []);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('lang_hi')), 200);
    await tester.tap(find.byKey(const Key('lang_hi')));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).languageCode, 'hi');
    expect(find.text('सेटिंग्स'), findsOneWidget);
    // pageBack() finds the button by its English tooltip.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('AI के साथ झटपट खेल'), findsOneWidget);
  });

  testWidgets('Dark appearance switches the theme', (tester) async {
    await pumpApp(tester, []);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.text('Appearance'));
    expect(Theme.of(ctx).brightness, Brightness.dark);
  });

  testWidgets('sound, music and vibration toggles update settings', (
    tester,
  ) async {
    final container = await pumpApp(tester, []);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettings')));
    await tester.pumpAndSettle();
    for (final key in ['soundToggle', 'musicToggle', 'vibrationToggle']) {
      await tester.scrollUntilVisible(find.byKey(Key(key)), 200);
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }
    final s = container.read(settingsProvider);
    expect([s.sound, s.music, s.vibration], [false, false, false]);
  });

  testWidgets('How to Play pages through five cards and closes', (
    tester,
  ) async {
    await pumpApp(tester, []);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openHowToPlay')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(const Key('htpNext')));
      await tester.pumpAndSettle();
    }
    expect(find.text('Bring all four home'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    await tester.tap(find.byKey(const Key('htpNext')));
    await tester.pumpAndSettle();
    expect(find.text('Quick Play vs AI'), findsOneWidget);
  });

  test('status lines render in the chosen language', () {
    final state = newGame(const [PlayerColor.red, PlayerColor.yellow]);
    final line = statusFor([
      const GameEvent.diceRolled(color: PlayerColor.red, value: 4),
    ], state)!;
    expect(line(lookupAppLocalizations(const Locale('en'))), contains('4'));
    final hi = lookupAppLocalizations(const Locale('hi'));
    expect(line(hi), contains('का 4 आया'));
  });

  test('every language has every string', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = lookupAppLocalizations(locale);
      expect(l.languageName, isNotEmpty, reason: '$locale');
      expect(l.htpBody5, isNotEmpty, reason: '$locale');
    }
  });
}

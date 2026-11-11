import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/features/game/services/dice_service.dart';

/// χ² critical value for 5 degrees of freedom at p = 0.001.
const double chiSquareCritical = 20.515;
const int rolls = 120000;

void checkFairness(String name, DiceService dice) {
  final counts = List.filled(7, 0);
  for (var i = 0; i < rolls; i++) {
    final v = dice.roll();
    expect(v, inInclusiveRange(1, 6));
    counts[v]++;
  }
  const expected = rolls / 6;
  var chi = 0.0;
  for (var f = 1; f <= 6; f++) {
    final diff = counts[f] - expected;
    chi += diff * diff / expected;
  }
  stdout.writeln(
    '$name: counts ${counts.sublist(1)}, χ² = ${chi.toStringAsFixed(3)}',
  );
  for (var f = 1; f <= 6; f++) {
    expect(
      counts[f],
      inInclusiveRange(expected * 0.97, expected * 1.03),
      reason: '$name face $f',
    );
  }
  expect(chi, lessThan(chiSquareCritical), reason: '$name χ²');
}

void main() {
  test('SeededDiceService is fair over 120,000 rolls', () {
    checkFairness('SeededDiceService(20261111)', SeededDiceService(20261111));
  });

  test('SecureDiceService is fair over 120,000 rolls', () {
    // Unseeded by design: this check has a 0.1% chance of a false failure.
    checkFairness('SecureDiceService', SecureDiceService());
  });

  test('ScriptedDiceService replays its script, then throws', () {
    final d = ScriptedDiceService([6, 3]);
    expect(d.roll(), 6);
    expect(d.roll(), 3);
    expect(d.roll, throwsStateError);
    expect(() => ScriptedDiceService([7]), throwsRangeError);
  });

  test('SeededDiceService replays the same sequence for the same seed', () {
    final a = SeededDiceService(5);
    final b = SeededDiceService(5);
    expect(
      List.generate(50, (_) => a.roll()),
      List.generate(50, (_) => b.roll()),
    );
  });
}

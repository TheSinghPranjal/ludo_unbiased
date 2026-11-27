import 'dart:math';

/// Produces dice values 1–6. The engine calls [roll] once per roll command.
// One method is the point: implementations differ only in randomness source.
// ignore: one_member_abstracts
abstract interface class DiceService {
  /// Returns a value from 1 to 6.
  int roll();
}

/// Production dice, backed by the platform's cryptographic RNG.
final class SecureDiceService implements DiceService {
  /// Creates secure dice.
  SecureDiceService() : _random = Random.secure();

  final Random _random;

  @override
  int roll() => _random.nextInt(6) + 1;
}

/// Reproducible dice for replays and the fairness test.
final class SeededDiceService implements DiceService {
  /// Creates dice whose sequence depends only on [seed].
  SeededDiceService(int seed) : _random = Random(seed);

  final Random _random;

  @override
  int roll() => _random.nextInt(6) + 1;
}

/// Dice that return a fixed script, for tests. Throws when the script runs
/// out, so a test can never silently roll a value it did not plan.
final class ScriptedDiceService implements DiceService {
  /// Creates dice that return [values] in order.
  ScriptedDiceService(Iterable<int> values) : _values = List.of(values) {
    for (final v in _values) {
      RangeError.checkValueInInterval(v, 1, 6, 'value');
    }
  }

  final List<int> _values;
  var _next = 0;

  /// Values not yet rolled.
  int get remaining => _values.length - _next;

  @override
  int roll() {
    if (_next >= _values.length) {
      throw StateError('ScriptedDiceService ran out after $_next rolls');
    }
    return _values[_next++];
  }
}

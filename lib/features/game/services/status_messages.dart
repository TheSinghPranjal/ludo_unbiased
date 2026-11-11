import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

/// The status-line text for a batch of events, or null to keep the current
/// line. Names come from [state] so the line says "Asha" rather than "Red".
String? statusFor(List<GameEvent> events, GameState state) {
  String name(PlayerColor c) => state.playerOf(c)?.name ?? _colorName(c);
  for (final e in events.reversed) {
    final text = switch (e) {
      GameOver(:final ranking) => '${name(ranking.first)} wins!',
      PlayerFinished(:final color, :final rank) =>
        '${name(color)} finished ${_ordinal(rank)}!',
      ThreeSixesForfeit(:final color) =>
        'Three 6s. ${name(color)} loses '
            'the turn.',
      TokenCaptured(:final color, :final byColor) =>
        '${name(byColor)} captured ${name(color)}!',
      ExtraRoll(:final color, :final reason) => switch (reason) {
        ExtraRollReason.six => '${name(color)} rolled 6, extra roll!',
        ExtraRollReason.capture => 'Capture! ${name(color)} rolls again.',
        ExtraRollReason.home => 'Token home! ${name(color)} rolls again.',
      },
      TurnPassed(:final from, :final to, :final reason) => switch (reason) {
        TurnPassReason.noMoves =>
          'No moves for ${name(from)}. '
              "${name(to)}'s turn.",
        TurnPassReason.playerRemoved =>
          '${name(from)} left. '
              "${name(to)}'s turn.",
        _ => "${name(to)}'s turn",
      },
      PlayerRemoved(:final color) => '${name(color)} left the game.',
      DiceRolled(:final color, :final value) =>
        '${name(color)} rolled '
            '$value',
      _ => null,
    };
    if (text != null) return text;
  }
  return null;
}

String _colorName(PlayerColor c) =>
    c.name[0].toUpperCase() + c.name.substring(1);

String _ordinal(int n) => switch (n) {
  1 => '1st',
  2 => '2nd',
  3 => '3rd',
  _ => '${n}th',
};

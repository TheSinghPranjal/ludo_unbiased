import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// A status line, rendered in whatever language is current when shown, so
/// switching language mid-game updates the line too.
typedef StatusLine = String Function(AppLocalizations l);

/// The status line for a batch of events, or null to keep the current
/// line. Names come from [state] so the line says "Asha" rather than "Red".
StatusLine? statusFor(List<GameEvent> events, GameState state) {
  for (final e in events.reversed) {
    final line = _lineFor(e, state);
    if (line != null) return line;
  }
  return null;
}

/// "Your turn" for the local "You" seat, otherwise "Name's turn".
StatusLine turnStatus(PlayerColor color, GameState state) =>
    (l) => turnLine(l, _name(l, state, color));

/// "Your turn" when [name] is the local player's name, else "Name's turn".
String turnLine(AppLocalizations l, String name) =>
    name == l.you ? l.turnYours : l.turnOf(name);

String _name(AppLocalizations l, GameState state, PlayerColor c) =>
    state.playerOf(c)?.name ?? l.colorName(c);

StatusLine? _lineFor(GameEvent e, GameState state) {
  String n(AppLocalizations l, PlayerColor c) => _name(l, state, c);
  return switch (e) {
    GameOver(:final ranking) => (l) => l.statusWins(n(l, ranking.first)),
    PlayerFinished(:final color, :final rank) => (l) => l.statusFinished(
      n(l, color),
      l.rankOrdinal('$rank'),
    ),
    ThreeSixesForfeit(:final color) => (l) => l.statusThreeSixes(n(l, color)),
    TokenCaptured(:final color, :final byColor) => (l) => l.statusCaptured(
      n(l, byColor),
      n(l, color),
    ),
    ExtraRoll(:final color, :final reason) => switch (reason) {
      ExtraRollReason.six => (l) => l.statusExtraSix(n(l, color)),
      ExtraRollReason.capture => (l) => l.statusExtraCapture(n(l, color)),
      ExtraRollReason.home => (l) => l.statusExtraHome(n(l, color)),
    },
    TurnPassed(:final from, :final to, :final reason) => switch (reason) {
      TurnPassReason.noMoves => (l) => l.statusNoMoves(
        n(l, from),
        turnLine(l, n(l, to)),
      ),
      TurnPassReason.playerRemoved => (l) => l.statusLeftTurn(
        n(l, from),
        turnLine(l, n(l, to)),
      ),
      _ => (l) => turnLine(l, n(l, to)),
    },
    PlayerRemoved(:final color) => (l) => l.statusLeft(n(l, color)),
    DiceRolled(:final color, :final value) => (l) => l.statusRolled(
      n(l, color),
      value,
    ),
    _ => null,
  };
}

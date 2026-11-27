import 'dart:convert';

import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A saved local game and the turn time it had left.
typedef SavedGame = ({GameState state, Duration remaining});

/// Saves one local game so Home can offer Continue (spec §6.4).
class SavedGameRepository {
  /// Creates a repository on [prefs].
  SavedGameRepository(this.prefs);

  /// Backing store.
  final SharedPreferences prefs;

  /// Storage key.
  static const key = 'saved_local_game';

  /// Bump when the saved format changes; older saves are discarded.
  static const schemaVersion = 1;

  /// Saves [state] with [remaining] turn time.
  Future<void> save(GameState state, Duration remaining) => prefs.setString(
    key,
    jsonEncode({
      'schemaVersion': schemaVersion,
      'remainingMs': remaining.inMilliseconds,
      'state': state.toJson(),
    }),
  );

  /// The saved game, or null when there is none or it cannot be read.
  SavedGame? load() {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['schemaVersion'] != schemaVersion) return null;
      final state = GameState.fromJson(json['state'] as Map<String, dynamic>);
      if (state.isOver || state.phase == GamePhase.animating) return null;
      return (
        state: state,
        remaining: Duration(milliseconds: json['remainingMs'] as int),
      );
    } on Object {
      return null;
    }
  }

  /// True when a game can be continued.
  bool get hasSave => load() != null;

  /// Deletes the save.
  Future<void> clear() => prefs.remove(key);
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/models/player.dart';

import '../helpers/game_builders.dart';

void main() {
  test('GameState round-trips through JSON text unchanged', () {
    var s = place(newGame(), {(red, 0): 12, (blue, 2): 53});
    (s, _) = rollOk(s, 6);
    final text = jsonEncode(s.toJson());
    final back = GameState.fromJson(jsonDecode(text) as Map<String, dynamic>);
    expect(back, s);
    expect(back.hashCode, s.hashCode);
  });

  test('every event type round-trips through JSON text', () {
    const events = <GameEvent>[
      GameEvent.diceRolled(color: red, value: 6),
      GameEvent.tokenMoved(
        color: red,
        tokenId: 1,
        fromRel: 3,
        toRel: 5,
        path: [BoardCell(10, 6), BoardCell(9, 6)],
      ),
      GameEvent.tokenCaptured(
        color: blue,
        tokenId: 0,
        byColor: red,
        at: BoardCell(8, 5),
      ),
      GameEvent.tokenHome(color: green, tokenId: 3),
      GameEvent.extraRoll(color: red, reason: ExtraRollReason.capture),
      GameEvent.turnPassed(from: red, to: blue, reason: TurnPassReason.noMoves),
      GameEvent.threeSixesForfeit(color: yellow),
      GameEvent.playerFinished(color: green, rank: 1),
      GameEvent.playerConnection(
        color: blue,
        connection: SeatConnection.disconnected,
      ),
      GameEvent.playerRemoved(color: yellow),
      GameEvent.playerReplacedByAi(color: blue, level: AiLevel.normal),
      GameEvent.gameOver(ranking: [green, red, blue, yellow]),
    ];
    for (final e in events) {
      final text = jsonEncode(e.toJson());
      final back = GameEvent.fromJson(jsonDecode(text) as Map<String, dynamic>);
      expect(back, e, reason: text);
    }
  });
}

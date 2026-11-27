// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GameState _$GameStateFromJson(Map<String, dynamic> json) => _GameState(
  gameId: json['gameId'] as String,
  players: (json['players'] as List<dynamic>)
      .map((e) => Player.fromJson(e as Map<String, dynamic>))
      .toList(),
  tokens: (json['tokens'] as List<dynamic>)
      .map((e) => Token.fromJson(e as Map<String, dynamic>))
      .toList(),
  currentColor: $enumDecode(_$PlayerColorEnumMap, json['currentColor']),
  phase: $enumDecode(_$GamePhaseEnumMap, json['phase']),
  nextPhase: $enumDecodeNullable(_$GamePhaseEnumMap, json['nextPhase']),
  dice: (json['dice'] as num?)?.toInt(),
  sixesThisTurn: (json['sixesThisTurn'] as num?)?.toInt() ?? 0,
  turnSeq: (json['turnSeq'] as num?)?.toInt() ?? 0,
  ranking:
      (json['ranking'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PlayerColorEnumMap, e))
          .toList() ??
      const <PlayerColor>[],
  leavers:
      (json['leavers'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PlayerColorEnumMap, e))
          .toList() ??
      const <PlayerColor>[],
  eventSeq: (json['eventSeq'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$GameStateToJson(_GameState instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'players': instance.players.map((e) => e.toJson()).toList(),
      'tokens': instance.tokens.map((e) => e.toJson()).toList(),
      'currentColor': _$PlayerColorEnumMap[instance.currentColor]!,
      'phase': _$GamePhaseEnumMap[instance.phase]!,
      'nextPhase': _$GamePhaseEnumMap[instance.nextPhase],
      'dice': instance.dice,
      'sixesThisTurn': instance.sixesThisTurn,
      'turnSeq': instance.turnSeq,
      'ranking': instance.ranking.map((e) => _$PlayerColorEnumMap[e]!).toList(),
      'leavers': instance.leavers.map((e) => _$PlayerColorEnumMap[e]!).toList(),
      'eventSeq': instance.eventSeq,
    };

const _$PlayerColorEnumMap = {
  PlayerColor.red: 'red',
  PlayerColor.blue: 'blue',
  PlayerColor.yellow: 'yellow',
  PlayerColor.green: 'green',
};

const _$GamePhaseEnumMap = {
  GamePhase.awaitingRoll: 'awaitingRoll',
  GamePhase.rolled: 'rolled',
  GamePhase.animating: 'animating',
  GamePhase.gameOver: 'gameOver',
};

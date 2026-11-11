// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiceRolled _$DiceRolledFromJson(Map<String, dynamic> json) => DiceRolled(
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  value: (json['value'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$DiceRolledToJson(DiceRolled instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'value': instance.value,
      'type': instance.$type,
    };

const _$PlayerColorEnumMap = {
  PlayerColor.red: 'red',
  PlayerColor.blue: 'blue',
  PlayerColor.yellow: 'yellow',
  PlayerColor.green: 'green',
};

TokenMoved _$TokenMovedFromJson(Map<String, dynamic> json) => TokenMoved(
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  tokenId: (json['tokenId'] as num).toInt(),
  fromRel: (json['fromRel'] as num).toInt(),
  toRel: (json['toRel'] as num).toInt(),
  path: (json['path'] as List<dynamic>)
      .map((e) => BoardCell.fromJson(e as Map<String, dynamic>))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$TokenMovedToJson(TokenMoved instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'tokenId': instance.tokenId,
      'fromRel': instance.fromRel,
      'toRel': instance.toRel,
      'path': instance.path.map((e) => e.toJson()).toList(),
      'type': instance.$type,
    };

TokenCaptured _$TokenCapturedFromJson(Map<String, dynamic> json) =>
    TokenCaptured(
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      tokenId: (json['tokenId'] as num).toInt(),
      byColor: $enumDecode(_$PlayerColorEnumMap, json['byColor']),
      at: BoardCell.fromJson(json['at'] as Map<String, dynamic>),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TokenCapturedToJson(TokenCaptured instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'tokenId': instance.tokenId,
      'byColor': _$PlayerColorEnumMap[instance.byColor]!,
      'at': instance.at.toJson(),
      'type': instance.$type,
    };

TokenHome _$TokenHomeFromJson(Map<String, dynamic> json) => TokenHome(
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  tokenId: (json['tokenId'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$TokenHomeToJson(TokenHome instance) => <String, dynamic>{
  'color': _$PlayerColorEnumMap[instance.color]!,
  'tokenId': instance.tokenId,
  'type': instance.$type,
};

ExtraRoll _$ExtraRollFromJson(Map<String, dynamic> json) => ExtraRoll(
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  reason: $enumDecode(_$ExtraRollReasonEnumMap, json['reason']),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$ExtraRollToJson(ExtraRoll instance) => <String, dynamic>{
  'color': _$PlayerColorEnumMap[instance.color]!,
  'reason': _$ExtraRollReasonEnumMap[instance.reason]!,
  'type': instance.$type,
};

const _$ExtraRollReasonEnumMap = {
  ExtraRollReason.six: 'six',
  ExtraRollReason.capture: 'capture',
  ExtraRollReason.home: 'home',
};

TurnPassed _$TurnPassedFromJson(Map<String, dynamic> json) => TurnPassed(
  from: $enumDecode(_$PlayerColorEnumMap, json['from']),
  to: $enumDecode(_$PlayerColorEnumMap, json['to']),
  reason: $enumDecode(_$TurnPassReasonEnumMap, json['reason']),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$TurnPassedToJson(TurnPassed instance) =>
    <String, dynamic>{
      'from': _$PlayerColorEnumMap[instance.from]!,
      'to': _$PlayerColorEnumMap[instance.to]!,
      'reason': _$TurnPassReasonEnumMap[instance.reason]!,
      'type': instance.$type,
    };

const _$TurnPassReasonEnumMap = {
  TurnPassReason.turnEnded: 'turnEnded',
  TurnPassReason.noMoves: 'noMoves',
  TurnPassReason.threeSixes: 'threeSixes',
  TurnPassReason.playerFinished: 'playerFinished',
  TurnPassReason.playerRemoved: 'playerRemoved',
};

ThreeSixesForfeit _$ThreeSixesForfeitFromJson(Map<String, dynamic> json) =>
    ThreeSixesForfeit(
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$ThreeSixesForfeitToJson(ThreeSixesForfeit instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'type': instance.$type,
    };

PlayerFinished _$PlayerFinishedFromJson(Map<String, dynamic> json) =>
    PlayerFinished(
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      rank: (json['rank'] as num).toInt(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PlayerFinishedToJson(PlayerFinished instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'rank': instance.rank,
      'type': instance.$type,
    };

PlayerConnection _$PlayerConnectionFromJson(Map<String, dynamic> json) =>
    PlayerConnection(
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      connection: $enumDecode(_$SeatConnectionEnumMap, json['connection']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PlayerConnectionToJson(PlayerConnection instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'connection': _$SeatConnectionEnumMap[instance.connection]!,
      'type': instance.$type,
    };

const _$SeatConnectionEnumMap = {
  SeatConnection.connected: 'connected',
  SeatConnection.disconnected: 'disconnected',
  SeatConnection.removed: 'removed',
};

PlayerRemoved _$PlayerRemovedFromJson(Map<String, dynamic> json) =>
    PlayerRemoved(
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PlayerRemovedToJson(PlayerRemoved instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'type': instance.$type,
    };

PlayerReplacedByAi _$PlayerReplacedByAiFromJson(Map<String, dynamic> json) =>
    PlayerReplacedByAi(
      color: $enumDecode(_$PlayerColorEnumMap, json['color']),
      level: $enumDecode(_$AiLevelEnumMap, json['level']),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PlayerReplacedByAiToJson(PlayerReplacedByAi instance) =>
    <String, dynamic>{
      'color': _$PlayerColorEnumMap[instance.color]!,
      'level': _$AiLevelEnumMap[instance.level]!,
      'type': instance.$type,
    };

const _$AiLevelEnumMap = {AiLevel.easy: 'easy', AiLevel.normal: 'normal'};

GameOver _$GameOverFromJson(Map<String, dynamic> json) => GameOver(
  ranking: (json['ranking'] as List<dynamic>)
      .map((e) => $enumDecode(_$PlayerColorEnumMap, e))
      .toList(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$GameOverToJson(GameOver instance) => <String, dynamic>{
  'ranking': instance.ranking.map((e) => _$PlayerColorEnumMap[e]!).toList(),
  'type': instance.$type,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlayerStats _$PlayerStatsFromJson(Map<String, dynamic> json) => _PlayerStats(
  tokensHome: (json['tokensHome'] as num?)?.toInt() ?? 0,
  captures: (json['captures'] as num?)?.toInt() ?? 0,
  timesCaptured: (json['timesCaptured'] as num?)?.toInt() ?? 0,
  sixes: (json['sixes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PlayerStatsToJson(_PlayerStats instance) =>
    <String, dynamic>{
      'tokensHome': instance.tokensHome,
      'captures': instance.captures,
      'timesCaptured': instance.timesCaptured,
      'sixes': instance.sixes,
    };

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  id: json['id'] as String,
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  name: json['name'] as String,
  kind: $enumDecode(_$PlayerKindEnumMap, json['kind']),
  aiLevel: $enumDecodeNullable(_$AiLevelEnumMap, json['aiLevel']),
  connection:
      $enumDecodeNullable(_$SeatConnectionEnumMap, json['connection']) ??
      SeatConnection.connected,
  finishedRank: (json['finishedRank'] as num?)?.toInt(),
  stats: json['stats'] == null
      ? const PlayerStats()
      : PlayerStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'id': instance.id,
  'color': _$PlayerColorEnumMap[instance.color]!,
  'name': instance.name,
  'kind': _$PlayerKindEnumMap[instance.kind]!,
  'aiLevel': _$AiLevelEnumMap[instance.aiLevel],
  'connection': _$SeatConnectionEnumMap[instance.connection]!,
  'finishedRank': instance.finishedRank,
  'stats': instance.stats.toJson(),
};

const _$PlayerColorEnumMap = {
  PlayerColor.red: 'red',
  PlayerColor.blue: 'blue',
  PlayerColor.yellow: 'yellow',
  PlayerColor.green: 'green',
};

const _$PlayerKindEnumMap = {
  PlayerKind.human: 'human',
  PlayerKind.ai: 'ai',
  PlayerKind.remote: 'remote',
};

const _$AiLevelEnumMap = {AiLevel.easy: 'easy', AiLevel.normal: 'normal'};

const _$SeatConnectionEnumMap = {
  SeatConnection.connected: 'connected',
  SeatConnection.disconnected: 'disconnected',
  SeatConnection.removed: 'removed',
};

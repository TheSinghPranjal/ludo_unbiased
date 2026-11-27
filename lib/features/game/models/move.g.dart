// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Move _$MoveFromJson(Map<String, dynamic> json) => _Move(
  tokenId: (json['tokenId'] as num).toInt(),
  fromRel: (json['fromRel'] as num).toInt(),
  toRel: (json['toRel'] as num).toInt(),
  captures:
      (json['captures'] as List<dynamic>?)
          ?.map((e) => TokenRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TokenRef>[],
  entersBase: json['entersBase'] as bool? ?? false,
  reachesHome: json['reachesHome'] as bool? ?? false,
  landsSafe: json['landsSafe'] as bool? ?? false,
);

Map<String, dynamic> _$MoveToJson(_Move instance) => <String, dynamic>{
  'tokenId': instance.tokenId,
  'fromRel': instance.fromRel,
  'toRel': instance.toRel,
  'captures': instance.captures.map((e) => e.toJson()).toList(),
  'entersBase': instance.entersBase,
  'reachesHome': instance.reachesHome,
  'landsSafe': instance.landsSafe,
};

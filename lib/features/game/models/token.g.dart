// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Token _$TokenFromJson(Map<String, dynamic> json) => _Token(
  id: (json['id'] as num).toInt(),
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  rel: (json['rel'] as num).toInt(),
);

Map<String, dynamic> _$TokenToJson(_Token instance) => <String, dynamic>{
  'id': instance.id,
  'color': _$PlayerColorEnumMap[instance.color]!,
  'rel': instance.rel,
};

const _$PlayerColorEnumMap = {
  PlayerColor.red: 'red',
  PlayerColor.blue: 'blue',
  PlayerColor.yellow: 'yellow',
  PlayerColor.green: 'green',
};

_TokenRef _$TokenRefFromJson(Map<String, dynamic> json) => _TokenRef(
  color: $enumDecode(_$PlayerColorEnumMap, json['color']),
  id: (json['id'] as num).toInt(),
);

Map<String, dynamic> _$TokenRefToJson(_TokenRef instance) => <String, dynamic>{
  'color': _$PlayerColorEnumMap[instance.color]!,
  'id': instance.id,
};

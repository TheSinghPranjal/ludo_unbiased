// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayerStats {

 int get tokensHome; int get captures; int get timesCaptured; int get sixes;
/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<PlayerStats> get copyWith => _$PlayerStatsCopyWithImpl<PlayerStats>(this as PlayerStats, _$identity);

  /// Serializes this PlayerStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerStats&&(identical(other.tokensHome, tokensHome) || other.tokensHome == tokensHome)&&(identical(other.captures, captures) || other.captures == captures)&&(identical(other.timesCaptured, timesCaptured) || other.timesCaptured == timesCaptured)&&(identical(other.sixes, sixes) || other.sixes == sixes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokensHome,captures,timesCaptured,sixes);

@override
String toString() {
  return 'PlayerStats(tokensHome: $tokensHome, captures: $captures, timesCaptured: $timesCaptured, sixes: $sixes)';
}


}

/// @nodoc
abstract mixin class $PlayerStatsCopyWith<$Res>  {
  factory $PlayerStatsCopyWith(PlayerStats value, $Res Function(PlayerStats) _then) = _$PlayerStatsCopyWithImpl;
@useResult
$Res call({
 int tokensHome, int captures, int timesCaptured, int sixes
});




}
/// @nodoc
class _$PlayerStatsCopyWithImpl<$Res>
    implements $PlayerStatsCopyWith<$Res> {
  _$PlayerStatsCopyWithImpl(this._self, this._then);

  final PlayerStats _self;
  final $Res Function(PlayerStats) _then;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokensHome = null,Object? captures = null,Object? timesCaptured = null,Object? sixes = null,}) {
  return _then(_self.copyWith(
tokensHome: null == tokensHome ? _self.tokensHome : tokensHome // ignore: cast_nullable_to_non_nullable
as int,captures: null == captures ? _self.captures : captures // ignore: cast_nullable_to_non_nullable
as int,timesCaptured: null == timesCaptured ? _self.timesCaptured : timesCaptured // ignore: cast_nullable_to_non_nullable
as int,sixes: null == sixes ? _self.sixes : sixes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlayerStats].
extension PlayerStatsPatterns on PlayerStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerStats value)  $default,){
final _that = this;
switch (_that) {
case _PlayerStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tokensHome,  int captures,  int timesCaptured,  int sixes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that.tokensHome,_that.captures,_that.timesCaptured,_that.sixes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tokensHome,  int captures,  int timesCaptured,  int sixes)  $default,) {final _that = this;
switch (_that) {
case _PlayerStats():
return $default(_that.tokensHome,_that.captures,_that.timesCaptured,_that.sixes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tokensHome,  int captures,  int timesCaptured,  int sixes)?  $default,) {final _that = this;
switch (_that) {
case _PlayerStats() when $default != null:
return $default(_that.tokensHome,_that.captures,_that.timesCaptured,_that.sixes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayerStats implements PlayerStats {
  const _PlayerStats({this.tokensHome = 0, this.captures = 0, this.timesCaptured = 0, this.sixes = 0});
  factory _PlayerStats.fromJson(Map<String, dynamic> json) => _$PlayerStatsFromJson(json);

@override@JsonKey() final  int tokensHome;
@override@JsonKey() final  int captures;
@override@JsonKey() final  int timesCaptured;
@override@JsonKey() final  int sixes;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStatsCopyWith<_PlayerStats> get copyWith => __$PlayerStatsCopyWithImpl<_PlayerStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerStats&&(identical(other.tokensHome, tokensHome) || other.tokensHome == tokensHome)&&(identical(other.captures, captures) || other.captures == captures)&&(identical(other.timesCaptured, timesCaptured) || other.timesCaptured == timesCaptured)&&(identical(other.sixes, sixes) || other.sixes == sixes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokensHome,captures,timesCaptured,sixes);

@override
String toString() {
  return 'PlayerStats(tokensHome: $tokensHome, captures: $captures, timesCaptured: $timesCaptured, sixes: $sixes)';
}


}

/// @nodoc
abstract mixin class _$PlayerStatsCopyWith<$Res> implements $PlayerStatsCopyWith<$Res> {
  factory _$PlayerStatsCopyWith(_PlayerStats value, $Res Function(_PlayerStats) _then) = __$PlayerStatsCopyWithImpl;
@override @useResult
$Res call({
 int tokensHome, int captures, int timesCaptured, int sixes
});




}
/// @nodoc
class __$PlayerStatsCopyWithImpl<$Res>
    implements _$PlayerStatsCopyWith<$Res> {
  __$PlayerStatsCopyWithImpl(this._self, this._then);

  final _PlayerStats _self;
  final $Res Function(_PlayerStats) _then;

/// Create a copy of PlayerStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokensHome = null,Object? captures = null,Object? timesCaptured = null,Object? sixes = null,}) {
  return _then(_PlayerStats(
tokensHome: null == tokensHome ? _self.tokensHome : tokensHome // ignore: cast_nullable_to_non_nullable
as int,captures: null == captures ? _self.captures : captures // ignore: cast_nullable_to_non_nullable
as int,timesCaptured: null == timesCaptured ? _self.timesCaptured : timesCaptured // ignore: cast_nullable_to_non_nullable
as int,sixes: null == sixes ? _self.sixes : sixes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Player {

 PlayerId get id; PlayerColor get color; String get name; PlayerKind get kind; AiLevel? get aiLevel; SeatConnection get connection; int? get finishedRank; PlayerStats get stats;
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerCopyWith<Player> get copyWith => _$PlayerCopyWithImpl<Player>(this as Player, _$identity);

  /// Serializes this Player to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Player&&(identical(other.id, id) || other.id == id)&&(identical(other.color, color) || other.color == color)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.aiLevel, aiLevel) || other.aiLevel == aiLevel)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.finishedRank, finishedRank) || other.finishedRank == finishedRank)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,color,name,kind,aiLevel,connection,finishedRank,stats);

@override
String toString() {
  return 'Player(id: $id, color: $color, name: $name, kind: $kind, aiLevel: $aiLevel, connection: $connection, finishedRank: $finishedRank, stats: $stats)';
}


}

/// @nodoc
abstract mixin class $PlayerCopyWith<$Res>  {
  factory $PlayerCopyWith(Player value, $Res Function(Player) _then) = _$PlayerCopyWithImpl;
@useResult
$Res call({
 PlayerId id, PlayerColor color, String name, PlayerKind kind, AiLevel? aiLevel, SeatConnection connection, int? finishedRank, PlayerStats stats
});


$PlayerStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$PlayerCopyWithImpl<$Res>
    implements $PlayerCopyWith<$Res> {
  _$PlayerCopyWithImpl(this._self, this._then);

  final Player _self;
  final $Res Function(Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? color = null,Object? name = null,Object? kind = null,Object? aiLevel = freezed,Object? connection = null,Object? finishedRank = freezed,Object? stats = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PlayerId,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlayerKind,aiLevel: freezed == aiLevel ? _self.aiLevel : aiLevel // ignore: cast_nullable_to_non_nullable
as AiLevel?,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as SeatConnection,finishedRank: freezed == finishedRank ? _self.finishedRank : finishedRank // ignore: cast_nullable_to_non_nullable
as int?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayerStats,
  ));
}
/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<$Res> get stats {
  
  return $PlayerStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [Player].
extension PlayerPatterns on Player {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Player value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Player value)  $default,){
final _that = this;
switch (_that) {
case _Player():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Player value)?  $default,){
final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlayerId id,  PlayerColor color,  String name,  PlayerKind kind,  AiLevel? aiLevel,  SeatConnection connection,  int? finishedRank,  PlayerStats stats)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.color,_that.name,_that.kind,_that.aiLevel,_that.connection,_that.finishedRank,_that.stats);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlayerId id,  PlayerColor color,  String name,  PlayerKind kind,  AiLevel? aiLevel,  SeatConnection connection,  int? finishedRank,  PlayerStats stats)  $default,) {final _that = this;
switch (_that) {
case _Player():
return $default(_that.id,_that.color,_that.name,_that.kind,_that.aiLevel,_that.connection,_that.finishedRank,_that.stats);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlayerId id,  PlayerColor color,  String name,  PlayerKind kind,  AiLevel? aiLevel,  SeatConnection connection,  int? finishedRank,  PlayerStats stats)?  $default,) {final _that = this;
switch (_that) {
case _Player() when $default != null:
return $default(_that.id,_that.color,_that.name,_that.kind,_that.aiLevel,_that.connection,_that.finishedRank,_that.stats);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Player extends Player {
  const _Player({required this.id, required this.color, required this.name, required this.kind, this.aiLevel, this.connection = SeatConnection.connected, this.finishedRank, this.stats = const PlayerStats()}): super._();
  factory _Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);

@override final  PlayerId id;
@override final  PlayerColor color;
@override final  String name;
@override final  PlayerKind kind;
@override final  AiLevel? aiLevel;
@override@JsonKey() final  SeatConnection connection;
@override final  int? finishedRank;
@override@JsonKey() final  PlayerStats stats;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerCopyWith<_Player> get copyWith => __$PlayerCopyWithImpl<_Player>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Player&&(identical(other.id, id) || other.id == id)&&(identical(other.color, color) || other.color == color)&&(identical(other.name, name) || other.name == name)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.aiLevel, aiLevel) || other.aiLevel == aiLevel)&&(identical(other.connection, connection) || other.connection == connection)&&(identical(other.finishedRank, finishedRank) || other.finishedRank == finishedRank)&&(identical(other.stats, stats) || other.stats == stats));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,color,name,kind,aiLevel,connection,finishedRank,stats);

@override
String toString() {
  return 'Player(id: $id, color: $color, name: $name, kind: $kind, aiLevel: $aiLevel, connection: $connection, finishedRank: $finishedRank, stats: $stats)';
}


}

/// @nodoc
abstract mixin class _$PlayerCopyWith<$Res> implements $PlayerCopyWith<$Res> {
  factory _$PlayerCopyWith(_Player value, $Res Function(_Player) _then) = __$PlayerCopyWithImpl;
@override @useResult
$Res call({
 PlayerId id, PlayerColor color, String name, PlayerKind kind, AiLevel? aiLevel, SeatConnection connection, int? finishedRank, PlayerStats stats
});


@override $PlayerStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$PlayerCopyWithImpl<$Res>
    implements _$PlayerCopyWith<$Res> {
  __$PlayerCopyWithImpl(this._self, this._then);

  final _Player _self;
  final $Res Function(_Player) _then;

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? color = null,Object? name = null,Object? kind = null,Object? aiLevel = freezed,Object? connection = null,Object? finishedRank = freezed,Object? stats = null,}) {
  return _then(_Player(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as PlayerId,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PlayerKind,aiLevel: freezed == aiLevel ? _self.aiLevel : aiLevel // ignore: cast_nullable_to_non_nullable
as AiLevel?,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as SeatConnection,finishedRank: freezed == finishedRank ? _self.finishedRank : finishedRank // ignore: cast_nullable_to_non_nullable
as int?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PlayerStats,
  ));
}

/// Create a copy of Player
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PlayerStatsCopyWith<$Res> get stats {
  
  return $PlayerStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on

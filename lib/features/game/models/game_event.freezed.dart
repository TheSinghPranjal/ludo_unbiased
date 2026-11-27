// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
GameEvent _$GameEventFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'diceRolled':
          return DiceRolled.fromJson(
            json
          );
                case 'tokenMoved':
          return TokenMoved.fromJson(
            json
          );
                case 'tokenCaptured':
          return TokenCaptured.fromJson(
            json
          );
                case 'tokenHome':
          return TokenHome.fromJson(
            json
          );
                case 'extraRoll':
          return ExtraRoll.fromJson(
            json
          );
                case 'turnPassed':
          return TurnPassed.fromJson(
            json
          );
                case 'threeSixesForfeit':
          return ThreeSixesForfeit.fromJson(
            json
          );
                case 'playerFinished':
          return PlayerFinished.fromJson(
            json
          );
                case 'playerConnection':
          return PlayerConnection.fromJson(
            json
          );
                case 'playerRemoved':
          return PlayerRemoved.fromJson(
            json
          );
                case 'playerReplacedByAi':
          return PlayerReplacedByAi.fromJson(
            json
          );
                case 'gameOver':
          return GameOver.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'GameEvent',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$GameEvent {



  /// Serializes this GameEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameEvent);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameEvent()';
}


}

/// @nodoc
class $GameEventCopyWith<$Res>  {
$GameEventCopyWith(GameEvent _, $Res Function(GameEvent) __);
}


/// Adds pattern-matching-related methods to [GameEvent].
extension GameEventPatterns on GameEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DiceRolled value)?  diceRolled,TResult Function( TokenMoved value)?  tokenMoved,TResult Function( TokenCaptured value)?  tokenCaptured,TResult Function( TokenHome value)?  tokenHome,TResult Function( ExtraRoll value)?  extraRoll,TResult Function( TurnPassed value)?  turnPassed,TResult Function( ThreeSixesForfeit value)?  threeSixesForfeit,TResult Function( PlayerFinished value)?  playerFinished,TResult Function( PlayerConnection value)?  playerConnection,TResult Function( PlayerRemoved value)?  playerRemoved,TResult Function( PlayerReplacedByAi value)?  playerReplacedByAi,TResult Function( GameOver value)?  gameOver,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DiceRolled() when diceRolled != null:
return diceRolled(_that);case TokenMoved() when tokenMoved != null:
return tokenMoved(_that);case TokenCaptured() when tokenCaptured != null:
return tokenCaptured(_that);case TokenHome() when tokenHome != null:
return tokenHome(_that);case ExtraRoll() when extraRoll != null:
return extraRoll(_that);case TurnPassed() when turnPassed != null:
return turnPassed(_that);case ThreeSixesForfeit() when threeSixesForfeit != null:
return threeSixesForfeit(_that);case PlayerFinished() when playerFinished != null:
return playerFinished(_that);case PlayerConnection() when playerConnection != null:
return playerConnection(_that);case PlayerRemoved() when playerRemoved != null:
return playerRemoved(_that);case PlayerReplacedByAi() when playerReplacedByAi != null:
return playerReplacedByAi(_that);case GameOver() when gameOver != null:
return gameOver(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DiceRolled value)  diceRolled,required TResult Function( TokenMoved value)  tokenMoved,required TResult Function( TokenCaptured value)  tokenCaptured,required TResult Function( TokenHome value)  tokenHome,required TResult Function( ExtraRoll value)  extraRoll,required TResult Function( TurnPassed value)  turnPassed,required TResult Function( ThreeSixesForfeit value)  threeSixesForfeit,required TResult Function( PlayerFinished value)  playerFinished,required TResult Function( PlayerConnection value)  playerConnection,required TResult Function( PlayerRemoved value)  playerRemoved,required TResult Function( PlayerReplacedByAi value)  playerReplacedByAi,required TResult Function( GameOver value)  gameOver,}){
final _that = this;
switch (_that) {
case DiceRolled():
return diceRolled(_that);case TokenMoved():
return tokenMoved(_that);case TokenCaptured():
return tokenCaptured(_that);case TokenHome():
return tokenHome(_that);case ExtraRoll():
return extraRoll(_that);case TurnPassed():
return turnPassed(_that);case ThreeSixesForfeit():
return threeSixesForfeit(_that);case PlayerFinished():
return playerFinished(_that);case PlayerConnection():
return playerConnection(_that);case PlayerRemoved():
return playerRemoved(_that);case PlayerReplacedByAi():
return playerReplacedByAi(_that);case GameOver():
return gameOver(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DiceRolled value)?  diceRolled,TResult? Function( TokenMoved value)?  tokenMoved,TResult? Function( TokenCaptured value)?  tokenCaptured,TResult? Function( TokenHome value)?  tokenHome,TResult? Function( ExtraRoll value)?  extraRoll,TResult? Function( TurnPassed value)?  turnPassed,TResult? Function( ThreeSixesForfeit value)?  threeSixesForfeit,TResult? Function( PlayerFinished value)?  playerFinished,TResult? Function( PlayerConnection value)?  playerConnection,TResult? Function( PlayerRemoved value)?  playerRemoved,TResult? Function( PlayerReplacedByAi value)?  playerReplacedByAi,TResult? Function( GameOver value)?  gameOver,}){
final _that = this;
switch (_that) {
case DiceRolled() when diceRolled != null:
return diceRolled(_that);case TokenMoved() when tokenMoved != null:
return tokenMoved(_that);case TokenCaptured() when tokenCaptured != null:
return tokenCaptured(_that);case TokenHome() when tokenHome != null:
return tokenHome(_that);case ExtraRoll() when extraRoll != null:
return extraRoll(_that);case TurnPassed() when turnPassed != null:
return turnPassed(_that);case ThreeSixesForfeit() when threeSixesForfeit != null:
return threeSixesForfeit(_that);case PlayerFinished() when playerFinished != null:
return playerFinished(_that);case PlayerConnection() when playerConnection != null:
return playerConnection(_that);case PlayerRemoved() when playerRemoved != null:
return playerRemoved(_that);case PlayerReplacedByAi() when playerReplacedByAi != null:
return playerReplacedByAi(_that);case GameOver() when gameOver != null:
return gameOver(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( PlayerColor color,  int value)?  diceRolled,TResult Function( PlayerColor color,  int tokenId,  int fromRel,  int toRel,  List<BoardCell> path)?  tokenMoved,TResult Function( PlayerColor color,  int tokenId,  PlayerColor byColor,  BoardCell at)?  tokenCaptured,TResult Function( PlayerColor color,  int tokenId)?  tokenHome,TResult Function( PlayerColor color,  ExtraRollReason reason)?  extraRoll,TResult Function( PlayerColor from,  PlayerColor to,  TurnPassReason reason)?  turnPassed,TResult Function( PlayerColor color)?  threeSixesForfeit,TResult Function( PlayerColor color,  int rank)?  playerFinished,TResult Function( PlayerColor color,  SeatConnection connection)?  playerConnection,TResult Function( PlayerColor color)?  playerRemoved,TResult Function( PlayerColor color,  AiLevel level)?  playerReplacedByAi,TResult Function( List<PlayerColor> ranking)?  gameOver,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DiceRolled() when diceRolled != null:
return diceRolled(_that.color,_that.value);case TokenMoved() when tokenMoved != null:
return tokenMoved(_that.color,_that.tokenId,_that.fromRel,_that.toRel,_that.path);case TokenCaptured() when tokenCaptured != null:
return tokenCaptured(_that.color,_that.tokenId,_that.byColor,_that.at);case TokenHome() when tokenHome != null:
return tokenHome(_that.color,_that.tokenId);case ExtraRoll() when extraRoll != null:
return extraRoll(_that.color,_that.reason);case TurnPassed() when turnPassed != null:
return turnPassed(_that.from,_that.to,_that.reason);case ThreeSixesForfeit() when threeSixesForfeit != null:
return threeSixesForfeit(_that.color);case PlayerFinished() when playerFinished != null:
return playerFinished(_that.color,_that.rank);case PlayerConnection() when playerConnection != null:
return playerConnection(_that.color,_that.connection);case PlayerRemoved() when playerRemoved != null:
return playerRemoved(_that.color);case PlayerReplacedByAi() when playerReplacedByAi != null:
return playerReplacedByAi(_that.color,_that.level);case GameOver() when gameOver != null:
return gameOver(_that.ranking);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( PlayerColor color,  int value)  diceRolled,required TResult Function( PlayerColor color,  int tokenId,  int fromRel,  int toRel,  List<BoardCell> path)  tokenMoved,required TResult Function( PlayerColor color,  int tokenId,  PlayerColor byColor,  BoardCell at)  tokenCaptured,required TResult Function( PlayerColor color,  int tokenId)  tokenHome,required TResult Function( PlayerColor color,  ExtraRollReason reason)  extraRoll,required TResult Function( PlayerColor from,  PlayerColor to,  TurnPassReason reason)  turnPassed,required TResult Function( PlayerColor color)  threeSixesForfeit,required TResult Function( PlayerColor color,  int rank)  playerFinished,required TResult Function( PlayerColor color,  SeatConnection connection)  playerConnection,required TResult Function( PlayerColor color)  playerRemoved,required TResult Function( PlayerColor color,  AiLevel level)  playerReplacedByAi,required TResult Function( List<PlayerColor> ranking)  gameOver,}) {final _that = this;
switch (_that) {
case DiceRolled():
return diceRolled(_that.color,_that.value);case TokenMoved():
return tokenMoved(_that.color,_that.tokenId,_that.fromRel,_that.toRel,_that.path);case TokenCaptured():
return tokenCaptured(_that.color,_that.tokenId,_that.byColor,_that.at);case TokenHome():
return tokenHome(_that.color,_that.tokenId);case ExtraRoll():
return extraRoll(_that.color,_that.reason);case TurnPassed():
return turnPassed(_that.from,_that.to,_that.reason);case ThreeSixesForfeit():
return threeSixesForfeit(_that.color);case PlayerFinished():
return playerFinished(_that.color,_that.rank);case PlayerConnection():
return playerConnection(_that.color,_that.connection);case PlayerRemoved():
return playerRemoved(_that.color);case PlayerReplacedByAi():
return playerReplacedByAi(_that.color,_that.level);case GameOver():
return gameOver(_that.ranking);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( PlayerColor color,  int value)?  diceRolled,TResult? Function( PlayerColor color,  int tokenId,  int fromRel,  int toRel,  List<BoardCell> path)?  tokenMoved,TResult? Function( PlayerColor color,  int tokenId,  PlayerColor byColor,  BoardCell at)?  tokenCaptured,TResult? Function( PlayerColor color,  int tokenId)?  tokenHome,TResult? Function( PlayerColor color,  ExtraRollReason reason)?  extraRoll,TResult? Function( PlayerColor from,  PlayerColor to,  TurnPassReason reason)?  turnPassed,TResult? Function( PlayerColor color)?  threeSixesForfeit,TResult? Function( PlayerColor color,  int rank)?  playerFinished,TResult? Function( PlayerColor color,  SeatConnection connection)?  playerConnection,TResult? Function( PlayerColor color)?  playerRemoved,TResult? Function( PlayerColor color,  AiLevel level)?  playerReplacedByAi,TResult? Function( List<PlayerColor> ranking)?  gameOver,}) {final _that = this;
switch (_that) {
case DiceRolled() when diceRolled != null:
return diceRolled(_that.color,_that.value);case TokenMoved() when tokenMoved != null:
return tokenMoved(_that.color,_that.tokenId,_that.fromRel,_that.toRel,_that.path);case TokenCaptured() when tokenCaptured != null:
return tokenCaptured(_that.color,_that.tokenId,_that.byColor,_that.at);case TokenHome() when tokenHome != null:
return tokenHome(_that.color,_that.tokenId);case ExtraRoll() when extraRoll != null:
return extraRoll(_that.color,_that.reason);case TurnPassed() when turnPassed != null:
return turnPassed(_that.from,_that.to,_that.reason);case ThreeSixesForfeit() when threeSixesForfeit != null:
return threeSixesForfeit(_that.color);case PlayerFinished() when playerFinished != null:
return playerFinished(_that.color,_that.rank);case PlayerConnection() when playerConnection != null:
return playerConnection(_that.color,_that.connection);case PlayerRemoved() when playerRemoved != null:
return playerRemoved(_that.color);case PlayerReplacedByAi() when playerReplacedByAi != null:
return playerReplacedByAi(_that.color,_that.level);case GameOver() when gameOver != null:
return gameOver(_that.ranking);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class DiceRolled implements GameEvent {
  const DiceRolled({required this.color, required this.value, final  String? $type}): $type = $type ?? 'diceRolled';
  factory DiceRolled.fromJson(Map<String, dynamic> json) => _$DiceRolledFromJson(json);

 final  PlayerColor color;
 final  int value;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiceRolledCopyWith<DiceRolled> get copyWith => _$DiceRolledCopyWithImpl<DiceRolled>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiceRolledToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiceRolled&&(identical(other.color, color) || other.color == color)&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,value);

@override
String toString() {
  return 'GameEvent.diceRolled(color: $color, value: $value)';
}


}

/// @nodoc
abstract mixin class $DiceRolledCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $DiceRolledCopyWith(DiceRolled value, $Res Function(DiceRolled) _then) = _$DiceRolledCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, int value
});




}
/// @nodoc
class _$DiceRolledCopyWithImpl<$Res>
    implements $DiceRolledCopyWith<$Res> {
  _$DiceRolledCopyWithImpl(this._self, this._then);

  final DiceRolled _self;
  final $Res Function(DiceRolled) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? value = null,}) {
  return _then(DiceRolled(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TokenMoved implements GameEvent {
  const TokenMoved({required this.color, required this.tokenId, required this.fromRel, required this.toRel, required final  List<BoardCell> path, final  String? $type}): _path = path,$type = $type ?? 'tokenMoved';
  factory TokenMoved.fromJson(Map<String, dynamic> json) => _$TokenMovedFromJson(json);

 final  PlayerColor color;
 final  int tokenId;
 final  int fromRel;
 final  int toRel;
 final  List<BoardCell> _path;
 List<BoardCell> get path {
  if (_path is EqualUnmodifiableListView) return _path;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_path);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenMovedCopyWith<TokenMoved> get copyWith => _$TokenMovedCopyWithImpl<TokenMoved>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenMovedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenMoved&&(identical(other.color, color) || other.color == color)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.fromRel, fromRel) || other.fromRel == fromRel)&&(identical(other.toRel, toRel) || other.toRel == toRel)&&const DeepCollectionEquality().equals(other._path, _path));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,tokenId,fromRel,toRel,const DeepCollectionEquality().hash(_path));

@override
String toString() {
  return 'GameEvent.tokenMoved(color: $color, tokenId: $tokenId, fromRel: $fromRel, toRel: $toRel, path: $path)';
}


}

/// @nodoc
abstract mixin class $TokenMovedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $TokenMovedCopyWith(TokenMoved value, $Res Function(TokenMoved) _then) = _$TokenMovedCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, int tokenId, int fromRel, int toRel, List<BoardCell> path
});




}
/// @nodoc
class _$TokenMovedCopyWithImpl<$Res>
    implements $TokenMovedCopyWith<$Res> {
  _$TokenMovedCopyWithImpl(this._self, this._then);

  final TokenMoved _self;
  final $Res Function(TokenMoved) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? tokenId = null,Object? fromRel = null,Object? toRel = null,Object? path = null,}) {
  return _then(TokenMoved(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int,fromRel: null == fromRel ? _self.fromRel : fromRel // ignore: cast_nullable_to_non_nullable
as int,toRel: null == toRel ? _self.toRel : toRel // ignore: cast_nullable_to_non_nullable
as int,path: null == path ? _self._path : path // ignore: cast_nullable_to_non_nullable
as List<BoardCell>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TokenCaptured implements GameEvent {
  const TokenCaptured({required this.color, required this.tokenId, required this.byColor, required this.at, final  String? $type}): $type = $type ?? 'tokenCaptured';
  factory TokenCaptured.fromJson(Map<String, dynamic> json) => _$TokenCapturedFromJson(json);

 final  PlayerColor color;
 final  int tokenId;
 final  PlayerColor byColor;
 final  BoardCell at;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenCapturedCopyWith<TokenCaptured> get copyWith => _$TokenCapturedCopyWithImpl<TokenCaptured>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenCapturedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenCaptured&&(identical(other.color, color) || other.color == color)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.byColor, byColor) || other.byColor == byColor)&&(identical(other.at, at) || other.at == at));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,tokenId,byColor,at);

@override
String toString() {
  return 'GameEvent.tokenCaptured(color: $color, tokenId: $tokenId, byColor: $byColor, at: $at)';
}


}

/// @nodoc
abstract mixin class $TokenCapturedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $TokenCapturedCopyWith(TokenCaptured value, $Res Function(TokenCaptured) _then) = _$TokenCapturedCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, int tokenId, PlayerColor byColor, BoardCell at
});




}
/// @nodoc
class _$TokenCapturedCopyWithImpl<$Res>
    implements $TokenCapturedCopyWith<$Res> {
  _$TokenCapturedCopyWithImpl(this._self, this._then);

  final TokenCaptured _self;
  final $Res Function(TokenCaptured) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? tokenId = null,Object? byColor = null,Object? at = null,}) {
  return _then(TokenCaptured(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int,byColor: null == byColor ? _self.byColor : byColor // ignore: cast_nullable_to_non_nullable
as PlayerColor,at: null == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as BoardCell,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TokenHome implements GameEvent {
  const TokenHome({required this.color, required this.tokenId, final  String? $type}): $type = $type ?? 'tokenHome';
  factory TokenHome.fromJson(Map<String, dynamic> json) => _$TokenHomeFromJson(json);

 final  PlayerColor color;
 final  int tokenId;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenHomeCopyWith<TokenHome> get copyWith => _$TokenHomeCopyWithImpl<TokenHome>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenHomeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenHome&&(identical(other.color, color) || other.color == color)&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,tokenId);

@override
String toString() {
  return 'GameEvent.tokenHome(color: $color, tokenId: $tokenId)';
}


}

/// @nodoc
abstract mixin class $TokenHomeCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $TokenHomeCopyWith(TokenHome value, $Res Function(TokenHome) _then) = _$TokenHomeCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, int tokenId
});




}
/// @nodoc
class _$TokenHomeCopyWithImpl<$Res>
    implements $TokenHomeCopyWith<$Res> {
  _$TokenHomeCopyWithImpl(this._self, this._then);

  final TokenHome _self;
  final $Res Function(TokenHome) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? tokenId = null,}) {
  return _then(TokenHome(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ExtraRoll implements GameEvent {
  const ExtraRoll({required this.color, required this.reason, final  String? $type}): $type = $type ?? 'extraRoll';
  factory ExtraRoll.fromJson(Map<String, dynamic> json) => _$ExtraRollFromJson(json);

 final  PlayerColor color;
 final  ExtraRollReason reason;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtraRollCopyWith<ExtraRoll> get copyWith => _$ExtraRollCopyWithImpl<ExtraRoll>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExtraRollToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtraRoll&&(identical(other.color, color) || other.color == color)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,reason);

@override
String toString() {
  return 'GameEvent.extraRoll(color: $color, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $ExtraRollCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $ExtraRollCopyWith(ExtraRoll value, $Res Function(ExtraRoll) _then) = _$ExtraRollCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, ExtraRollReason reason
});




}
/// @nodoc
class _$ExtraRollCopyWithImpl<$Res>
    implements $ExtraRollCopyWith<$Res> {
  _$ExtraRollCopyWithImpl(this._self, this._then);

  final ExtraRoll _self;
  final $Res Function(ExtraRoll) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? reason = null,}) {
  return _then(ExtraRoll(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as ExtraRollReason,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TurnPassed implements GameEvent {
  const TurnPassed({required this.from, required this.to, required this.reason, final  String? $type}): $type = $type ?? 'turnPassed';
  factory TurnPassed.fromJson(Map<String, dynamic> json) => _$TurnPassedFromJson(json);

 final  PlayerColor from;
 final  PlayerColor to;
 final  TurnPassReason reason;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TurnPassedCopyWith<TurnPassed> get copyWith => _$TurnPassedCopyWithImpl<TurnPassed>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TurnPassedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TurnPassed&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.reason, reason) || other.reason == reason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,from,to,reason);

@override
String toString() {
  return 'GameEvent.turnPassed(from: $from, to: $to, reason: $reason)';
}


}

/// @nodoc
abstract mixin class $TurnPassedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $TurnPassedCopyWith(TurnPassed value, $Res Function(TurnPassed) _then) = _$TurnPassedCopyWithImpl;
@useResult
$Res call({
 PlayerColor from, PlayerColor to, TurnPassReason reason
});




}
/// @nodoc
class _$TurnPassedCopyWithImpl<$Res>
    implements $TurnPassedCopyWith<$Res> {
  _$TurnPassedCopyWithImpl(this._self, this._then);

  final TurnPassed _self;
  final $Res Function(TurnPassed) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? from = null,Object? to = null,Object? reason = null,}) {
  return _then(TurnPassed(
from: null == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as PlayerColor,to: null == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as PlayerColor,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as TurnPassReason,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ThreeSixesForfeit implements GameEvent {
  const ThreeSixesForfeit({required this.color, final  String? $type}): $type = $type ?? 'threeSixesForfeit';
  factory ThreeSixesForfeit.fromJson(Map<String, dynamic> json) => _$ThreeSixesForfeitFromJson(json);

 final  PlayerColor color;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThreeSixesForfeitCopyWith<ThreeSixesForfeit> get copyWith => _$ThreeSixesForfeitCopyWithImpl<ThreeSixesForfeit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThreeSixesForfeitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThreeSixesForfeit&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color);

@override
String toString() {
  return 'GameEvent.threeSixesForfeit(color: $color)';
}


}

/// @nodoc
abstract mixin class $ThreeSixesForfeitCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $ThreeSixesForfeitCopyWith(ThreeSixesForfeit value, $Res Function(ThreeSixesForfeit) _then) = _$ThreeSixesForfeitCopyWithImpl;
@useResult
$Res call({
 PlayerColor color
});




}
/// @nodoc
class _$ThreeSixesForfeitCopyWithImpl<$Res>
    implements $ThreeSixesForfeitCopyWith<$Res> {
  _$ThreeSixesForfeitCopyWithImpl(this._self, this._then);

  final ThreeSixesForfeit _self;
  final $Res Function(ThreeSixesForfeit) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,}) {
  return _then(ThreeSixesForfeit(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PlayerFinished implements GameEvent {
  const PlayerFinished({required this.color, required this.rank, final  String? $type}): $type = $type ?? 'playerFinished';
  factory PlayerFinished.fromJson(Map<String, dynamic> json) => _$PlayerFinishedFromJson(json);

 final  PlayerColor color;
 final  int rank;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerFinishedCopyWith<PlayerFinished> get copyWith => _$PlayerFinishedCopyWithImpl<PlayerFinished>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerFinishedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerFinished&&(identical(other.color, color) || other.color == color)&&(identical(other.rank, rank) || other.rank == rank));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,rank);

@override
String toString() {
  return 'GameEvent.playerFinished(color: $color, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $PlayerFinishedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerFinishedCopyWith(PlayerFinished value, $Res Function(PlayerFinished) _then) = _$PlayerFinishedCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, int rank
});




}
/// @nodoc
class _$PlayerFinishedCopyWithImpl<$Res>
    implements $PlayerFinishedCopyWith<$Res> {
  _$PlayerFinishedCopyWithImpl(this._self, this._then);

  final PlayerFinished _self;
  final $Res Function(PlayerFinished) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? rank = null,}) {
  return _then(PlayerFinished(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PlayerConnection implements GameEvent {
  const PlayerConnection({required this.color, required this.connection, final  String? $type}): $type = $type ?? 'playerConnection';
  factory PlayerConnection.fromJson(Map<String, dynamic> json) => _$PlayerConnectionFromJson(json);

 final  PlayerColor color;
 final  SeatConnection connection;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerConnectionCopyWith<PlayerConnection> get copyWith => _$PlayerConnectionCopyWithImpl<PlayerConnection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerConnection&&(identical(other.color, color) || other.color == color)&&(identical(other.connection, connection) || other.connection == connection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,connection);

@override
String toString() {
  return 'GameEvent.playerConnection(color: $color, connection: $connection)';
}


}

/// @nodoc
abstract mixin class $PlayerConnectionCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerConnectionCopyWith(PlayerConnection value, $Res Function(PlayerConnection) _then) = _$PlayerConnectionCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, SeatConnection connection
});




}
/// @nodoc
class _$PlayerConnectionCopyWithImpl<$Res>
    implements $PlayerConnectionCopyWith<$Res> {
  _$PlayerConnectionCopyWithImpl(this._self, this._then);

  final PlayerConnection _self;
  final $Res Function(PlayerConnection) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? connection = null,}) {
  return _then(PlayerConnection(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,connection: null == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as SeatConnection,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PlayerRemoved implements GameEvent {
  const PlayerRemoved({required this.color, final  String? $type}): $type = $type ?? 'playerRemoved';
  factory PlayerRemoved.fromJson(Map<String, dynamic> json) => _$PlayerRemovedFromJson(json);

 final  PlayerColor color;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerRemovedCopyWith<PlayerRemoved> get copyWith => _$PlayerRemovedCopyWithImpl<PlayerRemoved>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerRemovedToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerRemoved&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color);

@override
String toString() {
  return 'GameEvent.playerRemoved(color: $color)';
}


}

/// @nodoc
abstract mixin class $PlayerRemovedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerRemovedCopyWith(PlayerRemoved value, $Res Function(PlayerRemoved) _then) = _$PlayerRemovedCopyWithImpl;
@useResult
$Res call({
 PlayerColor color
});




}
/// @nodoc
class _$PlayerRemovedCopyWithImpl<$Res>
    implements $PlayerRemovedCopyWith<$Res> {
  _$PlayerRemovedCopyWithImpl(this._self, this._then);

  final PlayerRemoved _self;
  final $Res Function(PlayerRemoved) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,}) {
  return _then(PlayerRemoved(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PlayerReplacedByAi implements GameEvent {
  const PlayerReplacedByAi({required this.color, required this.level, final  String? $type}): $type = $type ?? 'playerReplacedByAi';
  factory PlayerReplacedByAi.fromJson(Map<String, dynamic> json) => _$PlayerReplacedByAiFromJson(json);

 final  PlayerColor color;
 final  AiLevel level;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerReplacedByAiCopyWith<PlayerReplacedByAi> get copyWith => _$PlayerReplacedByAiCopyWithImpl<PlayerReplacedByAi>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayerReplacedByAiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerReplacedByAi&&(identical(other.color, color) || other.color == color)&&(identical(other.level, level) || other.level == level));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,color,level);

@override
String toString() {
  return 'GameEvent.playerReplacedByAi(color: $color, level: $level)';
}


}

/// @nodoc
abstract mixin class $PlayerReplacedByAiCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerReplacedByAiCopyWith(PlayerReplacedByAi value, $Res Function(PlayerReplacedByAi) _then) = _$PlayerReplacedByAiCopyWithImpl;
@useResult
$Res call({
 PlayerColor color, AiLevel level
});




}
/// @nodoc
class _$PlayerReplacedByAiCopyWithImpl<$Res>
    implements $PlayerReplacedByAiCopyWith<$Res> {
  _$PlayerReplacedByAiCopyWithImpl(this._self, this._then);

  final PlayerReplacedByAi _self;
  final $Res Function(PlayerReplacedByAi) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? color = null,Object? level = null,}) {
  return _then(PlayerReplacedByAi(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as PlayerColor,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as AiLevel,
  ));
}


}

/// @nodoc
@JsonSerializable()

class GameOver implements GameEvent {
  const GameOver({required final  List<PlayerColor> ranking, final  String? $type}): _ranking = ranking,$type = $type ?? 'gameOver';
  factory GameOver.fromJson(Map<String, dynamic> json) => _$GameOverFromJson(json);

 final  List<PlayerColor> _ranking;
 List<PlayerColor> get ranking {
  if (_ranking is EqualUnmodifiableListView) return _ranking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ranking);
}


@JsonKey(name: 'type')
final String $type;


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameOverCopyWith<GameOver> get copyWith => _$GameOverCopyWithImpl<GameOver>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameOverToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameOver&&const DeepCollectionEquality().equals(other._ranking, _ranking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ranking));

@override
String toString() {
  return 'GameEvent.gameOver(ranking: $ranking)';
}


}

/// @nodoc
abstract mixin class $GameOverCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $GameOverCopyWith(GameOver value, $Res Function(GameOver) _then) = _$GameOverCopyWithImpl;
@useResult
$Res call({
 List<PlayerColor> ranking
});




}
/// @nodoc
class _$GameOverCopyWithImpl<$Res>
    implements $GameOverCopyWith<$Res> {
  _$GameOverCopyWithImpl(this._self, this._then);

  final GameOver _self;
  final $Res Function(GameOver) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? ranking = null,}) {
  return _then(GameOver(
ranking: null == ranking ? _self._ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<PlayerColor>,
  ));
}


}

// dart format on

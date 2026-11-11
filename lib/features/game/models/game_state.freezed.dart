// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GameState {

 String get gameId; List<Player> get players; List<Token> get tokens; PlayerColor get currentColor; GamePhase get phase;/// The phase to enter when the current animation settles.
 GamePhase? get nextPhase;/// The committed roll the current player is choosing a move for.
 int? get dice;/// Consecutive 6s rolled in the current turn.
 int get sixesThisTurn;/// Increments at every decision point (roll, move, pass, removal).
 int get turnSeq;/// Colours that finished, first place first.
 List<PlayerColor> get ranking;/// Colours removed during play, in the order they left.
 List<PlayerColor> get leavers;/// Number of events emitted since the game started.
 int get eventSeq;
/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameStateCopyWith<GameState> get copyWith => _$GameStateCopyWithImpl<GameState>(this as GameState, _$identity);

  /// Serializes this GameState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameState&&(identical(other.gameId, gameId) || other.gameId == gameId)&&const DeepCollectionEquality().equals(other.players, players)&&const DeepCollectionEquality().equals(other.tokens, tokens)&&(identical(other.currentColor, currentColor) || other.currentColor == currentColor)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.nextPhase, nextPhase) || other.nextPhase == nextPhase)&&(identical(other.dice, dice) || other.dice == dice)&&(identical(other.sixesThisTurn, sixesThisTurn) || other.sixesThisTurn == sixesThisTurn)&&(identical(other.turnSeq, turnSeq) || other.turnSeq == turnSeq)&&const DeepCollectionEquality().equals(other.ranking, ranking)&&const DeepCollectionEquality().equals(other.leavers, leavers)&&(identical(other.eventSeq, eventSeq) || other.eventSeq == eventSeq));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameId,const DeepCollectionEquality().hash(players),const DeepCollectionEquality().hash(tokens),currentColor,phase,nextPhase,dice,sixesThisTurn,turnSeq,const DeepCollectionEquality().hash(ranking),const DeepCollectionEquality().hash(leavers),eventSeq);

@override
String toString() {
  return 'GameState(gameId: $gameId, players: $players, tokens: $tokens, currentColor: $currentColor, phase: $phase, nextPhase: $nextPhase, dice: $dice, sixesThisTurn: $sixesThisTurn, turnSeq: $turnSeq, ranking: $ranking, leavers: $leavers, eventSeq: $eventSeq)';
}


}

/// @nodoc
abstract mixin class $GameStateCopyWith<$Res>  {
  factory $GameStateCopyWith(GameState value, $Res Function(GameState) _then) = _$GameStateCopyWithImpl;
@useResult
$Res call({
 String gameId, List<Player> players, List<Token> tokens, PlayerColor currentColor, GamePhase phase, GamePhase? nextPhase, int? dice, int sixesThisTurn, int turnSeq, List<PlayerColor> ranking, List<PlayerColor> leavers, int eventSeq
});




}
/// @nodoc
class _$GameStateCopyWithImpl<$Res>
    implements $GameStateCopyWith<$Res> {
  _$GameStateCopyWithImpl(this._self, this._then);

  final GameState _self;
  final $Res Function(GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? gameId = null,Object? players = null,Object? tokens = null,Object? currentColor = null,Object? phase = null,Object? nextPhase = freezed,Object? dice = freezed,Object? sixesThisTurn = null,Object? turnSeq = null,Object? ranking = null,Object? leavers = null,Object? eventSeq = null,}) {
  return _then(_self.copyWith(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self.players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,tokens: null == tokens ? _self.tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<Token>,currentColor: null == currentColor ? _self.currentColor : currentColor // ignore: cast_nullable_to_non_nullable
as PlayerColor,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as GamePhase,nextPhase: freezed == nextPhase ? _self.nextPhase : nextPhase // ignore: cast_nullable_to_non_nullable
as GamePhase?,dice: freezed == dice ? _self.dice : dice // ignore: cast_nullable_to_non_nullable
as int?,sixesThisTurn: null == sixesThisTurn ? _self.sixesThisTurn : sixesThisTurn // ignore: cast_nullable_to_non_nullable
as int,turnSeq: null == turnSeq ? _self.turnSeq : turnSeq // ignore: cast_nullable_to_non_nullable
as int,ranking: null == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<PlayerColor>,leavers: null == leavers ? _self.leavers : leavers // ignore: cast_nullable_to_non_nullable
as List<PlayerColor>,eventSeq: null == eventSeq ? _self.eventSeq : eventSeq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameState].
extension GameStatePatterns on GameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameState value)  $default,){
final _that = this;
switch (_that) {
case _GameState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameState value)?  $default,){
final _that = this;
switch (_that) {
case _GameState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String gameId,  List<Player> players,  List<Token> tokens,  PlayerColor currentColor,  GamePhase phase,  GamePhase? nextPhase,  int? dice,  int sixesThisTurn,  int turnSeq,  List<PlayerColor> ranking,  List<PlayerColor> leavers,  int eventSeq)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.gameId,_that.players,_that.tokens,_that.currentColor,_that.phase,_that.nextPhase,_that.dice,_that.sixesThisTurn,_that.turnSeq,_that.ranking,_that.leavers,_that.eventSeq);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String gameId,  List<Player> players,  List<Token> tokens,  PlayerColor currentColor,  GamePhase phase,  GamePhase? nextPhase,  int? dice,  int sixesThisTurn,  int turnSeq,  List<PlayerColor> ranking,  List<PlayerColor> leavers,  int eventSeq)  $default,) {final _that = this;
switch (_that) {
case _GameState():
return $default(_that.gameId,_that.players,_that.tokens,_that.currentColor,_that.phase,_that.nextPhase,_that.dice,_that.sixesThisTurn,_that.turnSeq,_that.ranking,_that.leavers,_that.eventSeq);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String gameId,  List<Player> players,  List<Token> tokens,  PlayerColor currentColor,  GamePhase phase,  GamePhase? nextPhase,  int? dice,  int sixesThisTurn,  int turnSeq,  List<PlayerColor> ranking,  List<PlayerColor> leavers,  int eventSeq)?  $default,) {final _that = this;
switch (_that) {
case _GameState() when $default != null:
return $default(_that.gameId,_that.players,_that.tokens,_that.currentColor,_that.phase,_that.nextPhase,_that.dice,_that.sixesThisTurn,_that.turnSeq,_that.ranking,_that.leavers,_that.eventSeq);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GameState extends GameState {
  const _GameState({required this.gameId, required final  List<Player> players, required final  List<Token> tokens, required this.currentColor, required this.phase, this.nextPhase, this.dice, this.sixesThisTurn = 0, this.turnSeq = 0, final  List<PlayerColor> ranking = const <PlayerColor>[], final  List<PlayerColor> leavers = const <PlayerColor>[], this.eventSeq = 0}): _players = players,_tokens = tokens,_ranking = ranking,_leavers = leavers,super._();
  factory _GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);

@override final  String gameId;
 final  List<Player> _players;
@override List<Player> get players {
  if (_players is EqualUnmodifiableListView) return _players;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_players);
}

 final  List<Token> _tokens;
@override List<Token> get tokens {
  if (_tokens is EqualUnmodifiableListView) return _tokens;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tokens);
}

@override final  PlayerColor currentColor;
@override final  GamePhase phase;
/// The phase to enter when the current animation settles.
@override final  GamePhase? nextPhase;
/// The committed roll the current player is choosing a move for.
@override final  int? dice;
/// Consecutive 6s rolled in the current turn.
@override@JsonKey() final  int sixesThisTurn;
/// Increments at every decision point (roll, move, pass, removal).
@override@JsonKey() final  int turnSeq;
/// Colours that finished, first place first.
 final  List<PlayerColor> _ranking;
/// Colours that finished, first place first.
@override@JsonKey() List<PlayerColor> get ranking {
  if (_ranking is EqualUnmodifiableListView) return _ranking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ranking);
}

/// Colours removed during play, in the order they left.
 final  List<PlayerColor> _leavers;
/// Colours removed during play, in the order they left.
@override@JsonKey() List<PlayerColor> get leavers {
  if (_leavers is EqualUnmodifiableListView) return _leavers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_leavers);
}

/// Number of events emitted since the game started.
@override@JsonKey() final  int eventSeq;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameStateCopyWith<_GameState> get copyWith => __$GameStateCopyWithImpl<_GameState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GameStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameState&&(identical(other.gameId, gameId) || other.gameId == gameId)&&const DeepCollectionEquality().equals(other._players, _players)&&const DeepCollectionEquality().equals(other._tokens, _tokens)&&(identical(other.currentColor, currentColor) || other.currentColor == currentColor)&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.nextPhase, nextPhase) || other.nextPhase == nextPhase)&&(identical(other.dice, dice) || other.dice == dice)&&(identical(other.sixesThisTurn, sixesThisTurn) || other.sixesThisTurn == sixesThisTurn)&&(identical(other.turnSeq, turnSeq) || other.turnSeq == turnSeq)&&const DeepCollectionEquality().equals(other._ranking, _ranking)&&const DeepCollectionEquality().equals(other._leavers, _leavers)&&(identical(other.eventSeq, eventSeq) || other.eventSeq == eventSeq));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,gameId,const DeepCollectionEquality().hash(_players),const DeepCollectionEquality().hash(_tokens),currentColor,phase,nextPhase,dice,sixesThisTurn,turnSeq,const DeepCollectionEquality().hash(_ranking),const DeepCollectionEquality().hash(_leavers),eventSeq);

@override
String toString() {
  return 'GameState(gameId: $gameId, players: $players, tokens: $tokens, currentColor: $currentColor, phase: $phase, nextPhase: $nextPhase, dice: $dice, sixesThisTurn: $sixesThisTurn, turnSeq: $turnSeq, ranking: $ranking, leavers: $leavers, eventSeq: $eventSeq)';
}


}

/// @nodoc
abstract mixin class _$GameStateCopyWith<$Res> implements $GameStateCopyWith<$Res> {
  factory _$GameStateCopyWith(_GameState value, $Res Function(_GameState) _then) = __$GameStateCopyWithImpl;
@override @useResult
$Res call({
 String gameId, List<Player> players, List<Token> tokens, PlayerColor currentColor, GamePhase phase, GamePhase? nextPhase, int? dice, int sixesThisTurn, int turnSeq, List<PlayerColor> ranking, List<PlayerColor> leavers, int eventSeq
});




}
/// @nodoc
class __$GameStateCopyWithImpl<$Res>
    implements _$GameStateCopyWith<$Res> {
  __$GameStateCopyWithImpl(this._self, this._then);

  final _GameState _self;
  final $Res Function(_GameState) _then;

/// Create a copy of GameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? gameId = null,Object? players = null,Object? tokens = null,Object? currentColor = null,Object? phase = null,Object? nextPhase = freezed,Object? dice = freezed,Object? sixesThisTurn = null,Object? turnSeq = null,Object? ranking = null,Object? leavers = null,Object? eventSeq = null,}) {
  return _then(_GameState(
gameId: null == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String,players: null == players ? _self._players : players // ignore: cast_nullable_to_non_nullable
as List<Player>,tokens: null == tokens ? _self._tokens : tokens // ignore: cast_nullable_to_non_nullable
as List<Token>,currentColor: null == currentColor ? _self.currentColor : currentColor // ignore: cast_nullable_to_non_nullable
as PlayerColor,phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as GamePhase,nextPhase: freezed == nextPhase ? _self.nextPhase : nextPhase // ignore: cast_nullable_to_non_nullable
as GamePhase?,dice: freezed == dice ? _self.dice : dice // ignore: cast_nullable_to_non_nullable
as int?,sixesThisTurn: null == sixesThisTurn ? _self.sixesThisTurn : sixesThisTurn // ignore: cast_nullable_to_non_nullable
as int,turnSeq: null == turnSeq ? _self.turnSeq : turnSeq // ignore: cast_nullable_to_non_nullable
as int,ranking: null == ranking ? _self._ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<PlayerColor>,leavers: null == leavers ? _self._leavers : leavers // ignore: cast_nullable_to_non_nullable
as List<PlayerColor>,eventSeq: null == eventSeq ? _self.eventSeq : eventSeq // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

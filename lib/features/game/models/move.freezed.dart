// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'move.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Move {

 int get tokenId; int get fromRel; int get toRel;/// Opponent tokens sent back to base by this move.
 List<TokenRef> get captures;/// True when the token leaves base onto its start cell.
 bool get entersBase;/// True when the token lands exactly on HOME.
 bool get reachesHome;/// True when the destination is a safe cell or the home column.
 bool get landsSafe;
/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoveCopyWith<Move> get copyWith => _$MoveCopyWithImpl<Move>(this as Move, _$identity);

  /// Serializes this Move to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Move&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.fromRel, fromRel) || other.fromRel == fromRel)&&(identical(other.toRel, toRel) || other.toRel == toRel)&&const DeepCollectionEquality().equals(other.captures, captures)&&(identical(other.entersBase, entersBase) || other.entersBase == entersBase)&&(identical(other.reachesHome, reachesHome) || other.reachesHome == reachesHome)&&(identical(other.landsSafe, landsSafe) || other.landsSafe == landsSafe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenId,fromRel,toRel,const DeepCollectionEquality().hash(captures),entersBase,reachesHome,landsSafe);

@override
String toString() {
  return 'Move(tokenId: $tokenId, fromRel: $fromRel, toRel: $toRel, captures: $captures, entersBase: $entersBase, reachesHome: $reachesHome, landsSafe: $landsSafe)';
}


}

/// @nodoc
abstract mixin class $MoveCopyWith<$Res>  {
  factory $MoveCopyWith(Move value, $Res Function(Move) _then) = _$MoveCopyWithImpl;
@useResult
$Res call({
 int tokenId, int fromRel, int toRel, List<TokenRef> captures, bool entersBase, bool reachesHome, bool landsSafe
});




}
/// @nodoc
class _$MoveCopyWithImpl<$Res>
    implements $MoveCopyWith<$Res> {
  _$MoveCopyWithImpl(this._self, this._then);

  final Move _self;
  final $Res Function(Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tokenId = null,Object? fromRel = null,Object? toRel = null,Object? captures = null,Object? entersBase = null,Object? reachesHome = null,Object? landsSafe = null,}) {
  return _then(_self.copyWith(
tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int,fromRel: null == fromRel ? _self.fromRel : fromRel // ignore: cast_nullable_to_non_nullable
as int,toRel: null == toRel ? _self.toRel : toRel // ignore: cast_nullable_to_non_nullable
as int,captures: null == captures ? _self.captures : captures // ignore: cast_nullable_to_non_nullable
as List<TokenRef>,entersBase: null == entersBase ? _self.entersBase : entersBase // ignore: cast_nullable_to_non_nullable
as bool,reachesHome: null == reachesHome ? _self.reachesHome : reachesHome // ignore: cast_nullable_to_non_nullable
as bool,landsSafe: null == landsSafe ? _self.landsSafe : landsSafe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Move].
extension MovePatterns on Move {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Move value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Move() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Move value)  $default,){
final _that = this;
switch (_that) {
case _Move():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Move value)?  $default,){
final _that = this;
switch (_that) {
case _Move() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tokenId,  int fromRel,  int toRel,  List<TokenRef> captures,  bool entersBase,  bool reachesHome,  bool landsSafe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Move() when $default != null:
return $default(_that.tokenId,_that.fromRel,_that.toRel,_that.captures,_that.entersBase,_that.reachesHome,_that.landsSafe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tokenId,  int fromRel,  int toRel,  List<TokenRef> captures,  bool entersBase,  bool reachesHome,  bool landsSafe)  $default,) {final _that = this;
switch (_that) {
case _Move():
return $default(_that.tokenId,_that.fromRel,_that.toRel,_that.captures,_that.entersBase,_that.reachesHome,_that.landsSafe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tokenId,  int fromRel,  int toRel,  List<TokenRef> captures,  bool entersBase,  bool reachesHome,  bool landsSafe)?  $default,) {final _that = this;
switch (_that) {
case _Move() when $default != null:
return $default(_that.tokenId,_that.fromRel,_that.toRel,_that.captures,_that.entersBase,_that.reachesHome,_that.landsSafe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Move extends Move {
  const _Move({required this.tokenId, required this.fromRel, required this.toRel, final  List<TokenRef> captures = const <TokenRef>[], this.entersBase = false, this.reachesHome = false, this.landsSafe = false}): _captures = captures,super._();
  factory _Move.fromJson(Map<String, dynamic> json) => _$MoveFromJson(json);

@override final  int tokenId;
@override final  int fromRel;
@override final  int toRel;
/// Opponent tokens sent back to base by this move.
 final  List<TokenRef> _captures;
/// Opponent tokens sent back to base by this move.
@override@JsonKey() List<TokenRef> get captures {
  if (_captures is EqualUnmodifiableListView) return _captures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_captures);
}

/// True when the token leaves base onto its start cell.
@override@JsonKey() final  bool entersBase;
/// True when the token lands exactly on HOME.
@override@JsonKey() final  bool reachesHome;
/// True when the destination is a safe cell or the home column.
@override@JsonKey() final  bool landsSafe;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoveCopyWith<_Move> get copyWith => __$MoveCopyWithImpl<_Move>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Move&&(identical(other.tokenId, tokenId) || other.tokenId == tokenId)&&(identical(other.fromRel, fromRel) || other.fromRel == fromRel)&&(identical(other.toRel, toRel) || other.toRel == toRel)&&const DeepCollectionEquality().equals(other._captures, _captures)&&(identical(other.entersBase, entersBase) || other.entersBase == entersBase)&&(identical(other.reachesHome, reachesHome) || other.reachesHome == reachesHome)&&(identical(other.landsSafe, landsSafe) || other.landsSafe == landsSafe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tokenId,fromRel,toRel,const DeepCollectionEquality().hash(_captures),entersBase,reachesHome,landsSafe);

@override
String toString() {
  return 'Move(tokenId: $tokenId, fromRel: $fromRel, toRel: $toRel, captures: $captures, entersBase: $entersBase, reachesHome: $reachesHome, landsSafe: $landsSafe)';
}


}

/// @nodoc
abstract mixin class _$MoveCopyWith<$Res> implements $MoveCopyWith<$Res> {
  factory _$MoveCopyWith(_Move value, $Res Function(_Move) _then) = __$MoveCopyWithImpl;
@override @useResult
$Res call({
 int tokenId, int fromRel, int toRel, List<TokenRef> captures, bool entersBase, bool reachesHome, bool landsSafe
});




}
/// @nodoc
class __$MoveCopyWithImpl<$Res>
    implements _$MoveCopyWith<$Res> {
  __$MoveCopyWithImpl(this._self, this._then);

  final _Move _self;
  final $Res Function(_Move) _then;

/// Create a copy of Move
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tokenId = null,Object? fromRel = null,Object? toRel = null,Object? captures = null,Object? entersBase = null,Object? reachesHome = null,Object? landsSafe = null,}) {
  return _then(_Move(
tokenId: null == tokenId ? _self.tokenId : tokenId // ignore: cast_nullable_to_non_nullable
as int,fromRel: null == fromRel ? _self.fromRel : fromRel // ignore: cast_nullable_to_non_nullable
as int,toRel: null == toRel ? _self.toRel : toRel // ignore: cast_nullable_to_non_nullable
as int,captures: null == captures ? _self._captures : captures // ignore: cast_nullable_to_non_nullable
as List<TokenRef>,entersBase: null == entersBase ? _self.entersBase : entersBase // ignore: cast_nullable_to_non_nullable
as bool,reachesHome: null == reachesHome ? _self.reachesHome : reachesHome // ignore: cast_nullable_to_non_nullable
as bool,landsSafe: null == landsSafe ? _self.landsSafe : landsSafe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

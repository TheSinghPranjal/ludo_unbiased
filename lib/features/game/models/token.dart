import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ludo_unbiased/core/constants/board_constants.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';

part 'token.freezed.dart';
part 'token.g.dart';

/// One of a player's four pieces.
///
/// [rel] is the token's progress along its own route: -1 in base, 0–50 on
/// the main track, 51–55 in its home column, 56 at HOME.
@freezed
abstract class Token with _$Token {
  /// Creates a token.
  const factory Token({
    required int id,
    required PlayerColor color,
    required int rel,
  }) = _Token;

  const Token._();

  /// Reads a token written by `toJson`.
  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  /// True while the token waits in its yard.
  bool get isInBase => rel == BoardConstants.baseRel;

  /// True once the token has finished.
  bool get isHome => rel == BoardConstants.homeRel;

  /// True while the token is on the shared 52-cell loop.
  bool get isOnTrack => rel >= 0 && rel <= BoardConstants.lastTrackRel;

  /// True while the token is in its own home column.
  bool get isInHomeColumn =>
      rel >= BoardConstants.firstHomeColumnRel && rel < BoardConstants.homeRel;
}

/// Identifies a token without its position.
@freezed
abstract class TokenRef with _$TokenRef {
  /// Creates a reference to token [id] of [color].
  const factory TokenRef({required PlayerColor color, required int id}) =
      _TokenRef;

  /// Reads a reference written by `toJson`.
  factory TokenRef.fromJson(Map<String, dynamic> json) =>
      _$TokenRefFromJson(json);
}

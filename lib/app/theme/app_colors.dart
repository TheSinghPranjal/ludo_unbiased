import 'package:flutter/material.dart';

/// App UI colours (spec §1.9). Widgets read colours only from here, the
/// board palette and the [ColorScheme] built from them.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  /// Creates the colours.
  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.text,
    required this.text2,
    required this.border,
    required this.primary,
    required this.onPrimary,
    required this.danger,
    required this.onDanger,
  });

  /// Light UI. All text pairs pass WCAG AA.
  static const light = AppColors(
    background: Color(0xFFF4F5F9),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFEEF0F6),
    text: Color(0xFF1B1E28),
    text2: Color(0xFF596074),
    border: Color(0xFFD6DAE3),
    primary: Color(0xFF2563C9),
    onPrimary: Color(0xFFFFFFFF),
    danger: Color(0xFFC42B23),
    onDanger: Color(0xFFFFFFFF),
  );

  /// Dark UI, from the spec's night palette.
  static const dark = AppColors(
    background: Color(0xFF12141C),
    surface: Color(0xFF1D2030),
    surface2: Color(0xFF262A3C),
    text: Color(0xFFF2F3F7),
    text2: Color(0xFFA9AEC2),
    border: Color(0xFF343A4F),
    primary: Color(0xFF6EA6EE),
    onPrimary: Color(0xFF12141C),
    danger: Color(0xFFEB6F67),
    onDanger: Color(0xFF12141C),
  );

  /// Page background.
  final Color background;

  /// Cards and sheets.
  final Color surface;

  /// Secondary surfaces: status line, segmented controls.
  final Color surface2;

  /// Main text.
  final Color text;

  /// Secondary text.
  final Color text2;

  /// Outlines and dividers.
  final Color border;

  /// Primary actions.
  final Color primary;

  /// Text and icons on [primary].
  final Color onPrimary;

  /// Destructive actions.
  final Color danger;

  /// Text and icons on [danger].
  final Color onDanger;

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? text,
    Color? text2,
    Color? border,
    Color? primary,
    Color? onPrimary,
    Color? danger,
    Color? onDanger,
  }) => AppColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surface2: surface2 ?? this.surface2,
    text: text ?? this.text,
    text2: text2 ?? this.text2,
    border: border ?? this.border,
    primary: primary ?? this.primary,
    onPrimary: onPrimary ?? this.onPrimary,
    danger: danger ?? this.danger,
    onDanger: onDanger ?? this.onDanger,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      text: l(text, other.text),
      text2: l(text2, other.text2),
      border: l(border, other.border),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      danger: l(danger, other.danger),
      onDanger: l(onDanger, other.onDanger),
    );
  }
}

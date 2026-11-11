import 'package:flutter/material.dart';
import 'package:ludo_unbiased/app/theme/app_colors.dart';
import 'package:ludo_unbiased/app/theme/board_palette.dart';

/// Builds the light and dark [ThemeData] from the theme extensions.
abstract final class AppTheme {
  /// Light theme.
  static ThemeData get light =>
      _build(Brightness.light, AppColors.light, BoardPalette.light);

  /// Dark theme.
  static ThemeData get dark =>
      _build(Brightness.dark, AppColors.dark, BoardPalette.dark);

  static ThemeData _build(Brightness b, AppColors c, BoardPalette p) {
    final scheme = ColorScheme(
      brightness: b,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.primary,
      onSecondary: c.onPrimary,
      error: c.danger,
      onError: c.onDanger,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.text2,
      surfaceContainerHighest: c.surface2,
      outline: c.border,
      outlineVariant: c.border,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      extensions: [c, p],
    );
  }
}

/// Theme lookups for widgets.
extension ThemeColors on BuildContext {
  /// App UI colours.
  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  /// Board colours.
  BoardPalette get board => Theme.of(this).extension<BoardPalette>()!;
}

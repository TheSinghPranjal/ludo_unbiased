import 'package:flutter/widgets.dart';
import 'package:ludo_unbiased/features/game/models/player_color.dart';
import 'package:ludo_unbiased/l10n/gen/app_localizations.dart';

export 'package:ludo_unbiased/l10n/gen/app_localizations.dart';

/// Short access to the strings: `context.l10n.roll`.
extension L10nContext on BuildContext {
  /// Strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localized colour names.
extension PlayerColorName on AppLocalizations {
  /// "Red", "लाल", ...
  String colorName(PlayerColor c) => switch (c) {
    PlayerColor.red => colorRed,
    PlayerColor.blue => colorBlue,
    PlayerColor.yellow => colorYellow,
    PlayerColor.green => colorGreen,
  };
}

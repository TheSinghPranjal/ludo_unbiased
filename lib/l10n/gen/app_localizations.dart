import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('pt'),
  ];

  /// App name, shown in the task switcher and read by screen readers.
  ///
  /// In en, this message translates to:
  /// **'Ludo Unbiased'**
  String get appTitle;

  /// This language's own name, shown in the language picker.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageName;

  /// Primary Home button: starts a fresh game vs AI.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @quickPlay.
  ///
  /// In en, this message translates to:
  /// **'Quick Play vs AI'**
  String get quickPlay;

  /// No description provided for @playLocal.
  ///
  /// In en, this message translates to:
  /// **'Play Local'**
  String get playLocal;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// Name of the local player in Quick Play.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @localGame.
  ///
  /// In en, this message translates to:
  /// **'Local game'**
  String get localGame;

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get playerCount;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @playerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'{color} name'**
  String playerNameLabel(String color);

  /// No description provided for @human.
  ///
  /// In en, this message translates to:
  /// **'Human'**
  String get human;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @leaveGame.
  ///
  /// In en, this message translates to:
  /// **'Leave game'**
  String get leaveGame;

  /// No description provided for @leaveGameQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave game?'**
  String get leaveGameQuestion;

  /// No description provided for @leaveSavedNote.
  ///
  /// In en, this message translates to:
  /// **'Your game is saved. You can continue it from Home.'**
  String get leaveSavedNote;

  /// No description provided for @leaveUnsavedNote.
  ///
  /// In en, this message translates to:
  /// **'You will leave this game.'**
  String get leaveUnsavedNote;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @roll.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get roll;

  /// Appended to a computer player's name.
  ///
  /// In en, this message translates to:
  /// **'(AI)'**
  String get aiSuffix;

  /// No description provided for @turnTimer.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds left'**
  String turnTimer(int seconds);

  /// No description provided for @turnYours.
  ///
  /// In en, this message translates to:
  /// **'Your turn'**
  String get turnYours;

  /// No description provided for @turnOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s turn'**
  String turnOf(String name);

  /// No description provided for @rankOrdinal.
  ///
  /// In en, this message translates to:
  /// **'{rank, select, 1{1st} 2{2nd} 3{3rd} other{4th}}'**
  String rankOrdinal(String rank);

  /// No description provided for @statusWins.
  ///
  /// In en, this message translates to:
  /// **'{name} wins!'**
  String statusWins(String name);

  /// No description provided for @statusFinished.
  ///
  /// In en, this message translates to:
  /// **'{name} finished {ordinal}!'**
  String statusFinished(String name, String ordinal);

  /// No description provided for @statusThreeSixes.
  ///
  /// In en, this message translates to:
  /// **'Three 6s. {name} loses the turn.'**
  String statusThreeSixes(String name);

  /// No description provided for @statusCaptured.
  ///
  /// In en, this message translates to:
  /// **'{by} captured {victim}!'**
  String statusCaptured(String by, String victim);

  /// No description provided for @statusExtraSix.
  ///
  /// In en, this message translates to:
  /// **'{name} rolled 6, extra roll!'**
  String statusExtraSix(String name);

  /// No description provided for @statusExtraCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture! {name} rolls again.'**
  String statusExtraCapture(String name);

  /// No description provided for @statusExtraHome.
  ///
  /// In en, this message translates to:
  /// **'Token home! {name} rolls again.'**
  String statusExtraHome(String name);

  /// No description provided for @statusNoMoves.
  ///
  /// In en, this message translates to:
  /// **'No moves for {name}. {next}.'**
  String statusNoMoves(String name, String next);

  /// No description provided for @statusLeftTurn.
  ///
  /// In en, this message translates to:
  /// **'{name} left. {next}.'**
  String statusLeftTurn(String name, String next);

  /// No description provided for @statusLeft.
  ///
  /// In en, this message translates to:
  /// **'{name} left the game.'**
  String statusLeft(String name);

  /// No description provided for @statusRolled.
  ///
  /// In en, this message translates to:
  /// **'{name} rolled {value}'**
  String statusRolled(String name, int value);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @appearanceHint.
  ///
  /// In en, this message translates to:
  /// **'System follows your phone\'s light or dark mode.'**
  String get appearanceHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @soundAndVibration.
  ///
  /// In en, this message translates to:
  /// **'Sound and vibration'**
  String get soundAndVibration;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @soundEffectsHint.
  ///
  /// In en, this message translates to:
  /// **'Dice, moves, captures, timer'**
  String get soundEffectsHint;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @musicHint.
  ///
  /// In en, this message translates to:
  /// **'One calm background loop'**
  String get musicHint;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationHint.
  ///
  /// In en, this message translates to:
  /// **'Dice landing, token steps, captures'**
  String get vibrationHint;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @howToPlayHint.
  ///
  /// In en, this message translates to:
  /// **'The rules in five quick cards'**
  String get howToPlayHint;

  /// No description provided for @htpTitle1.
  ///
  /// In en, this message translates to:
  /// **'Roll a 6 to leave base'**
  String get htpTitle1;

  /// No description provided for @htpBody1.
  ///
  /// In en, this message translates to:
  /// **'All four tokens start in your base. A 6 moves one out onto your start square.'**
  String get htpBody1;

  /// No description provided for @htpTitle2.
  ///
  /// In en, this message translates to:
  /// **'Move around the board'**
  String get htpTitle2;

  /// No description provided for @htpBody2.
  ///
  /// In en, this message translates to:
  /// **'Tap the dice, then tap a glowing token. It moves clockwise by the number you rolled.'**
  String get htpBody2;

  /// No description provided for @htpTitle3.
  ///
  /// In en, this message translates to:
  /// **'Capture, or stay safe'**
  String get htpTitle3;

  /// No description provided for @htpBody3.
  ///
  /// In en, this message translates to:
  /// **'Land on an opponent to send it back to base. Star and start squares are safe: nobody is captured there.'**
  String get htpBody3;

  /// No description provided for @htpTitle4.
  ///
  /// In en, this message translates to:
  /// **'Earn extra rolls'**
  String get htpTitle4;

  /// No description provided for @htpBody4.
  ///
  /// In en, this message translates to:
  /// **'Rolling a 6, capturing or bringing a token home gives you another roll. Three 6s in a row lose the turn.'**
  String get htpBody4;

  /// No description provided for @htpTitle5.
  ///
  /// In en, this message translates to:
  /// **'Bring all four home'**
  String get htpTitle5;

  /// No description provided for @htpBody5.
  ///
  /// In en, this message translates to:
  /// **'Walk up your home column with an exact roll. The first player with all four tokens home wins.'**
  String get htpBody5;

  /// No description provided for @htpProgress.
  ///
  /// In en, this message translates to:
  /// **'Card {current} of {total}'**
  String htpProgress(int current, int total);

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'hi', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

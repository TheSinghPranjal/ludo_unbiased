// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ludo Unbiased';

  @override
  String get languageName => 'English';

  @override
  String get newGame => 'New Game';

  @override
  String get continueGame => 'Continue';

  @override
  String get quickPlay => 'Quick Play vs AI';

  @override
  String get playLocal => 'Play Local';

  @override
  String get settings => 'Settings';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get you => 'You';

  @override
  String get localGame => 'Local game';

  @override
  String get playerCount => 'Players';

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String playerNameLabel(String color) {
    return '$color name';
  }

  @override
  String get human => 'Human';

  @override
  String get ai => 'AI';

  @override
  String get easy => 'Easy';

  @override
  String get normal => 'Normal';

  @override
  String get startGame => 'Start game';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get paused => 'Paused';

  @override
  String get pause => 'Pause';

  @override
  String get menu => 'Menu';

  @override
  String get resume => 'Resume';

  @override
  String get leaveGame => 'Leave game';

  @override
  String get leaveGameQuestion => 'Leave game?';

  @override
  String get leaveSavedNote =>
      'Your game is saved. You can continue it from Home.';

  @override
  String get leaveUnsavedNote => 'You will leave this game.';

  @override
  String get leave => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String get players => 'Players';

  @override
  String get playAgain => 'Play Again';

  @override
  String get home => 'Home';

  @override
  String get roll => 'Roll';

  @override
  String get aiSuffix => '(AI)';

  @override
  String turnTimer(int seconds) {
    return '$seconds seconds left';
  }

  @override
  String get turnYours => 'Your turn';

  @override
  String turnOf(String name) {
    return '$name\'s turn';
  }

  @override
  String rankOrdinal(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': '1st',
        '2': '2nd',
        '3': '3rd',
        'other': '4th',
      },
    );
    return '$_temp0';
  }

  @override
  String statusWins(String name) {
    return '$name wins!';
  }

  @override
  String statusFinished(String name, String ordinal) {
    return '$name finished $ordinal!';
  }

  @override
  String statusThreeSixes(String name) {
    return 'Three 6s. $name loses the turn.';
  }

  @override
  String statusCaptured(String by, String victim) {
    return '$by captured $victim!';
  }

  @override
  String statusExtraSix(String name) {
    return '$name rolled 6, extra roll!';
  }

  @override
  String statusExtraCapture(String name) {
    return 'Capture! $name rolls again.';
  }

  @override
  String statusExtraHome(String name) {
    return 'Token home! $name rolls again.';
  }

  @override
  String statusNoMoves(String name, String next) {
    return 'No moves for $name. $next.';
  }

  @override
  String statusLeftTurn(String name, String next) {
    return '$name left. $next.';
  }

  @override
  String statusLeft(String name) {
    return '$name left the game.';
  }

  @override
  String statusRolled(String name, int value) {
    return '$name rolled $value';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get appearanceHint =>
      'System follows your phone\'s light or dark mode.';

  @override
  String get language => 'Language';

  @override
  String get soundAndVibration => 'Sound and vibration';

  @override
  String get soundEffects => 'Sound effects';

  @override
  String get soundEffectsHint => 'Dice, moves, captures, timer';

  @override
  String get music => 'Music';

  @override
  String get musicHint => 'One calm background loop';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationHint => 'Dice landing, token steps, captures';

  @override
  String get help => 'Help';

  @override
  String get howToPlayHint => 'The rules in five quick cards';

  @override
  String get htpTitle1 => 'Roll a 6 to leave base';

  @override
  String get htpBody1 =>
      'All four tokens start in your base. A 6 moves one out onto your start square.';

  @override
  String get htpTitle2 => 'Move around the board';

  @override
  String get htpBody2 =>
      'Tap the dice, then tap a glowing token. It moves clockwise by the number you rolled.';

  @override
  String get htpTitle3 => 'Capture, or stay safe';

  @override
  String get htpBody3 =>
      'Land on an opponent to send it back to base. Star and start squares are safe: nobody is captured there.';

  @override
  String get htpTitle4 => 'Earn extra rolls';

  @override
  String get htpBody4 =>
      'Rolling a 6, capturing or bringing a token home gives you another roll. Three 6s in a row lose the turn.';

  @override
  String get htpTitle5 => 'Bring all four home';

  @override
  String get htpBody5 =>
      'Walk up your home column with an exact roll. The first player with all four tokens home wins.';

  @override
  String htpProgress(int current, int total) {
    return 'Card $current of $total';
  }

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get gotIt => 'Got it';

  @override
  String get close => 'Close';
}

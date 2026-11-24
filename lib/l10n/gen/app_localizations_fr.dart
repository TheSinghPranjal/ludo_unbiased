// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Ludo Unbiased';

  @override
  String get languageName => 'Français';

  @override
  String get continueGame => 'Continuer';

  @override
  String get quickPlay => 'Partie rapide contre l\'IA';

  @override
  String get playLocal => 'Jouer en local';

  @override
  String get settings => 'Paramètres';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get you => 'Vous';

  @override
  String get localGame => 'Partie locale';

  @override
  String get playerCount => 'Joueurs';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorGreen => 'Vert';

  @override
  String playerNameLabel(String color) {
    return 'Nom du $color';
  }

  @override
  String get human => 'Humain';

  @override
  String get ai => 'IA';

  @override
  String get easy => 'Facile';

  @override
  String get normal => 'Normal';

  @override
  String get startGame => 'Commencer';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get paused => 'En pause';

  @override
  String get pause => 'Pause';

  @override
  String get menu => 'Menu';

  @override
  String get resume => 'Reprendre';

  @override
  String get leaveGame => 'Quitter la partie';

  @override
  String get leaveGameQuestion => 'Quitter la partie ?';

  @override
  String get leaveSavedNote =>
      'Votre partie est enregistrée. Vous pourrez la reprendre depuis l\'accueil.';

  @override
  String get leaveUnsavedNote => 'Vous allez quitter cette partie.';

  @override
  String get leave => 'Quitter';

  @override
  String get stay => 'Rester';

  @override
  String get players => 'Joueurs';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get home => 'Accueil';

  @override
  String get roll => 'Lancer';

  @override
  String get aiSuffix => '(IA)';

  @override
  String turnTimer(int seconds) {
    return '$seconds secondes restantes';
  }

  @override
  String get turnYours => 'À vous de jouer';

  @override
  String turnOf(String name) {
    return 'Au tour de $name';
  }

  @override
  String rankOrdinal(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': '1er',
        '2': '2e',
        '3': '3e',
        'other': '4e',
      },
    );
    return '$_temp0';
  }

  @override
  String statusWins(String name) {
    return '$name gagne !';
  }

  @override
  String statusFinished(String name, String ordinal) {
    return '$name termine $ordinal !';
  }

  @override
  String statusThreeSixes(String name) {
    return 'Trois 6. $name perd son tour.';
  }

  @override
  String statusCaptured(String by, String victim) {
    return '$by a capturé $victim !';
  }

  @override
  String statusExtraSix(String name) {
    return '$name a fait 6, lancer bonus !';
  }

  @override
  String statusExtraCapture(String name) {
    return 'Capture ! $name relance.';
  }

  @override
  String statusExtraHome(String name) {
    return 'Pion arrivé ! $name relance.';
  }

  @override
  String statusNoMoves(String name, String next) {
    return 'Aucun coup pour $name. $next.';
  }

  @override
  String statusLeftTurn(String name, String next) {
    return '$name est parti. $next.';
  }

  @override
  String statusLeft(String name) {
    return '$name a quitté la partie.';
  }

  @override
  String statusRolled(String name, int value) {
    return '$name a fait $value';
  }

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get appearanceHint =>
      'Système suit le mode clair ou sombre du téléphone.';

  @override
  String get language => 'Langue';

  @override
  String get soundAndVibration => 'Son et vibration';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get soundEffectsHint => 'Dé, déplacements, captures, minuteur';

  @override
  String get music => 'Musique';

  @override
  String get musicHint => 'Une boucle de fond apaisante';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationHint => 'Chute du dé, pas des pions, captures';

  @override
  String get help => 'Aide';

  @override
  String get howToPlayHint => 'Les règles en cinq cartes';

  @override
  String get htpTitle1 => 'Faites 6 pour sortir';

  @override
  String get htpBody1 =>
      'Vos quatre pions commencent dans votre base. Un 6 en fait sortir un sur votre case de départ.';

  @override
  String get htpTitle2 => 'Avancez sur le plateau';

  @override
  String get htpBody2 =>
      'Touchez le dé, puis un pion qui brille. Il avance dans le sens horaire du nombre obtenu.';

  @override
  String get htpTitle3 => 'Capturez ou restez à l\'abri';

  @override
  String get htpBody3 =>
      'Arrivez sur un adversaire pour le renvoyer à sa base. Les étoiles et les cases de départ sont sûres : personne n\'y est capturé.';

  @override
  String get htpTitle4 => 'Gagnez des lancers bonus';

  @override
  String get htpBody4 =>
      'Faire 6, capturer ou ramener un pion vous donne un autre lancer. Trois 6 de suite font perdre le tour.';

  @override
  String get htpTitle5 => 'Ramenez les quatre';

  @override
  String get htpBody5 =>
      'Montez votre colonne avec le nombre exact. Le premier à ramener ses quatre pions gagne.';

  @override
  String htpProgress(int current, int total) {
    return 'Carte $current sur $total';
  }

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get gotIt => 'Compris';

  @override
  String get close => 'Fermer';
}

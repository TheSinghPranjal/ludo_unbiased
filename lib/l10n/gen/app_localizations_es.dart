// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Ludo Unbiased';

  @override
  String get languageName => 'Español';

  @override
  String get newGame => 'Nueva partida';

  @override
  String get continueGame => 'Continuar';

  @override
  String get quickPlay => 'Partida rápida vs IA';

  @override
  String get playLocal => 'Jugar en local';

  @override
  String get settings => 'Ajustes';

  @override
  String get howToPlay => 'Cómo jugar';

  @override
  String get you => 'Tú';

  @override
  String get localGame => 'Partida local';

  @override
  String get playerCount => 'Jugadores';

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorGreen => 'Verde';

  @override
  String playerNameLabel(String color) {
    return 'Nombre de $color';
  }

  @override
  String get human => 'Humano';

  @override
  String get ai => 'IA';

  @override
  String get easy => 'Fácil';

  @override
  String get normal => 'Normal';

  @override
  String get startGame => 'Empezar partida';

  @override
  String get backToHome => 'Volver al inicio';

  @override
  String get paused => 'En pausa';

  @override
  String get pause => 'Pausa';

  @override
  String get menu => 'Menú';

  @override
  String get resume => 'Reanudar';

  @override
  String get leaveGame => 'Salir de la partida';

  @override
  String get leaveGameQuestion => '¿Salir de la partida?';

  @override
  String get leaveSavedNote =>
      'Tu partida está guardada. Puedes continuarla desde el inicio.';

  @override
  String get leaveUnsavedNote => 'Saldrás de esta partida.';

  @override
  String get leave => 'Salir';

  @override
  String get stay => 'Quedarse';

  @override
  String get players => 'Jugadores';

  @override
  String get playAgain => 'Jugar otra vez';

  @override
  String get home => 'Inicio';

  @override
  String get roll => 'Tirar';

  @override
  String get aiSuffix => '(IA)';

  @override
  String turnTimer(int seconds) {
    return 'Quedan $seconds segundos';
  }

  @override
  String get turnYours => 'Tu turno';

  @override
  String turnOf(String name) {
    return 'Turno de $name';
  }

  @override
  String rankOrdinal(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': '1.º',
        '2': '2.º',
        '3': '3.º',
        'other': '4.º',
      },
    );
    return '$_temp0';
  }

  @override
  String statusWins(String name) {
    return '¡$name gana!';
  }

  @override
  String statusFinished(String name, String ordinal) {
    return '¡$name terminó $ordinal!';
  }

  @override
  String statusThreeSixes(String name) {
    return 'Tres 6. $name pierde el turno.';
  }

  @override
  String statusCaptured(String by, String victim) {
    return '¡$by capturó a $victim!';
  }

  @override
  String statusExtraSix(String name) {
    return '¡$name sacó 6, tirada extra!';
  }

  @override
  String statusExtraCapture(String name) {
    return '¡Captura! $name vuelve a tirar.';
  }

  @override
  String statusExtraHome(String name) {
    return '¡Ficha en casa! $name vuelve a tirar.';
  }

  @override
  String statusNoMoves(String name, String next) {
    return '$name no tiene movimientos. $next.';
  }

  @override
  String statusLeftTurn(String name, String next) {
    return '$name se fue. $next.';
  }

  @override
  String statusLeft(String name) {
    return '$name abandonó la partida.';
  }

  @override
  String statusRolled(String name, int value) {
    return '$name sacó $value';
  }

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get appearanceHint =>
      'Sistema sigue el modo claro u oscuro del teléfono.';

  @override
  String get language => 'Idioma';

  @override
  String get soundAndVibration => 'Sonido y vibración';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get soundEffectsHint => 'Dado, movimientos, capturas, temporizador';

  @override
  String get music => 'Música';

  @override
  String get musicHint => 'Una melodía de fondo tranquila';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrationHint => 'Caída del dado, pasos de fichas, capturas';

  @override
  String get help => 'Ayuda';

  @override
  String get howToPlayHint => 'Las reglas en cinco tarjetas';

  @override
  String get htpTitle1 => 'Saca un 6 para salir';

  @override
  String get htpBody1 =>
      'Tus cuatro fichas empiezan en tu base. Un 6 saca una a tu casilla de salida.';

  @override
  String get htpTitle2 => 'Avanza por el tablero';

  @override
  String get htpBody2 =>
      'Toca el dado y luego una ficha que brille. Avanza en sentido horario tantas casillas como el número que sacaste.';

  @override
  String get htpTitle3 => 'Captura o ponte a salvo';

  @override
  String get htpBody3 =>
      'Cae sobre un rival para mandarlo a su base. Las estrellas y las casillas de salida son seguras: ahí nadie es capturado.';

  @override
  String get htpTitle4 => 'Gana tiradas extra';

  @override
  String get htpBody4 =>
      'Sacar un 6, capturar o llevar una ficha a casa te da otra tirada. Tres 6 seguidos pierden el turno.';

  @override
  String get htpTitle5 => 'Lleva las cuatro a casa';

  @override
  String get htpBody5 =>
      'Sube por tu columna con el número exacto. Gana quien lleve primero sus cuatro fichas a casa.';

  @override
  String htpProgress(int current, int total) {
    return 'Tarjeta $current de $total';
  }

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get gotIt => 'Entendido';

  @override
  String get close => 'Cerrar';
}

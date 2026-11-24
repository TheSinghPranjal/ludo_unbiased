// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Ludo Unbiased';

  @override
  String get languageName => 'Português';

  @override
  String get continueGame => 'Continuar';

  @override
  String get quickPlay => 'Jogo rápido vs IA';

  @override
  String get playLocal => 'Jogar local';

  @override
  String get settings => 'Configurações';

  @override
  String get howToPlay => 'Como jogar';

  @override
  String get you => 'Você';

  @override
  String get localGame => 'Jogo local';

  @override
  String get playerCount => 'Jogadores';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorGreen => 'Verde';

  @override
  String playerNameLabel(String color) {
    return 'Nome do $color';
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
  String get startGame => 'Começar jogo';

  @override
  String get backToHome => 'Voltar ao início';

  @override
  String get paused => 'Pausado';

  @override
  String get pause => 'Pausar';

  @override
  String get menu => 'Menu';

  @override
  String get resume => 'Retomar';

  @override
  String get leaveGame => 'Sair do jogo';

  @override
  String get leaveGameQuestion => 'Sair do jogo?';

  @override
  String get leaveSavedNote =>
      'Seu jogo está salvo. Você pode continuá-lo pelo início.';

  @override
  String get leaveUnsavedNote => 'Você vai sair deste jogo.';

  @override
  String get leave => 'Sair';

  @override
  String get stay => 'Ficar';

  @override
  String get players => 'Jogadores';

  @override
  String get playAgain => 'Jogar de novo';

  @override
  String get home => 'Início';

  @override
  String get roll => 'Rolar';

  @override
  String get aiSuffix => '(IA)';

  @override
  String turnTimer(int seconds) {
    return '$seconds segundos restantes';
  }

  @override
  String get turnYours => 'Sua vez';

  @override
  String turnOf(String name) {
    return 'Vez de $name';
  }

  @override
  String rankOrdinal(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': '1º',
        '2': '2º',
        '3': '3º',
        'other': '4º',
      },
    );
    return '$_temp0';
  }

  @override
  String statusWins(String name) {
    return '$name venceu!';
  }

  @override
  String statusFinished(String name, String ordinal) {
    return '$name terminou em $ordinal!';
  }

  @override
  String statusThreeSixes(String name) {
    return 'Três 6. $name perde a vez.';
  }

  @override
  String statusCaptured(String by, String victim) {
    return '$by capturou $victim!';
  }

  @override
  String statusExtraSix(String name) {
    return '$name tirou 6, jogada extra!';
  }

  @override
  String statusExtraCapture(String name) {
    return 'Captura! $name joga de novo.';
  }

  @override
  String statusExtraHome(String name) {
    return 'Peça em casa! $name joga de novo.';
  }

  @override
  String statusNoMoves(String name, String next) {
    return '$name não tem jogadas. $next.';
  }

  @override
  String statusLeftTurn(String name, String next) {
    return '$name saiu. $next.';
  }

  @override
  String statusLeft(String name) {
    return '$name saiu do jogo.';
  }

  @override
  String statusRolled(String name, int value) {
    return '$name tirou $value';
  }

  @override
  String get appearance => 'Aparência';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get appearanceHint =>
      'Sistema segue o modo claro ou escuro do celular.';

  @override
  String get language => 'Idioma';

  @override
  String get soundAndVibration => 'Som e vibração';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get soundEffectsHint => 'Dado, movimentos, capturas, cronômetro';

  @override
  String get music => 'Música';

  @override
  String get musicHint => 'Uma trilha de fundo tranquila';

  @override
  String get vibration => 'Vibração';

  @override
  String get vibrationHint => 'Queda do dado, passos das peças, capturas';

  @override
  String get help => 'Ajuda';

  @override
  String get howToPlayHint => 'As regras em cinco cartões';

  @override
  String get htpTitle1 => 'Tire 6 para sair';

  @override
  String get htpBody1 =>
      'Suas quatro peças começam na base. Um 6 leva uma delas para a sua casa de saída.';

  @override
  String get htpTitle2 => 'Ande pelo tabuleiro';

  @override
  String get htpBody2 =>
      'Toque no dado e depois numa peça brilhando. Ela anda no sentido horário o número que você tirou.';

  @override
  String get htpTitle3 => 'Capture ou fique seguro';

  @override
  String get htpBody3 =>
      'Pare sobre um adversário para mandá-lo de volta à base. Estrelas e casas de saída são seguras: ninguém é capturado ali.';

  @override
  String get htpTitle4 => 'Ganhe jogadas extras';

  @override
  String get htpBody4 =>
      'Tirar 6, capturar ou levar uma peça para casa dá outra jogada. Três 6 seguidos perdem a vez.';

  @override
  String get htpTitle5 => 'Leve as quatro para casa';

  @override
  String get htpBody5 =>
      'Suba sua coluna com o número exato. Vence quem levar primeiro as quatro peças para casa.';

  @override
  String htpProgress(int current, int total) {
    return 'Cartão $current de $total';
  }

  @override
  String get back => 'Voltar';

  @override
  String get next => 'Próximo';

  @override
  String get gotIt => 'Entendi';

  @override
  String get close => 'Fechar';
}

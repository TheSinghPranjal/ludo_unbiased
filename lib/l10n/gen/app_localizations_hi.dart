// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'लूडो अनबायस्ड';

  @override
  String get languageName => 'हिन्दी';

  @override
  String get continueGame => 'जारी रखें';

  @override
  String get quickPlay => 'AI के साथ झटपट खेल';

  @override
  String get playLocal => 'साथ में खेलें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get howToPlay => 'कैसे खेलें';

  @override
  String get you => 'आप';

  @override
  String get localGame => 'लोकल गेम';

  @override
  String get playerCount => 'खिलाड़ी';

  @override
  String get colorRed => 'लाल';

  @override
  String get colorBlue => 'नीला';

  @override
  String get colorYellow => 'पीला';

  @override
  String get colorGreen => 'हरा';

  @override
  String playerNameLabel(String color) {
    return '$color का नाम';
  }

  @override
  String get human => 'इंसान';

  @override
  String get ai => 'AI';

  @override
  String get easy => 'आसान';

  @override
  String get normal => 'सामान्य';

  @override
  String get startGame => 'गेम शुरू करें';

  @override
  String get backToHome => 'होम पर वापस';

  @override
  String get paused => 'रुका हुआ';

  @override
  String get pause => 'रोकें';

  @override
  String get menu => 'मेन्यू';

  @override
  String get resume => 'फिर शुरू करें';

  @override
  String get leaveGame => 'गेम छोड़ें';

  @override
  String get leaveGameQuestion => 'गेम छोड़ें?';

  @override
  String get leaveSavedNote =>
      'आपका गेम सेव है। आप इसे होम से जारी रख सकते हैं।';

  @override
  String get leaveUnsavedNote => 'आप यह गेम छोड़ देंगे।';

  @override
  String get leave => 'छोड़ें';

  @override
  String get stay => 'रुकें';

  @override
  String get players => 'खिलाड़ी';

  @override
  String get playAgain => 'फिर से खेलें';

  @override
  String get home => 'होम';

  @override
  String get roll => 'पासा फेंकें';

  @override
  String get aiSuffix => '(AI)';

  @override
  String turnTimer(int seconds) {
    return '$seconds सेकंड बाकी';
  }

  @override
  String get turnYours => 'आपकी बारी';

  @override
  String turnOf(String name) {
    return '$name की बारी';
  }

  @override
  String rankOrdinal(String rank) {
    String _temp0 = intl.Intl.selectLogic(
      rank,
      {
        '1': 'पहले',
        '2': 'दूसरे',
        '3': 'तीसरे',
        'other': 'चौथे',
      },
    );
    return '$_temp0';
  }

  @override
  String statusWins(String name) {
    return '$name जीत गए!';
  }

  @override
  String statusFinished(String name, String ordinal) {
    return '$name $ordinal स्थान पर रहे!';
  }

  @override
  String statusThreeSixes(String name) {
    return 'लगातार तीन 6। $name की बारी गई।';
  }

  @override
  String statusCaptured(String by, String victim) {
    return '$by ने $victim को काटा!';
  }

  @override
  String statusExtraSix(String name) {
    return '$name का 6 आया, एक और चाल!';
  }

  @override
  String statusExtraCapture(String name) {
    return 'काट दिया! $name फिर से फेंकें।';
  }

  @override
  String statusExtraHome(String name) {
    return 'गोटी घर पहुँची! $name फिर से फेंकें।';
  }

  @override
  String statusNoMoves(String name, String next) {
    return '$name के पास कोई चाल नहीं। $next।';
  }

  @override
  String statusLeftTurn(String name, String next) {
    return '$name चले गए। $next।';
  }

  @override
  String statusLeft(String name) {
    return '$name ने गेम छोड़ दिया।';
  }

  @override
  String statusRolled(String name, int value) {
    return '$name का $value आया';
  }

  @override
  String get appearance => 'दिखावट';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get appearanceHint =>
      'सिस्टम आपके फ़ोन के लाइट या डार्क मोड के अनुसार चलता है।';

  @override
  String get language => 'भाषा';

  @override
  String get soundAndVibration => 'आवाज़ और वाइब्रेशन';

  @override
  String get soundEffects => 'साउंड इफ़ेक्ट';

  @override
  String get soundEffectsHint => 'पासा, चालें, काटना, टाइमर';

  @override
  String get music => 'संगीत';

  @override
  String get musicHint => 'एक शांत बैकग्राउंड धुन';

  @override
  String get vibration => 'वाइब्रेशन';

  @override
  String get vibrationHint => 'पासा गिरना, गोटी के कदम, काटना';

  @override
  String get help => 'मदद';

  @override
  String get howToPlayHint => 'पाँच छोटे कार्ड में नियम';

  @override
  String get htpTitle1 => 'बाहर निकलने के लिए 6 लाएँ';

  @override
  String get htpBody1 =>
      'चारों गोटियाँ आपके घर (बेस) से शुरू होती हैं। 6 आने पर एक गोटी आपके शुरुआती खाने पर आती है।';

  @override
  String get htpTitle2 => 'बोर्ड पर आगे बढ़ें';

  @override
  String get htpBody2 =>
      'पासे पर टैप करें, फिर चमकती गोटी पर टैप करें। वह पासे के अंक जितने खाने घड़ी की दिशा में चलती है।';

  @override
  String get htpTitle3 => 'काटें, या सुरक्षित रहें';

  @override
  String get htpBody3 =>
      'विरोधी की गोटी पर उतरकर उसे वापस बेस भेजें। तारे और शुरुआती खाने सुरक्षित हैं: वहाँ कोई नहीं कटता।';

  @override
  String get htpTitle4 => 'एक और चाल पाएँ';

  @override
  String get htpBody4 =>
      '6 आने, गोटी काटने या गोटी घर पहुँचाने पर एक और चाल मिलती है। लगातार तीन 6 आने पर बारी चली जाती है।';

  @override
  String get htpTitle5 => 'चारों को घर पहुँचाएँ';

  @override
  String get htpBody5 =>
      'अपने घर वाले रास्ते पर ठीक अंक से चढ़ें। जिसकी चारों गोटियाँ पहले घर पहुँचें, वह जीतता है।';

  @override
  String htpProgress(int current, int total) {
    return 'कार्ड $current / $total';
  }

  @override
  String get back => 'पीछे';

  @override
  String get next => 'आगे';

  @override
  String get gotIt => 'समझ गया';

  @override
  String get close => 'बंद करें';
}

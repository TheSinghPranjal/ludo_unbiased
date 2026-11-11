import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ludo_unbiased/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const LudoApp());
}

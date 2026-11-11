import 'package:flutter/material.dart';

/// The root widget. Milestone 2 replaces the start screen with the router
/// and the playable local game.
class LudoApp extends StatelessWidget {
  /// Creates the app.
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Unbiased',
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Ludo Unbiased')),
      ),
    );
  }
}

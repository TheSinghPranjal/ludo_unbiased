import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';

/// The root widget.
class LudoApp extends StatefulWidget {
  /// Creates the app.
  const LudoApp({super.key});

  @override
  State<LudoApp> createState() => _LudoAppState();
}

class _LudoAppState extends State<LudoApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ludo Unbiased',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}

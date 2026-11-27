import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// The root widget. Theme mode and language come from settings and change
/// live; the theme cross-fades rather than snapping.
class LudoApp extends ConsumerStatefulWidget {
  /// Creates the app.
  const LudoApp({super.key});

  @override
  ConsumerState<LudoApp> createState() => _LudoAppState();
}

class _LudoAppState extends ConsumerState<LudoApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    // Starts music and keeps the audio service alive with the app.
    ref.watch(audioServiceProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOutCubic,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}

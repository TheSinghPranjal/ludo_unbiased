import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/app/widgets/fade_slide_in.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/settings/models/app_settings.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// Settings: appearance, language, sound, music, vibration and help.
/// Every change applies at once and is saved.
class SettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final sections = <Widget>[
      _Section(
        title: l.appearance,
        footer: l.appearanceHint,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              key: const Key('themeMode'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_rounded),
                  label: Text(l.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_rounded),
                  label: Text(l.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_rounded),
                  label: Text(l.themeDark),
                ),
              ],
              selected: {s.themeMode},
              onSelectionChanged: (v) {
                ref.read(audioServiceProvider).play(Sfx.uiTap);
                ref.read(hapticsProvider).tick();
                ctl.setThemeMode(v.first);
              },
            ),
          ),
        ),
      ),
      _Section(
        title: l.language,
        child: Column(
          children: [
            for (final code in supportedLanguageCodes)
              _LanguageTile(
                code: code,
                selected: code == s.languageCode,
                onTap: () {
                  ref.read(audioServiceProvider).play(Sfx.uiTap);
                  ref.read(hapticsProvider).tick();
                  ctl.setLanguage(code);
                },
              ),
          ],
        ),
      ),
      _Section(
        title: l.soundAndVibration,
        child: Column(
          children: [
            _Toggle(
              key: const Key('soundToggle'),
              icon: Icons.volume_up_rounded,
              offIcon: Icons.volume_off_rounded,
              title: l.soundEffects,
              subtitle: l.soundEffectsHint,
              value: s.sound,
              onChanged: (on) {
                ctl.setSound(on: on);
                // Plays only when turned on: a sample of what was enabled.
                ref.read(audioServiceProvider).play(Sfx.uiTap);
              },
            ),
            _Toggle(
              key: const Key('musicToggle'),
              icon: Icons.music_note_rounded,
              offIcon: Icons.music_off_rounded,
              title: l.music,
              subtitle: l.musicHint,
              value: s.music,
              onChanged: (on) => ctl.setMusic(on: on),
            ),
            _Toggle(
              key: const Key('vibrationToggle'),
              icon: Icons.vibration_rounded,
              offIcon: Icons.phone_android_rounded,
              title: l.vibration,
              subtitle: l.vibrationHint,
              value: s.vibration,
              onChanged: (on) {
                ctl.setVibration(on: on);
                // A sample buzz confirms vibration works.
                if (on) ref.read(hapticsProvider).reward();
              },
            ),
          ],
        ),
      ),
      _Section(
        title: l.help,
        child: ListTile(
          key: const Key('howToPlayTile'),
          leading: const Icon(Icons.menu_book_rounded),
          title: Text(l.howToPlay),
          subtitle: Text(l.howToPlayHint),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            ref.read(audioServiceProvider).play(Sfx.uiTap);
            unawaited(context.push<void>('/how-to-play'));
          },
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            // A handful of sections: built together so they enter together,
            // and never replay their entrance while scrolling.
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, section) in sections.indexed)
                    FadeSlideIn.staggered(index: i, child: section),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.footer});

  final String title;
  final String? footer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: text.titleSmall?.copyWith(
                  color: c.text2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: c.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: c.border),
            ),
            child: child,
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
              child: Text(
                footer!,
                style: text.bodySmall?.copyWith(color: c.text2),
              ),
            ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Each language is listed in its own script, whatever the app's locale.
    final name = lookupAppLocalizations(Locale(code)).languageName;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: ListTile(
        key: Key('lang_$code'),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        trailing: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (child, a) =>
              ScaleTransition(scale: a, child: child),
          child: selected
              ? Icon(
                  Icons.check_circle_rounded,
                  key: const ValueKey(true),
                  color: c.primary,
                )
              : const SizedBox(key: ValueKey(false), width: 24),
        ),
        onTap: selected ? null : onTap,
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.offIcon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final IconData offIcon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      secondary: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, a) => FadeTransition(
          opacity: a,
          child: ScaleTransition(scale: a, child: child),
        ),
        child: Icon(
          value ? icon : offIcon,
          key: ValueKey(value),
          color: value ? c.primary : c.text2,
        ),
      ),
    );
  }
}

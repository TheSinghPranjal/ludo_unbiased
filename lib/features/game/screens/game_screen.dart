import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/core/constants/timing.dart';
import 'package:ludo_unbiased/features/game/controllers/game_controller.dart';
import 'package:ludo_unbiased/features/game/controllers/local_game_controller.dart';
import 'package:ludo_unbiased/features/game/models/game_event.dart';
import 'package:ludo_unbiased/features/game/models/game_state.dart';
import 'package:ludo_unbiased/features/game/providers/game_providers.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/game/services/status_messages.dart';
import 'package:ludo_unbiased/features/game/widgets/board_view.dart';
import 'package:ludo_unbiased/features/game/widgets/game_backdrop.dart';
import 'package:ludo_unbiased/features/game/widgets/game_hud.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// The Game screen: a painted scene with the framed Flame board, player
/// pills, the turn banner and the Roll button.
class GameScreen extends ConsumerWidget {
  /// Creates the screen.
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(activeGameProvider);
    if (controller == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/'),
            child: Text(context.l10n.backToHome),
          ),
        ),
      );
    }
    return _GameView(key: ObjectKey(controller), controller: controller);
  }
}

class _GameView extends ConsumerStatefulWidget {
  const _GameView({required this.controller, super.key});

  final GameController controller;

  @override
  ConsumerState<_GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<_GameView> {
  late final StreamSubscription<List<GameEvent>> _sub;
  late StatusLine _status;
  int? _lastDice;
  int _rollSerial = 0;
  bool _sixPending = false;
  int _lastTick = -1;

  GameController get c => widget.controller;
  AudioService get _audio => ref.read(audioServiceProvider);

  @override
  void initState() {
    super.initState();
    final s = c.state.value;
    _status = turnStatus(s.currentColor, s);
    _sub = c.events.listen(_onEvents);
    c.remainingMs.addListener(_onTimer);
  }

  @override
  void dispose() {
    unawaited(_sub.cancel());
    c.remainingMs.removeListener(_onTimer);
    super.dispose();
  }

  void _onEvents(List<GameEvent> events) {
    final line = statusFor(events, c.state.value);
    final dice = events.whereType<DiceRolled>().lastOrNull;
    if (dice != null) {
      _audio.play(Sfx.diceRoll);
      // Celebrated when the dice lands, not before it has tumbled.
      _sixPending = events.any(
        (e) => e is ExtraRoll && e.reason == ExtraRollReason.six,
      );
    }
    setState(() {
      if (line != null) _status = line;
      if (dice != null) {
        _lastDice = dice.value;
        _rollSerial++;
      }
    });
  }

  void _onDiceLanded() {
    if (!mounted) return;
    _audio.play(Sfx.diceLand);
    ref.read(hapticsProvider).diceLand();
    if (_sixPending) {
      _sixPending = false;
      _audio.play(Sfx.extraRoll);
      ref.read(hapticsProvider).reward();
    }
  }

  /// Ticks through the last seconds of this device's turn.
  void _onTimer() {
    final s = c.state.value;
    final secs = (c.remainingMs.value / 1000).ceil();
    if (secs == _lastTick) return;
    _lastTick = secs;
    if (s.isOver ||
        secs <= 0 ||
        secs > Timing.turnWarning.inSeconds ||
        !c.controlledColors.contains(s.currentColor)) {
      return;
    }
    _audio.play(Sfx.timerTick);
  }

  void _onStep() {
    _audio.play(Sfx.step);
    ref.read(hapticsProvider).tick();
  }

  void _onCapture() {
    _audio.play(Sfx.capture);
    ref.read(hapticsProvider).heavy();
  }

  void _onHome() {
    final over = c.state.value.isOver;
    _audio.play(over ? Sfx.win : Sfx.home);
    final h = ref.read(hapticsProvider);
    over ? h.heavy() : h.reward();
  }

  void _onLeaveBase() => _audio.play(Sfx.leaveBase);

  Future<void> _openPause() async {
    c.pause();
    final choice = await showGeneralDialog<_PauseChoice>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.resume,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: _popIn,
      pageBuilder: (context, _, _) => const _PauseMenu(),
    );
    if (!mounted) return;
    switch (choice) {
      case _PauseChoice.leave:
        _goHome();
      case _PauseChoice.settings:
        await context.push<void>('/settings');
        if (!mounted) return;
        // Back from Settings returns to the pause menu, still paused.
        await _openPause();
      case _PauseChoice.resume || null:
        c.resume();
    }
  }

  bool _confirming = false;

  /// Back (button or system gesture): confirm, then return Home.
  Future<void> _confirmLeave() async {
    if (c.state.value.isOver) {
      _goHome();
      return;
    }
    if (_confirming) return;
    _confirming = true;
    c.pause();
    final saved = c is LocalGameController;
    final leave = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.stay,
      transitionDuration: const Duration(milliseconds: 260),
      transitionBuilder: _popIn,
      pageBuilder: (context, _, _) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: GoldPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Text(
                context.l10n.leaveGameQuestion,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                saved
                    ? context.l10n.leaveSavedNote
                    : context.l10n.leaveUnsavedNote,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  GlossyPillButton(
                    key: const Key('confirmLeave'),
                    label: context.l10n.leave,
                    secondary: true,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  GlossyPillButton(
                    label: context.l10n.stay,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    _confirming = false;
    if (!mounted) return;
    if (leave ?? false) {
      _goHome();
    } else {
      c.resume();
    }
  }

  void _goHome() {
    ref.read(activeGameProvider.notifier).end();
    context.go('/');
  }

  void _showPlayers(GameState s) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GoldPanel(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.players,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  for (final p in s.players) ...[
                    SeatPill(player: p, active: p.color == s.currentColor),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = context.scene;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave());
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: scene.skyTop,
          body: Stack(
            children: [
              Positioned.fill(child: GameBackdrop(colors: scene)),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ValueListenableBuilder<GameState>(
                      valueListenable: c.state,
                      builder: (context, s, _) => _layout(s),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _layout(GameState s) {
    final mine = c.controlledColors.contains(s.currentColor);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                GlossyCircleButton(
                  key: const Key('back'),
                  icon: Icons.arrow_back_rounded,
                  tooltip: context.l10n.backToHome,
                  size: 46,
                  onPressed: _confirmLeave,
                ),
                const SizedBox(width: 8),
                GlossyCircleButton(
                  icon: Icons.pause_rounded,
                  size: 46,
                  tooltip: context.l10n.pause,
                  onPressed: s.isOver ? null : _openPause,
                ),
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GameTitle(),
                  ),
                ),
                SizedBox(
                  width: 92,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: s.isOver
                        ? const SizedBox.shrink()
                        : ValueListenableBuilder<int>(
                            valueListenable: c.remainingMs,
                            builder: (context, ms, _) => FittedBox(
                              fit: BoxFit.scaleDown,
                              child: TimerChip(seconds: (ms / 1000).ceil()),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final p in s.players)
                SeatPill(player: p, active: p.color == s.currentColor),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: BoardFrame(
                child: BoardView(
                  controller: c,
                  onStep: _onStep,
                  onCapture: _onCapture,
                  onHome: _onHome,
                  onLeaveBase: _onLeaveBase,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TurnBanner(
            text: _status(context.l10n),
            textKey: const Key('status'),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: ScaleTransition(scale: a, child: child),
            ),
            child: s.isOver
                ? _Results(state: s, controller: c)
                : Row(
                    children: [
                      GlossySquareButton(
                        icon: Icons.groups_rounded,
                        tooltip: context.l10n.players,
                        onPressed: () => _showPlayers(s),
                      ),
                      Expanded(
                        child: Center(
                          child: RollButton(
                            key: const Key('roll'),
                            diceFace: _lastDice ?? 5,
                            rollSerial: _rollSerial,
                            onLanded: _onDiceLanded,
                            onPressed: mine && s.phase == GamePhase.awaitingRoll
                                ? c.requestRoll
                                : null,
                          ),
                        ),
                      ),
                      GlossySquareButton(
                        icon: Icons.settings_rounded,
                        tooltip: context.l10n.menu,
                        onPressed: _openPause,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.state, required this.controller});

  final GameState state;
  final GameController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = controller;
    return GoldPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, color) in state.ranking.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i < 4)
                    Image.asset(
                      'assets/images/cards/card_rank_${i + 1}.png',
                      width: 26,
                      height: 26,
                    ),
                  const SizedBox(width: 8),
                  Text('${i + 1}. ${state.playerOf(color)!.name}'),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (c is LocalGameController) ...[
                GlossyPillButton(
                  label: context.l10n.playAgain,
                  onPressed: () =>
                      ref.read(activeGameProvider.notifier).startLocal(c.seats),
                ),
                const SizedBox(width: 12),
              ],
              GlossyPillButton(
                label: context.l10n.home,
                secondary: true,
                onPressed: () {
                  ref.read(activeGameProvider.notifier).end();
                  context.go('/');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Scales and fades a dialog in.
Widget _popIn(
  BuildContext context,
  Animation<double> a,
  Animation<double> _,
  Widget child,
) {
  final curved = CurvedAnimation(
    parent: a,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: a,
    child: ScaleTransition(
      scale: Tween<double>(begin: .88, end: 1).animate(curved),
      child: child,
    ),
  );
}

enum _PauseChoice { resume, leave, settings }

/// Pause menu: quick toggles for sound, music, vibration and theme, plus
/// Settings, Leave and Resume.
class _PauseMenu extends ConsumerWidget {
  const _PauseMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final ctl = ref.read(settingsProvider.notifier);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GoldPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(l.paused, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                GlossyCircleButton(
                  key: const Key('pauseSound'),
                  icon: s.sound
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  tooltip: l.soundEffects,
                  size: 48,
                  onPressed: () => ctl.setSound(on: !s.sound),
                ),
                GlossyCircleButton(
                  key: const Key('pauseMusic'),
                  icon: s.music
                      ? Icons.music_note_rounded
                      : Icons.music_off_rounded,
                  tooltip: l.music,
                  size: 48,
                  onPressed: () => ctl.setMusic(on: !s.music),
                ),
                GlossyCircleButton(
                  key: const Key('pauseVibration'),
                  icon: s.vibration
                      ? Icons.vibration_rounded
                      : Icons.phone_android_rounded,
                  tooltip: l.vibration,
                  size: 48,
                  onPressed: () => ctl.setVibration(on: !s.vibration),
                ),
                GlossyCircleButton(
                  key: const Key('pauseTheme'),
                  icon: dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  tooltip: dark ? l.themeLight : l.themeDark,
                  size: 48,
                  onPressed: () => ctl.setThemeMode(
                    dark ? ThemeMode.light : ThemeMode.dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                GlossyPillButton(
                  key: const Key('pauseSettings'),
                  label: l.settings,
                  secondary: true,
                  onPressed: () =>
                      Navigator.pop(context, _PauseChoice.settings),
                ),
                GlossyPillButton(
                  label: l.leaveGame,
                  secondary: true,
                  onPressed: () => Navigator.pop(context, _PauseChoice.leave),
                ),
                GlossyPillButton(
                  label: l.resume,
                  onPressed: () => Navigator.pop(context, _PauseChoice.resume),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

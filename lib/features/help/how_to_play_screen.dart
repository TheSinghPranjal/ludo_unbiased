import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo_unbiased/app/theme/app_theme.dart';
import 'package:ludo_unbiased/features/game/services/audio_service.dart';
import 'package:ludo_unbiased/features/settings/providers/settings_providers.dart';
import 'package:ludo_unbiased/l10n/l10n.dart';

/// One How to Play card: illustration asset stem, title and body.
typedef _Card = ({String art, String title, String body});

/// How to Play: five illustrated cards. Swipe, or use Back and Next; the
/// dots show where you are.
class HowToPlayScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const HowToPlayScreen({super.key});

  @override
  ConsumerState<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends ConsumerState<HowToPlayScreen> {
  final _pages = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  List<_Card> _cards(AppLocalizations l) => [
    (art: 'htp_1_leave_base', title: l.htpTitle1, body: l.htpBody1),
    (art: 'htp_2_move', title: l.htpTitle2, body: l.htpBody2),
    (art: 'htp_3_capture_safe', title: l.htpTitle3, body: l.htpBody3),
    (art: 'htp_4_extra_roll', title: l.htpTitle4, body: l.htpBody4),
    (art: 'htp_5_win', title: l.htpTitle5, body: l.htpBody5),
  ];

  void _go(int page, int count) {
    ref.read(audioServiceProvider).play(Sfx.uiTap);
    ref.read(hapticsProvider).tick();
    if (page >= count) {
      unawaited(Navigator.of(context).maybePop());
      return;
    }
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _pages.jumpToPage(page);
    } else {
      unawaited(
        _pages.animateToPage(
          page,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final cards = _cards(l);
    final last = _page == cards.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.howToPlay),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: l.close,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    itemCount: cards.length,
                    onPageChanged: (p) => setState(() => _page = p),
                    itemBuilder: (context, i) => _ParallaxCard(
                      controller: _pages,
                      index: i,
                      child: _CardView(card: cards[i]),
                    ),
                  ),
                ),
                Semantics(
                  label: l.htpProgress(_page + 1, cards.length),
                  child: ExcludeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < cards.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _page ? 24 : 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: i == _page ? c.primary : c.border,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('htpBack'),
                          style: _buttonStyle,
                          onPressed: _page == 0
                              ? null
                              : () => _go(_page - 1, cards.length),
                          child: Text(l.back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          key: const Key('htpNext'),
                          style: _buttonStyle,
                          onPressed: () => _go(_page + 1, cards.length),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              last ? l.gotIt : l.next,
                              key: ValueKey(last),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static final _buttonStyle = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );
}

/// Scales and fades a page as it slides away from the centre.
class _ParallaxCard extends StatelessWidget {
  const _ParallaxCard({
    required this.controller,
    required this.index,
    required this.child,
  });

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    child: child,
    builder: (context, child) {
      var page = index.toDouble();
      if (controller.hasClients && controller.position.haveDimensions) {
        page = controller.page ?? page;
      }
      final d = (page - index).abs().clamp(0.0, 1.0);
      return Opacity(
        opacity: 1 - d * .5,
        child: Transform.scale(scale: 1 - d * .08, child: child),
      );
    },
  );
}

class _CardView extends StatelessWidget {
  const _CardView({required this.card});

  final _Card card;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final mode = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Image.asset(
                    'assets/images/ui/${card.art}_$mode.png',
                    key: ValueKey(mode),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                card.title,
                style: text.headlineSmall?.copyWith(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.w700,
                  color: c.text,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              card.body,
              style: text.bodyLarge?.copyWith(color: c.text2, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

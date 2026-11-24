import 'dart:async';

import 'package:flutter/material.dart';

/// Fades and slides its child in once, after [delay]. Used to stagger a
/// screen's sections. With reduced motion the child just appears.
class FadeSlideIn extends StatefulWidget {
  /// Creates the entrance.
  const FadeSlideIn({
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .08),
    super.key,
  });

  /// Shows a list's [index]th item 50 ms after the previous one.
  FadeSlideIn.staggered({
    required int index,
    required this.child,
    this.offset = const Offset(0, .08),
    super.key,
  }) : delay = Duration(milliseconds: 40 + 50 * index);

  /// What appears.
  final Widget child;

  /// Wait before starting.
  final Duration delay;

  /// Starting offset, as a fraction of the child's size.
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const _run = Duration(milliseconds: 420);

  // The delay is the head of one controller rather than a timer, so the
  // entrance stays on the frame clock (and settles in widget tests).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.delay + _run,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Interval(
      widget.delay.inMicroseconds / (widget.delay + _run).inMicroseconds,
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else {
      unawaited(_c.forward());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _t,
    child: SlideTransition(
      position: Tween(begin: widget.offset, end: Offset.zero).animate(_t),
      child: widget.child,
    ),
  );
}

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Animation durations, curves and reduced-motion helpers.
///
/// Two rules govern every animation in this app:
///  1. Animate on the UI thread using implicit animations or
///     [AnimationController]. Never drive layout with per-frame `setState`
///     from a `Timer`.
///  2. Animate only `opacity` and `transform`. Animating layout properties
///     forces a relayout of the whole subtree each frame and is the single
///     most common source of dropped frames.
abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);

  /// Curves chosen so motion starts fast and settles gently, which reads as
  /// responsive even when the animation itself is long.
  static const Curve enter = Cubic(0.0, 0.0, 0.2, 1);
  static const Curve exit = Cubic(0.4, 0.0, 1.0, 1);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;

  /// Respects the platform "remove animations" accessibility setting.
  static bool prefersReducedMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// Returns [duration] unchanged, or [Duration.zero] when the user has
  /// asked for reduced motion. Pass the result to every animation.
  static Duration resolve(BuildContext context, Duration duration) =>
      prefersReducedMotion(context) ? Duration.zero : duration;

  /// Stagger offset for list entrance animations. Clamped to 8 items so a
  /// 500-row list never spends seconds animating.
  static Duration stagger(BuildContext context, int index) {
    if (prefersReducedMotion(context)) return Duration.zero;
    return Duration(milliseconds: index.clamp(0, 8) * 30);
  }
}

/// Fade + slide entrance used for list items and cards.
///
/// Built on implicit animations, so only the compositor is involved: no
/// element rebuilds and no layout pass runs while the animation plays.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.offsetY = 0.06,
    this.duration,
  });

  final Widget child;

  /// Position in a list, used for the stagger.
  final int index;

  /// Fractional vertical travel. Kept small to read as a settle rather than
  /// a slide-in from off-screen.
  final double offsetY;

  final Duration? duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration ?? AppMotion.normal,
  );

  /// Stagger timer. Held so it can be cancelled in [dispose] — a bare
  /// `Future.delayed` would keep a pending callback alive after unmount.
  Timer? _staggerTimer;

  @override
  void initState() {
    super.initState();
    if (AppMotion.prefersReducedMotion(context)) {
      _controller.value = 1;
      return;
    }
    final delay = AppMotion.stagger(context, widget.index);
    if (delay > Duration.zero) {
      _staggerTimer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _staggerTimer?.cancel();
    _staggerTimer = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.enter,
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        // Transform-driven: no relayout while animating.
        position: Tween<Offset>(
          begin: Offset(0, widget.offsetY),
          end: Offset.zero,
        ).animate(animation),
        child: widget.child,
      ),
    );
  }
}

/// Scale-in wrapper for dialogs, sheets and FAB actions.
class ScaleFadeIn extends StatelessWidget {
  const ScaleFadeIn({
    super.key,
    required this.child,
    this.beginScale = 0.94,
    this.duration,
  });

  final Widget child;
  final double beginScale;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.prefersReducedMotion(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: beginScale, end: 1),
      duration: duration ?? AppMotion.fast,
      curve: AppMotion.enter,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        // transform-only: the child is laid out once, not per frame.
        child: child,
      ),
      child: child,
    );
  }
}

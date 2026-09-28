import 'dart:async';

import 'package:flutter/material.dart';

import '../services/performance/performance_monitor.dart';

/// Reports how long a screen took to become interactive.
///
/// Wraps the body of a screen rather than requiring each screen to remember
/// to instrument itself, and clears its own post-frame callback on dispose so
/// a fast back-navigation cannot fire against a dead [State].
///
/// Cost: one [Stopwatch] and, on the first frame only, one post-frame
/// callback.
class ScreenPerformanceWatcher extends StatefulWidget {
  const ScreenPerformanceWatcher({
    super.key,
    required this.name,
    required this.child,
  });

  /// Screen identifier used in timings, e.g. `Home`.
  final String name;

  final Widget child;

  @override
  State<ScreenPerformanceWatcher> createState() =>
      _ScreenPerformanceWatcherState();
}

class _ScreenPerformanceWatcherState extends State<ScreenPerformanceWatcher> {
  final Stopwatch _clock = Stopwatch()..start();
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    PerformanceMonitor.instance.trackScreen(widget.name);
  }

  @override
  void didUpdateWidget(ScreenPerformanceWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      _clock
        ..reset()
        ..start();
      _reported = false;
      PerformanceMonitor.instance.trackScreen(widget.name);
    }
  }

  @override
  void dispose() {
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_reported) {
      _reported = true;
      // One shot: without the flag this would re-register on every rebuild
      // and flood the metrics registry.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        PerformanceMonitor.instance
            .trackScreenReady(widget.name, _clock.elapsed);
      });
    }
    return widget.child;
  }
}

/// Marks the app as ready on the first painted frame.
///
/// Wired to [WidgetsBinding.addPostFrameCallback] from the root widget, so
/// `APP_READY` measures the real cold start including database bootstrap.
class AppReadyReporter extends StatefulWidget {
  const AppReadyReporter({super.key, required this.child, this.onReady});

  final Widget child;
  final VoidCallback? onReady;

  @override
  State<AppReadyReporter> createState() => _AppReadyReporterState();
}

class _AppReadyReporterState extends State<AppReadyReporter> {
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _reported) return;
      _reported = true;
      PerformanceMonitor.instance.markAppReady();
      widget.onReady?.call();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A repeating, cheap animation used to indicate that something is live.
///
/// Kept as a self-contained widget so only this subtree repaints; without the
/// [RepaintBoundary] the animation would dirty its whole ancestor chain
/// sixty times a second.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.size = 8, this.color});

  final double size;
  final Color? color;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return RepaintBoundary(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// Debounced scrolling throttler for high-frequency callbacks such as scroll
/// position tracking.
///
/// Uses a cached [Timer] so repeated calls inside the window cost one
/// reschedule rather than a new timer each time.
class ThrottledCallback {
  ThrottledCallback(this.callback,
      {this.interval = const Duration(milliseconds: 100)});

  final void Function() callback;
  final Duration interval;

  Timer? _timer;

  void call() {
    if (_timer?.isActive ?? false) return;
    _timer = Timer(interval, callback);
  }

  void dispose() => _timer?.cancel();
}

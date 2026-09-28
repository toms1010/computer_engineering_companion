import 'package:flutter/scheduler.dart';

import 'app_logger.dart';
import 'performance_logger.dart';
import 'performance_metrics.dart';

/// High-level performance facade used by the rest of the application.
///
/// Feature code should call the named helpers ([trackScreen], [trackQuery],
/// [trackNavigation] …) rather than poking the logger directly, so every
/// measurement lands in the same registry and gets judged against the same
/// threshold set.
class PerformanceMonitor {
  PerformanceMonitor._();

  static final PerformanceMonitor instance = PerformanceMonitor._();

  PerformanceLogger get logger => PerformanceLogger.instance;
  MetricsRegistry get registry => logger.registry;
  PerfThresholds get thresholds => logger.thresholds;

  /// Measures the whole cold start.
  ///
  /// Started explicitly by [startProcessClock] at the top of `main()`.
  /// Deliberately not a lazily-initialised `static final`, because Dart would
  /// then begin the clock at the first *read* — inside `markAppReady` — which
  /// would make `APP_READY` report the gap between two adjacent statements
  /// instead of the real startup cost.
  static final Stopwatch processClock = Stopwatch();

  /// Call as the first statement of `main()`, before any plugin call.
  static void startProcessClock() {
    if (!processClock.isRunning) processClock.start();
  }

  DateTime? _appReadyAt;
  Duration? _appReadyDuration;
  int _screensVisited = 0;
  String? _currentScreen;
  bool _frameCallbackInstalled = false;

  /// Timings reported by the engine for the most recent frame batch.
  List<FrameTiming> _frameTimings = const [];

  /// True once [start] has run.
  bool get isStarted => _started;
  bool _started = false;

  // ---------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------

  /// Starts frame monitoring. Safe to call more than once.
  void start() {
    if (_started) return;
    _started = true;
    // Safety net: if `startProcessClock` was not called, start it now so
    // `APP_READY` is never a meaningless near-zero.
    if (!processClock.isRunning) startProcessClock();
    AppLogger.instance.info('Performance monitoring started');
    _installFrameCallback();
  }

  /// Marks the moment the first frame is on screen.
  void markAppReady({String? route}) {
    if (_appReadyAt != null) return;
    _appReadyAt = DateTime.now();
    final elapsed = processClock.elapsed;
    _appReadyDuration = elapsed;
    logger.record('APP_READY', PerfCategory.app, elapsed,
        attributes: {if (route != null) 'route': route});
    AppLogger.instance.info('First frame rendered',
        context: {'ms': elapsed.inMicroseconds / 1000});
  }

  Duration? get appReadyDuration => _appReadyDuration;
  int get screensVisited => _screensVisited;
  String? get currentScreen => _currentScreen;
  List<FrameTiming> get frameTimings => _frameTimings;
  FrameStats get frames => registry.frames;

  // ---------------------------------------------------------------------
  // Screens and navigation
  // ---------------------------------------------------------------------

  /// Called when a screen is inserted into the tree, by
  /// `ScreenPerformanceWatcher`. Records the mount instant so the matching
  /// [trackScreenReady] can report time-to-interactive.
  void trackScreen(String name, {String? from}) {
    _screensVisited++;
    _currentScreen = name;
    logger.record('SCREEN_MOUNT', PerfCategory.screen, Duration.zero,
        attributes: {if (from != null) 'from': from});
  }

  /// Called once a screen has painted its first meaningful frame.
  void trackScreenReady(String name, Duration sinceMount) {
    logger.record('SCREEN_READY', PerfCategory.screen, sinceMount,
        attributes: {'screen': name});
  }

  /// Wrap a navigation action (push, tab switch, route replace).
  PerfTrace trackNavigation(String name, {String? from}) =>
      logger.start('NAV $name', PerfCategory.navigation,
          attributes: {if (from != null) 'from': from});

  // ---------------------------------------------------------------------
  // Data access
  // ---------------------------------------------------------------------

  /// Wrap any database read or write. [label] should identify the query, e.g.
  /// `loadSubjects`, so a slow query is attributable.
  PerfTrace trackQuery(String label, {Map<String, Object?> context = const {}}) =>
      logger.start('DB $label', PerfCategory.database, attributes: context);

  /// Wrap a network request.
  PerfTrace trackApi(String label,
          {Map<String, Object?> context = const {}}) =>
      logger.start('API $label', PerfCategory.api, attributes: context);

  /// Wrap an image load or decode.
  PerfTrace trackImage(String label,
          {Map<String, Object?> context = const {}}) =>
      logger.start('IMAGE $label', PerfCategory.image, attributes: context);

  /// Wrap an AI request, local or remote.
  PerfTrace trackAi(String label,
          {Map<String, Object?> context = const {}}) =>
      logger.start('AI $label', PerfCategory.ai, attributes: context);

  /// Wrap a synchronisation pass.
  PerfTrace trackSync(String label,
          {Map<String, Object?> context = const {}}) =>
      logger.start('SYNC $label', PerfCategory.sync, attributes: context);

  /// Records a one-off expensive computation that has no natural call site.
  void recordComputation(String label, Duration duration,
          {Map<String, Object?> context = const {}}) =>
      logger.record('CPU $label', PerfCategory.render, duration,
          attributes: context);

  // ---------------------------------------------------------------------
  // Frame / jank monitoring
  // ---------------------------------------------------------------------

  void _installFrameCallback() {
    if (_frameCallbackInstalled) return;
    _frameCallbackInstalled = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void _onTimings(List<FrameTiming> timings) {
    // The engine batches timings; keep only the newest batch so memory stays
    // flat on a long session.
    _frameTimings = timings;
    final budget = thresholds.frameBudget;
    for (final timing in timings) {
      registry.frames.record(
        build: timing.buildDuration,
        raster: timing.rasterDuration,
        budget: budget,
      );
    }
  }

  /// Fraction of frames that exceeded the budget since launch.
  double get jankRate => registry.frames.jankRate;

  /// Snapshot suitable for the diagnostics screen.
  PerformanceSnapshot snapshot() {
    return PerformanceSnapshot(
      appReady: _appReadyDuration,
      currentScreen: _currentScreen,
      screensVisited: _screensVisited,
      frames: registry.frames,
      series: registry.series,
      events: registry.events,
    );
  }

  /// Resets counters. Used by the diagnostics screen and by tests.
  void reset() {
    registry.clear();
    _screensVisited = 0;
  }
}

/// Immutable view of everything the diagnostics screen needs.
class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.appReady,
    required this.currentScreen,
    required this.screensVisited,
    required this.frames,
    required this.series,
    required this.events,
  });

  final Duration? appReady;
  final String? currentScreen;
  final int screensVisited;
  final FrameStats frames;
  final List<MetricSeries> series;
  final List<PerfSample> events;
}

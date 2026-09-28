import 'app_logger.dart';
import 'log_level.dart';
import 'performance_metrics.dart';

/// Configurable budgets for slow-operation detection.
class PerfThresholds {
  PerfThresholds({
    this.appReady = const Duration(milliseconds: 1500),
    this.screen = const Duration(milliseconds: 500),
    this.navigation = const Duration(milliseconds: 300),
    this.database = const Duration(milliseconds: 300),
    this.api = const Duration(milliseconds: 2000),
    this.image = const Duration(milliseconds: 1000),
    this.ai = const Duration(milliseconds: 4000),
    this.sync = const Duration(milliseconds: 5000),
    this.render = const Duration(milliseconds: 100),
  });

  final Duration appReady;
  final Duration screen;
  final Duration navigation;
  final Duration database;
  final Duration api;
  final Duration image;
  final Duration ai;
  final Duration sync;
  final Duration render;

  /// Budget for a single frame. 16.67ms is one frame at 60Hz. A device
  /// running at 90 or 120Hz can lower this; a device that struggles can
  /// raise it to cut noise.
  Duration frameBudget = const Duration(microseconds: 16667);

  /// Returns a copy with individual budgets replaced. Used by the
  /// diagnostics screen so thresholds can be tuned without a rebuild.
  PerfThresholds copyWith({
    Duration? appReady,
    Duration? screen,
    Duration? navigation,
    Duration? database,
    Duration? api,
    Duration? image,
    Duration? ai,
    Duration? sync,
    Duration? render,
  }) {
    return PerfThresholds(
      appReady: appReady ?? this.appReady,
      screen: screen ?? this.screen,
      navigation: navigation ?? this.navigation,
      database: database ?? this.database,
      api: api ?? this.api,
      image: image ?? this.image,
      ai: ai ?? this.ai,
      sync: sync ?? this.sync,
      render: render ?? this.render,
    )..frameBudget = frameBudget;
  }

  /// The budget that applies to [category].
  Duration budgetFor(PerfCategory category) => switch (category) {
        PerfCategory.app => appReady,
        PerfCategory.screen => screen,
        PerfCategory.navigation => navigation,
        PerfCategory.database => database,
        PerfCategory.api => api,
        PerfCategory.image => image,
        PerfCategory.ai => ai,
        PerfCategory.sync => sync,
        PerfCategory.render => render,
      };
}

/// A handle returned by [PerformanceLogger.start]. Call [stop] exactly once;
/// it is idempotent so an early return in an error path cannot double count.
class PerfTrace {
  PerfTrace(this._logger, this.name, this.category, this._start, this.attributes);

  final PerformanceLogger _logger;
  final String name;
  final PerfCategory category;
  final Stopwatch _start;
  final Map<String, Object?> attributes;
  bool _stopped = false;

  /// Milliseconds elapsed so far, for a caller that wants to abort.
  int get elapsedMs => _start.elapsedMicroseconds ~/ 1000;

  Duration stop({Map<String, Object?> extra = const {}, bool succeeded = true}) {
    if (_stopped) return Duration.zero;
    _stopped = true;
    _start.stop();
    final duration = _start.elapsed;
    _logger._complete(this, duration, extra, succeeded: succeeded);
    return duration;
  }
}

/// Centralised performance logger.
///
/// Every measured operation in the app goes through here so timings use one
/// clock, one format and one set of thresholds. `Stopwatch` is used for all
/// measurement: `DateTime.now()` is wall-clock and can jump.
class PerformanceLogger {
  PerformanceLogger._();

  static final PerformanceLogger instance = PerformanceLogger._();

  final MetricsRegistry registry = MetricsRegistry();
  PerfThresholds thresholds = PerfThresholds();

  /// Retained so the diagnostics screen can show the last N timings.
  bool captureScreens = true;

  PerfTrace start(
    String name,
    PerfCategory category, {
    Map<String, Object?> attributes = const {},
  }) {
    return PerfTrace(this, name, category, Stopwatch()..start(), attributes);
  }

  /// Records an already-measured duration.
  void record(
    String name,
    PerfCategory category,
    Duration duration, {
    Map<String, Object?> attributes = const {},
  }) {
    final sample = PerfSample(
      name: name,
      category: category,
      duration: duration,
      timestamp: DateTime.now(),
      attributes: attributes,
    );
    final threshold = thresholds.budgetFor(category);
    registry.record(sample, threshold);
    if (duration > threshold) {
      AppLogger.instance.perf(
        'SLOW ${sample.format(includeCategory: true)}',
        // A slow operation is the one perf event worth surfacing in a
        // release build, so it is raised at WARN as well as PERF.
        context: {
          ...attributes,
          'threshold_ms': threshold.inMilliseconds,
          'actual_ms': duration.inMicroseconds / 1000,
        },
      );
      AppLogger.instance.warn(
        '${category.name} "$name" took ${_ms(duration)}',
        context: {'threshold_ms': threshold.inMilliseconds},
      );
    } else if (AppLogger.instance.shouldLog(LogLevel.perf)) {
      AppLogger.instance.perf(sample.format(includeCategory: true),
          context: attributes);
    }
  }

  void _complete(
    PerfTrace trace,
    Duration duration,
    Map<String, Object?> extra, {
    required bool succeeded,
  }) {
    record(
      trace.name,
      trace.category,
      duration,
      attributes: {
        ...trace.attributes,
        ...extra,
        if (!succeeded) 'failed': true,
      },
    );
  }

  static String _ms(Duration d) {
    final ms = d.inMicroseconds / 1000;
    return ms >= 1000
        ? '${(ms / 1000).toStringAsFixed(2)}s'
        : '${ms.toStringAsFixed(ms < 10 ? 1 : 0)}ms';
  }
}

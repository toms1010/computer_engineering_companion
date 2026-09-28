/// Classification for every measured operation. Thresholds are looked up
/// per category so a slow screen and a slow database query are judged
/// against different budgets.
enum PerfCategory {
  app,
  screen,
  navigation,
  database,
  api,
  image,
  ai,
  sync,
  render,
}


/// One measured operation.
class PerfSample {
  const PerfSample({
    required this.name,
    required this.category,
    required this.duration,
    required this.timestamp,
    this.attributes = const {},
  });

  final String name;
  final PerfCategory category;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, Object?> attributes;

  /// `SCREEN Home 112ms` — the body of a perf line, without the `[PERF]`
  /// prefix, which the logger adds. The prefix is deliberately not baked in
  /// here so console output and the in-app diagnostics list cannot disagree.
  String format({bool includeCategory = false}) {
    final ms = duration.inMicroseconds / 1000;
    final value = ms >= 1000
        ? '${(ms / 1000).toStringAsFixed(2)}s'
        : '${ms.toStringAsFixed(ms < 10 ? 1 : 0)}ms';
    final head =
        includeCategory ? '${category.name.toUpperCase()} $name' : name;
    return '$head $value';
  }
}

/// Aggregate statistics for one named operation.
class MetricSeries {
  MetricSeries(this.name, this.category);

  final String name;
  final PerfCategory category;

  int count = 0;
  int totalMicros = 0;
  int minMicros = 1 << 62;
  int maxMicros = 0;
  int slowCount = 0;
  Duration? last;

  void add(Duration duration) {
    final micros = duration.inMicroseconds;
    count++;
    totalMicros += micros;
    if (micros < minMicros) minMicros = micros;
    if (micros > maxMicros) maxMicros = micros;
    last = duration;
  }

  double get averageMs => count == 0 ? 0 : totalMicros / count / 1000;
  double get minMs => count == 0 ? 0 : minMicros / 1000;
  double get maxMs => maxMicros / 1000;
  double get slowRate => count == 0 ? 0 : slowCount / count;
}

/// Rolling frame statistics used to prove whether the UI is janking.
class FrameStats {
  int totalFrames = 0;
  int jankyFrames = 0;
  int worstFrameMicros = 0;
  double _buildTotal = 0;
  double _rasterTotal = 0;

  void record({required Duration build, required Duration raster, required Duration budget}) {
    final total = build.inMicroseconds + raster.inMicroseconds;
    totalFrames++;
    _buildTotal += build.inMicroseconds / 1000;
    _rasterTotal += raster.inMicroseconds / 1000;
    if (total > budget.inMicroseconds) jankyFrames++;
    if (total > worstFrameMicros) worstFrameMicros = total;
  }

  double get averageBuildMs => totalFrames == 0 ? 0 : _buildTotal / totalFrames;
  double get averageRasterMs => totalFrames == 0 ? 0 : _rasterTotal / totalFrames;
  double get jankRate => totalFrames == 0 ? 0 : jankyFrames / totalFrames;
  double get worstFrameMs => worstFrameMicros / 1000;
}

/// Bounded in-memory store for samples and aggregates.
///
/// Deliberately in-memory and bounded: this is a diagnostics aid, not
/// telemetry. It must never become an unbounded memory growth vector on a
/// low-end device.
class MetricsRegistry {
  MetricsRegistry({this.maxEvents = 300});

  final int maxEvents;

  final List<PerfSample> _events = <PerfSample>[];
  final Map<String, MetricSeries> _series = <String, MetricSeries>{};
  final FrameStats frames = FrameStats();

  /// Newest-last event log, capped at [maxEvents].
  List<PerfSample> get events => List.unmodifiable(_events);

  List<MetricSeries> get series {
    final all = _series.values.toList();
    all.sort((a, b) => b.maxMicros.compareTo(a.maxMicros));
    return all;
  }

  void record(PerfSample sample, Duration threshold) {
    _events.add(sample);
    if (_events.length > maxEvents) {
      _events.removeRange(0, _events.length - maxEvents);
    }
    final key = '${sample.category.name}:${sample.name}';
    final entry = _series.putIfAbsent(
      key,
      () => MetricSeries(sample.name, sample.category),
    );
    entry.add(sample.duration);
    if (sample.duration > threshold) entry.slowCount++;
  }

  /// Median-ish view of recent events for a given category, used by the
  /// dashboard to show "how bad is it right now".
  Duration? recentAverage(PerfCategory category) {
    final matching = _events
        .where((e) => e.category == category)
        .take(_events.length > 40 ? 40 : _events.length)
        .toList();
    if (matching.isEmpty) return null;
    final total = matching.fold<int>(0, (s, e) => s + e.duration.inMicroseconds);
    return Duration(microseconds: total ~/ matching.length);
  }

  void clear() {
    _events.clear();
    _series.clear();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_spacing.dart';
import '../../core/error/error_reporter.dart';
import '../../services/performance/app_logger.dart';
import '../../services/performance/performance_metrics.dart';
import '../../services/performance/performance_monitor.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Development-only performance and diagnostics dashboard.
///
/// Reachable only when `diagnosticsEnabledProvider` is on, which defaults to
/// `true` in debug builds and `false` in release — so a normal user of a
/// production build cannot reach this screen from Settings.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(diagnosticsEnabledProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diagnostics')),
        body: const EmptyStateView(
          icon: Icons.lock_outline,
          title: 'Diagnostics disabled',
          message: 'Enable it in Settings → About to view performance data.',
        ),
      );
    }

    final monitor = PerformanceMonitor.instance;
    final snapshot = monitor.snapshot();
    final appReady = snapshot.appReady;

    return ScreenPerformanceWatcher(
      name: 'Diagnostics',
      child: AppScaffold(
        title: 'Performance',
        actions: [
          IconButton(
            onPressed: () {
              monitor.reset();
              AppLogger.instance.clearBuffer();
              showAppSnackBar(context, 'Timings cleared', icon: Icons.refresh);
            },
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Clear timings',
          ),
        ],
        slivers: [
          // Live counters. The 1 Hz pulse is owned by `_FrameStatsState` and
          // cancelled on dispose, so it only runs while this screen is up.
          const SliverToBoxAdapter(child: _FrameStats()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          const SliverSectionHeader(title: 'Startup'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: _StatGrid(
                items: [
                  (label: 'App ready', value: _format(appReady), tone: null),
                  (
                    label: 'Current screen',
                    value: snapshot.currentScreen ?? '—',
                    tone: null
                  ),
                  (
                    label: 'Screens visited',
                    value: '${snapshot.screensVisited}',
                    tone: null
                  ),
                ],
              ),
            ),
          ),

          const SliverSectionHeader(
              title: 'Slowest operations',
              subtitle: 'Highest peak duration, with the budget it exceeded',
            ),
          ..._seriesSlivers(context, snapshot.series),

          const SliverSectionHeader(
              title: 'Recent events',
              subtitle: 'Newest first',
            ),
          ..._eventSlivers(context, snapshot.events.reversed.toList()),

          const SliverSectionHeader(title: 'Log tail'),
          const SliverToBoxAdapter(child: _LogTail()),

          const SliverSectionHeader(title: 'Recent errors'),
          ..._errorSlivers(context),
        ],
      ),
    );
  }

  static String _format(Duration? value) {
    if (value == null) return '—';
    final ms = value.inMicroseconds / 1000;
    return ms >= 1000 ? '${(ms / 1000).toStringAsFixed(2)} s' : '${ms.round()} ms';
  }

  static List<Widget> _seriesSlivers(
      BuildContext context, List<MetricSeries> series) {
    if (series.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Text('No timings recorded yet. Use the app for a moment.'),
          ),
        ),
      ];
    }
    final budget = PerformanceMonitor.instance.thresholds;
    return [
      LazySliverList(
        itemCount: series.length,
        itemBuilder: (context, index) {
          final entry = series[index];
          final budgetMs =
              budget.budgetFor(entry.category).inMicroseconds / 1000;
          final over = entry.maxMs > budgetMs;
          return Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(entry.name,
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        if (over)
                          const Pill(label: 'SLOW', dense: true)
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'max ${entry.maxMs.toStringAsFixed(0)} ms · '
                      'avg ${entry.averageMs.toStringAsFixed(0)} ms · '
                      '${entry.count}× · budget ${budgetMs.toStringAsFixed(0)} ms',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  static List<Widget> _eventSlivers(
      BuildContext context, List<PerfSample> events) {
    if (events.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Text('No events yet.'),
          ),
        ),
      ];
    }
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: CodeBlock(
            fontSize: 11,
            code: events
                .take(60)
                .map((e) => e.format(includeCategory: true))
                .join('\n'),
          ),
        ),
      ),
    ];
  }

  static List<Widget> _errorSlivers(BuildContext context) {
    final errors = ErrorReporter.instance.recent.reversed.toList();
    if (errors.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Text('No errors recorded. Good.'),
          ),
        ),
      ];
    }
    return [
      LazySliverList(
        itemCount: errors.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.sm),
          child: AppListRow(
            title: errors[index].error.message,
            subtitle: Text(errors[index].format()),
            leading: const Icon(Icons.error_outline, size: 18),
          ),
        ),
      ),
    ];
  }
}

class _FrameStats extends StatefulWidget {
  const _FrameStats();

  @override
  State<_FrameStats> createState() => _FrameStatsState();
}

class _FrameStatsState extends State<_FrameStats> {
  late final Stream<void> _ticks;
  late final StreamSubscription<void> _subscription;

  @override
  void initState() {
    super.initState();
    // A single shared 1 Hz pulse, cancelled in dispose. It exists only while
    // this screen is on the stack.
    _ticks = Stream<void>.periodic(const Duration(seconds: 1));
    _subscription = _ticks.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frames = PerformanceMonitor.instance.registry.frames;
    // A frame over the budget is a dropped frame; the budget itself is
    // configurable so a 120Hz device is not judged by a 60Hz target.
    final budget =
        PerformanceMonitor.instance.thresholds.frameBudget.inMicroseconds / 1000;
    final jankPercent = (frames.jankRate * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, 0),
      child: _StatGrid(
        items: [
          (label: 'Frames', value: '${frames.totalFrames}', tone: null),
          (
            label: 'Janky',
            value: '$jankPercent%',
            tone: jankPercent > 5
                ? Theme.of(context).colorScheme.errorContainer
                : null,
          ),
          (
            label: 'Avg build',
            value: '${frames.averageBuildMs.toStringAsFixed(1)} ms',
            tone: null
          ),
          (
            label: 'Avg raster',
            value: '${frames.averageRasterMs.toStringAsFixed(1)} ms',
            tone: null
          ),
          (
            label: 'Worst frame',
            value: '${frames.worstFrameMs.toStringAsFixed(1)} ms',
            tone: null
          ),
          (
            label: 'Budget',
            value: '${budget.toStringAsFixed(1)} ms',
            tone: null
          ),
        ],
      ),
    );
  }
}

class _LogTail extends ConsumerStatefulWidget {
  const _LogTail();

  @override
  ConsumerState<_LogTail> createState() => _LogTailState();
}

class _LogTailState extends ConsumerState<_LogTail> {
  @override
  Widget build(BuildContext context) {
    final records = AppLogger.instance.records.reversed.take(40).toList();
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: Text('No log records.'),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: CodeBlock(
        fontSize: 10,
        code: records.map((r) => r.format()).join('\n'),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.items});

  /// One tile: a label, a value, and optionally a background tone used to
  /// flag a value that needs attention.
  final List<({String label, String value, Color? tone})> items;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 380 ? 1 : 2;
    final itemWidth =
        (width - AppSpacing.gutter * 2 - AppSpacing.sm * (columns - 1)) / columns;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in items)
          SizedBox(
            width: itemWidth,
            child: StatCard(
              label: item.label,
              value: item.value,
              tone: item.tone,
            ),
          ),
      ],
    );
  }
}

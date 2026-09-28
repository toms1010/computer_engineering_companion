import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_typography.dart';
import '../../core/utils/app_time.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Progress dashboard.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);

    return ScreenPerformanceWatcher(
      name: 'Progress',
      child: AppScaffold(
        title: 'Progress',
        slivers: [
          ...stats.when(
            data: (data) => [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                  child: _OverviewCard(stats: data),
                ),
              ),

              const SliverSectionHeader(title: 'Totals'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      SizedBox(
                        width: _statWidth(context),
                        child: StatCard(
                          label: 'Lessons',
                          value: '${data.lessonsCompleted}',
                          caption: 'of ${data.totalLessons}',
                          icon: Icons.menu_book_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _statWidth(context),
                        child: StatCard(
                          label: 'Quizzes',
                          value: '${data.quizzesCompleted}',
                          caption:
                              '${data.quizAccuracy.round()}% average',
                          icon: Icons.quiz_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _statWidth(context),
                        child: StatCard(
                          label: 'Study streak',
                          value: '${data.studyStreakDays}',
                          caption: data.studyStreakDays == 1 ? 'day' : 'days',
                          icon: Icons.local_fire_department_outlined,
                        ),
                      ),
                      SizedBox(
                        width: _statWidth(context),
                        child: StatCard(
                          label: 'Study time',
                          value: AppTime.duration(data.totalStudyMinutes),
                          caption: 'logged locally',
                          icon: Icons.schedule_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (data.strongSubjects.isNotEmpty) ...[
                const SliverSectionHeader(
                    title: 'Strong subjects',
                    subtitle: '75% or more of lessons complete',
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final name in data.strongSubjects)
                          Pill(label: name, icon: Icons.check_circle_outline),
                      ],
                    ),
                  ),
                ),
              ],

              if (data.needsReviewSubjects.isNotEmpty) ...[
                const SliverSectionHeader(
                    title: 'Needs review',
                    subtitle: 'Under 50% complete, or quiz average below 70%',
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.gutter),
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final name in data.needsReviewSubjects)
                          Pill(
                            label: name,
                            icon: Icons.refresh,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
            loading: () => const [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.gutter),
                  child: SkeletonBox(height: 140, radius: 14),
                ),
              ),
              SkeletonList(itemCount: 4, hasLeading: false),
            ],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(progressStatsProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Half the available width minus the gap, so two stat cards fit per row on
  /// a phone and more on a tablet.
  static double _statWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 380 ? 1 : 2;
    return (width - AppSpacing.gutter * 2 - AppSpacing.sm * (columns - 1)) /
        columns;
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percent = (stats.overallProgress * 100).round();

    return ContentCard(
      color: scheme.primaryContainer,
      semanticLabel: 'Overall progress $percent percent',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OVERALL PROGRESS', style: AppTypography.overline(context)),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$percent%',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ProgressBar(
            value: stats.overallProgress,
            label: 'Overall progress',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${stats.lessonsCompleted} of ${stats.totalLessons} lessons complete',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

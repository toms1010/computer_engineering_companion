import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_typography.dart';
import '../../core/utils/app_time.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Dashboard.
///
/// Rebuilt on: profile name, progress stats, subjects, activity. Each of those
/// is watched through the narrowest provider that exists, and the derived
/// values (percentage, greeting, relative time) are computed once per build
/// rather than per row.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileNameProvider).valueOrNull ??
        ProfileNameNotifier.fallback;
    final stats = ref.watch(progressStatsProvider);
    final subjects = ref.watch(subjectsProvider);
    final activity = ref.watch(activitiesProvider);
    // One clock read per build, shared by every relative-time label, so a
    // rebuild does not call `DateTime.now()` once per row.
    final now = DateTime.now();

    return ScreenPerformanceWatcher(
      name: 'Home',
      child: AppScaffold(
        title: 'Home',
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.progress),
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Progress',
          ),
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.bookmarks),
            icon: const Icon(Icons.bookmark_outline),
            tooltip: 'Bookmarks',
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${AppTime.greeting(now)}, $name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Continue your engineering journey.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),

          // Overall progress.
          stats.when(
            data: (data) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: _ProgressCard(stats: data),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: SkeletonBox(height: 148, radius: 14),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // The assistant is a headline feature, so it gets a first-class
          // card on the dashboard rather than being buried in a menu.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: ContentCard(
                onTap: () =>
                    Navigator.of(context).pushNamed(AppRoutes.assistant),
                semanticLabel:
                    'Study assistant. Ask questions using the offline curriculum.',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ask the study assistant',
                              style:
                                  Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Answers from the curriculum on this device. '
                            'Works offline.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),

          const SectionHeader(title: 'Continue learning'),
          subjects.when(
            data: (all) {
              final next = _nextSubject(all);
              if (next == null) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                    child: EmptyStateView(
                      icon: Icons.school_outlined,
                      title: 'Curriculum unavailable',
                      message:
                          'The subject list could not be read from this device.',
                    ),
                  ),
                );
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                  child: _SubjectCard(
                    key: ValueKey(next.id),
                    subject: next,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
                child: SkeletonBox(height: 96, radius: 14),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          const SectionHeader(
            title: 'Quick tools',
            subtitle: 'Jump straight into a calculator',
          ),
          const SliverToBoxAdapter(child: _QuickTools()),

          const SectionHeader(title: 'Recent activity'),
          activity.when(
            data: (items) {
              if (items.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                    child: Text('No activity yet. Start with a lesson!'),
                  ),
                );
              }
              return LazySliverList(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AppListRow(
                    key: ValueKey(item.id),
                    title: item.description,
                    subtitle: Text(AppTime.relative(item.createdAt, now: now)),
                    leading: Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: null,
                  );
                },
              );
            },
            loading: () => const SkeletonList(itemCount: 3, hasLeading: true),
            error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
        ],
      ),
    );
  }

  /// First subject that is not finished.
  ///
  /// `firstWhere` with a short-circuiting predicate replaces the previous
  /// `where(...).cast<Subject?>().firstWhere(...)`, which allocated two
  /// throwaway lists and evaluated `progress` for every subject.
  static Subject? _nextSubject(List<Subject> subjects) {
    if (subjects.isEmpty) return null;
    for (final subject in subjects) {
      if (subject.progress < 1.0) return subject;
    }
    return subjects.first;
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final percent = (stats.overallProgress * 100).round();

    return ContentCard(
      color: scheme.primaryContainer,
      padding: const EdgeInsets.all(AppSpacing.xl),
      semanticLabel:
          'Overall progress: $percent percent, ${stats.lessonsCompleted} of ${stats.totalLessons} lessons complete',
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
            label: 'Lessons completed',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${stats.lessonsCompleted} of ${stats.totalLessons} lessons'
            ' • ${stats.quizzesCompleted} quizzes'
            '${stats.studyStreakDays > 0 ? ' • ${stats.studyStreakDays} day streak' : ''}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ContentCard(
      onTap: () => Navigator.of(context).pushNamed(
        AppRoutes.subject,
        arguments: {RouteArgs.subject: subject},
      ),
      semanticLabel: '${subject.name}, '
          '${subject.completedLessons} of ${subject.totalLessons} lessons complete',
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Icon(subject.iconData, color: scheme.onSecondaryContainer),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${subject.completedLessons}/${subject.totalLessons} lessons',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.sm),
                ProgressBar(
                  value: subject.progress,
                  label: '${subject.name} progress',
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _QuickTools extends StatelessWidget {
  const _QuickTools();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    const tools = [
      (label: 'Ohm’s Law', icon: Icons.bolt_outlined, route: AppRoutes.electronics),
      (label: 'Number System', icon: Icons.numbers_outlined, route: AppRoutes.numberSystem),
      (label: 'CPU Scheduling', icon: Icons.timeline_outlined, route: AppRoutes.cpuScheduling),
      (label: 'Subnetting', icon: Icons.lan_outlined, route: AppRoutes.networking),
    ];

    return ResponsiveGrid(
      maxColumns: 4,
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return Card(
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              tool.route,
              arguments: tool.route == AppRoutes.electronics
                  ? {RouteArgs.toolId: 'ohms'}
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(tool.icon, color: scheme.primary),
                  const Spacer(),
                  Text(
                    tool.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

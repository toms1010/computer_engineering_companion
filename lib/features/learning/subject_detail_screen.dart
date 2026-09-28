import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/design/app_spacing.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Lessons inside one subject.
///
/// The previous version built a `ListView(children: [...])` containing every
/// lesson, which is not lazy: a subject with 37 lessons instantiated and laid
/// out all 37 rows at once. Rows now go through [LazySliverList] and carry
/// stable `ValueKey`s, so a completion toggle rebuilds one row rather than
/// the whole list.
class SubjectDetailScreen extends ConsumerWidget {
  const SubjectDetailScreen({super.key, required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(subjectDetailProvider(subject.id));
    final isBookmarked = ref.watch(
      bookmarkKeysProvider.select((keys) => keys.contains('subject:${subject.id}')),
    );

    return ScreenPerformanceWatcher(
      name: 'Subject',
      child: AppScaffold(
        title: subject.name,
        actions: [
          IconButton(
            onPressed: () => ref
                .read(bookmarksProvider.notifier)
                .toggle('subject', subject.id, subject.name),
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark subject',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.quiz,
                arguments: {
                  RouteArgs.quizMode: QuizMode.subject.label,
                  RouteArgs.subjectId: subject.id,
                }),
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Quiz this subject',
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
              child: _Summary(subject: subject),
            ),
          ),
          ...detail.when(
            data: (value) => [
              if (value.lessons.isEmpty)
                const EmptyStateSliver(
                  icon: Icons.inbox_outlined,
                  title: 'No lessons',
                  message: 'This subject has no lessons in the local curriculum.',
                )
              else
                LazySliverList(
                  itemCount: value.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = value.lessons[index];
                    return _LessonTile(
                      key: ValueKey(lesson.id),
                      lesson: lesson,
                      index: index,
                    );
                  },
                ),
            ],
            loading: () => const [SkeletonList(itemCount: 8)],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(subjectDetailProvider(subject.id)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.subject});

  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ContentCard(
      color: theme.colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject.description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
          const SizedBox(height: AppSpacing.md),
          ProgressBar(
            value: subject.progress,
            label: '${subject.name} progress',
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${subject.completedLessons} of ${subject.totalLessons} lessons complete',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends ConsumerWidget {
  const _LessonTile({super.key, required this.lesson, required this.index});

  final Lesson lesson;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppListRow(
        title: lesson.title,
        subtitle: Text(
          lesson.concept.isEmpty
              ? (lesson.definition.isEmpty
                  ? 'Lesson ${index + 1}'
                  : lesson.definition)
              : lesson.concept,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.lesson,
          arguments: {RouteArgs.lesson: lesson},
        ),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor:
              lesson.isCompleted ? scheme.primary : scheme.surfaceContainerHighest,
          foregroundColor:
              lesson.isCompleted ? scheme.onPrimary : scheme.onSurfaceVariant,
          child: lesson.isCompleted
              ? const Icon(Icons.check, size: 16)
              : Text('${index + 1}',
                  style: theme.textTheme.labelMedium),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lesson.formula.isNotEmpty)
              Icon(Icons.functions_outlined,
                  size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

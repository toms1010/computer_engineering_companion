import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/design/app_spacing.dart';
import '../../core/utils/app_time.dart';
import '../../domain/entities/entities.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Quiz launcher and recent attempts.
///
/// `subjectsProvider` is *read* in the tap handler rather than watched in
/// `build`: the screen only needs it when the user picks a subject, and
/// watching it made every progress change rebuild the whole screen.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempts = ref.watch(quizAttemptsProvider);

    return ScreenPerformanceWatcher(
      name: 'Practice',
      child: AppScaffold(
        title: 'Practice',
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.assistant),
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'Assistant',
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
              child: Column(
                children: [
                  _PracticeCard(
                    icon: Icons.bolt_outlined,
                    title: 'Quick quiz',
                    subtitle: '5 random questions from the whole bank',
                    onTap: () => _start(context, ref, QuizMode.quick),
                  ),
                  _PracticeCard(
                    icon: Icons.timer_outlined,
                    title: 'Exam',
                    subtitle: '10 random questions, scored like a test',
                    onTap: () => _start(context, ref, QuizMode.exam),
                  ),
                  _PracticeCard(
                    icon: Icons.replay_outlined,
                    title: 'Review mistakes',
                    subtitle: 'Re-attempt questions you got wrong',
                    onTap: () => _start(context, ref, QuizMode.mistakes),
                  ),
                  _PracticeCard(
                    icon: Icons.folder_outlined,
                    title: 'Subject quiz',
                    subtitle: 'Every question in one subject',
                    onTap: () => _pickSubject(context, ref),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'Recent attempts'),
          ...attempts.when(
            data: (all) {
              final recent = all.take(10).toList();
              if (recent.isEmpty) {
                return const [
                  EmptyStateSliver(
                    icon: Icons.quiz_outlined,
                    title: 'No attempts yet',
                    message: 'Take a quick quiz and your score will appear here.',
                  ),
                ];
              }
              return [
                LazySliverList(
                  itemCount: recent.length,
                  itemBuilder: (context, index) => _AttemptTile(
                    key: ValueKey(recent[index].id),
                    attempt: recent[index],
                    index: index,
                  ),
                ),
              ];
            },
            loading: () => const [SkeletonList(itemCount: 4, hasLeading: false)],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(quizAttemptsProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _start(BuildContext context, WidgetRef ref, QuizMode mode,
      {int? subjectId, int? lessonId}) {
    Navigator.of(context).pushNamed(AppRoutes.quiz, arguments: {
      RouteArgs.quizMode: mode.label,
      if (subjectId != null) RouteArgs.subjectId: subjectId,
      if (lessonId != null) RouteArgs.lessonId: lessonId,
    });
  }

  Future<void> _pickSubject(BuildContext context, WidgetRef ref) async {
    // Read on demand: the list is not needed until the sheet is opened.
    final subjects = await ref.read(subjectsProvider.future);
    if (!context.mounted) return;

    final selected = await showModalBottomSheet<Subject>(
      context: context,
      isScrollControlled: true,
      // A scrollable sheet: the previous one used a fixed Column, which
      // overflows as soon as the subject list grows.
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
              child: Text('Choose a subject',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return ListTile(
                    key: ValueKey(subject.id),
                    leading: Icon(subject.iconData),
                    title: Text(subject.name),
                    subtitle: Text('${subject.totalLessons} lessons'),
                    onTap: () => Navigator.of(sheetContext).pop(subject),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null && context.mounted) {
      _start(context, ref, QuizMode.subject, subjectId: selected.id);
    }
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ContentCard(
        onTap: onTap,
        semanticLabel: '$title. $subtitle',
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _AttemptTile extends StatelessWidget {
  const _AttemptTile({super.key, required this.attempt, required this.index});

  final QuizAttempt attempt;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final passed = attempt.score >= 60;
    final tint = passed ? scheme.primaryContainer : scheme.errorContainer;
    final onTint = passed ? scheme.onPrimaryContainer : scheme.onErrorContainer;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        color: tint.withValues(alpha: 0.45),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: tint,
            foregroundColor: onTint,
            child: Text('${attempt.score.round()}',
                style: theme.textTheme.titleSmall),
          ),
          title: Text(attempt.quizMode),
          subtitle: Text(
            '${attempt.correctAnswers}/${attempt.totalQuestions} correct'
            ' • ${AppTime.dateTime(attempt.completedAt)}',
          ),
          trailing: Pill(
            label: '${attempt.score.round()}%',
            color: tint,
            dense: true,
          ),
        ),
      ),
    );
  }
}

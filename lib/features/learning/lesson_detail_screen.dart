import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/design/app_spacing.dart';
import '../../core/design/app_typography.dart';
import '../../domain/entities/entities.dart';
import '../../services/ai/ai_models.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// One lesson in full, with on-device AI assistance.
///
/// The content itself is a fixed, bounded set of sections, so a sliver list
/// is not required here — but the topic list is user/DB driven and *is*
/// rendered lazily, and every section is wrapped so a single long lesson
/// cannot rebuild the whole screen when one part changes.
class LessonDetailScreen extends ConsumerStatefulWidget {
  const LessonDetailScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  int _lessonId = 0;
  String? _summary;
  bool _summarising = false;

  @override
  void initState() {
    super.initState();
    // Recorded once, so the assistant can recommend what comes next.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lastViewedLessonProvider.notifier).state = widget.lesson.id;
      }
    });
  }

  Future<void> _toggleCompletion() async {
    final repository = ref.read(repositoryProvider);
    final next = !widget.lesson.isCompleted;
    await repository.setLessonCompleted(widget.lesson.id, next);
    // Only the three derived providers are invalidated. The lesson itself is
    // re-read by its own provider.
    ref
      ..invalidate(lessonDetailProvider(_lessonId))
      ..invalidate(subjectsProvider)
      ..invalidate(progressStatsProvider)
      ..invalidate(notesProvider);
    if (mounted) {
      showAppSnackBar(
        context,
        next ? 'Lesson marked complete' : 'Lesson marked incomplete',
        icon: next ? Icons.check_circle_outline : Icons.undo,
      );
    }
  }

  Future<void> _summarise() async {
    setState(() => _summarising = true);
    try {
      final summary =
          await ref.read(aiServiceProvider).summarise(widget.lesson);
      if (mounted) setState(() => _summary = summary);
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Could not summarise this lesson yet');
      }
    } finally {
      if (mounted) setState(() => _summarising = false);
    }
  }

  Future<void> _generatePractice() async {
    try {
      final questions = await ref
          .read(aiServiceProvider)
          .generatePractice(widget.lesson);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Practice from this lesson',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: questions.length,
                  itemBuilder: (context, index) =>
                      _PracticeCard(question: questions[index]),
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, 'Could not build practice questions');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(lessonDetailProvider(widget.lesson.id));
    _lessonId = widget.lesson.id;
    final isBookmarked = ref.watch(bookmarkKeysProvider
        .select((keys) => keys.contains('lesson:${widget.lesson.id}')));

    return ScreenPerformanceWatcher(
      name: 'Lesson',
      child: AppScaffold(
        title: widget.lesson.title,
        actions: [
          IconButton(
            onPressed: () => ref
                .read(bookmarksProvider.notifier)
                .toggle('lesson', widget.lesson.id, widget.lesson.title),
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_outline),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Bookmark lesson',
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.quiz,
                arguments: {
                  RouteArgs.quizMode: QuizMode.lesson.label,
                  RouteArgs.lessonId: widget.lesson.id,
                }),
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'Quiz this lesson',
          ),
        ],
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.lesson.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.lg),

                  if (widget.lesson.formula.isNotEmpty) ...[
                    FormulaPanel(
                      formula: widget.lesson.formula,
                      onCopy: () =>
                          copyToClipboard(context, widget.lesson.formula,
                              label: 'formula'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  if (widget.lesson.concept.isNotEmpty)
                    _ContentSection(
                      title: 'Concept',
                      child: Text(widget.lesson.concept,
                          style: AppTypography.reading(context)),
                    ),
                  if (widget.lesson.definition.isNotEmpty)
                    _ContentSection(
                      title: 'Definition',
                      child: Text(widget.lesson.definition,
                          style: AppTypography.reading(context)),
                    ),

                  // On-device assistance. Built on the lesson's own text, so
                  // it works with no network.
                  if (_summary != null)
                    _ContentSection(
                      title: 'Summary',
                      child: Text(_summary!,
                          style: AppTypography.reading(context)),
                    )
                  else
                    _AiActions(
                      busy: _summarising,
                      onSummarise: _summarise,
                      onPractice: _generatePractice,
                    ),

                  if (widget.lesson.explanation.isNotEmpty)
                    _ContentSection(
                      title: 'Explanation',
                      child: Text(widget.lesson.explanation,
                          style: AppTypography.reading(context)),
                    ),
                  if (widget.lesson.workedExample.isNotEmpty)
                    _ContentSection(
                      title: 'Worked example',
                      child: Text(widget.lesson.workedExample,
                          style: AppTypography.reading(context)),
                    ),
                  if (widget.lesson.engineeringExample.isNotEmpty)
                    _ContentSection(
                      title: 'Engineering example',
                      child: Text(widget.lesson.engineeringExample,
                          style: AppTypography.reading(context)),
                    ),
                  if (widget.lesson.commonMistakes.isNotEmpty)
                    _ContentSection(
                      title: 'Common mistakes',
                      child: Text(widget.lesson.commonMistakes,
                          style: AppTypography.reading(context)),
                    ),

                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: _toggleCompletion,
                    icon: Icon(
                        widget.lesson.isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline),
                    label: Text(widget.lesson.isCompleted
                        ? 'Completed — tap to undo'
                        : 'Mark as complete'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Topics are unbounded relative to the database, so they get a lazy
          // list with stable keys rather than a `for` loop in a Column.
          ...detail.when(
            data: (value) {
              if (value.topics.isEmpty) return const <Widget>[];
              return [
                const SliverSectionHeader(title: 'Topics'),
                LazySliverList(
                  itemCount: value.topics.length,
                  itemBuilder: (context, index) {
                    final topic = value.topics[index];
                    return Padding(
                      key: ValueKey(topic.id),
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Card(
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: const Icon(Icons.topic_outlined),
                          title: Text(topic.title,
                              style: Theme.of(context).textTheme.titleSmall),
                          childrenPadding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                          children: [
                            Text(topic.content,
                                style: AppTypography.reading(context)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ];
            },
            loading: () => const <Widget>[],
            error: (_, __) => const <Widget>[],
          ),
        ],
      ),
    );
  }
}

class _AiActions extends StatelessWidget {
  const _AiActions({
    required this.busy,
    required this.onSummarise,
    required this.onPractice,
  });

  final bool busy;
  final VoidCallback onSummarise, onPractice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : onSummarise,
              icon: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.summarize_outlined, size: 18),
              label: const Text('Summarise'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPractice,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Practice'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.question});

  final GeneratedQuestion question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.prompt, style: theme.textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text('Answer', style: theme.textTheme.labelMedium),
            Text(question.answer, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Why', style: theme.textTheme.labelMedium),
            Text(question.explanation,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

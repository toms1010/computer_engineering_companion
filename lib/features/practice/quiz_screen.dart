import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_spacing.dart';
import '../../core/utils/app_time.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/quiz_scoring_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';
import '../../widgets/states.dart';

/// Runs a quiz and shows the result with a full review.
///
/// Three performance problems from the previous implementation are fixed:
///
///  * the timer called `setState` once a second, rebuilding the app bar, the
///    whole question body and the progress bar. The timer now drives only the
///    clock text through a [ValueListenableBuilder], so a tick repaints one
///    small widget;
///  * quick and exam modes loaded all 665 questions and then shuffled them on
///    the UI isolate. Randomised modes now select their rows in SQL;
///  * mistake review ran one query per attempt and then reloaded the whole
///    question bank. It is now a single joined query.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.mode,
    this.subjectId,
    this.lessonId,
  });

  final QuizMode mode;
  final int? subjectId;
  final int? lessonId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  static const _scoring = QuizScoringService();

  List<QuizQuestion> _questions = const [];
  final Map<int, Set<int>> _answers = {};
  int _current = 0;
  bool _loading = true;
  bool _finished = false;
  bool _saving = false;
  int _correct = 0;
  String _error = '';
  final Stopwatch _clock = Stopwatch();
  Timer? _timer;
  final ValueNotifier<int> _elapsed = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _clock.start();
    // Ticks only repaint the clock label, not the whole screen.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed.value = _clock.elapsed.inSeconds;
    });
    _load();
  }

  @override
  void dispose() {
    // Every timer, listener and notifier owned by this screen is released
    // here. A quiz left open must not keep ticking in the background.
    _timer?.cancel();
    _elapsed.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repository = ref.read(repositoryProvider);
    final limit = widget.mode.questionLimit;
    try {
      final List<QuizQuestion> loaded;
      if (widget.mode == QuizMode.mistakes) {
        final entries = await repository.loadMistakesForReview(
          subjectId: widget.subjectId ?? 0,
          limit: limit ?? 20,
        );
        loaded = entries.map((e) => e.question).toList(growable: false);
        // Pre-fill the user's previous wrong answers so the review shows
        // what they chose last time.
        for (final entry in entries) {
          _answers[entry.question.id] = {...entry.selected};
        }
      } else if (widget.mode.isRandomised) {
        loaded = await repository.loadRandomQuestions(
          subjectId: widget.subjectId,
          lessonId: widget.lessonId,
          limit: limit ?? 5,
        );
      } else {
        loaded = await repository.loadQuestions(
          subjectId: widget.subjectId,
          lessonId: widget.lessonId,
        );
      }

      if (!mounted) return;
      setState(() {
        _questions = loaded;
        _loading = false;
        if (loaded.isEmpty) {
          _error = switch (widget.mode) {
            QuizMode.mistakes =>
              'You have no wrong answers to review yet. Take a quiz first!',
            QuizMode.subject || QuizMode.lesson =>
              'No questions are available for this selection.',
            _ => 'No questions are available.',
          };
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load the questions. $error';
      });
    }
  }

  bool get _isMultiSelect =>
      _questions.isNotEmpty && _questions[_current].correctIndexes.length > 1;

  void _select(int optionIndex) {
    final question = _questions[_current];
    setState(() {
      final selected = _answers.putIfAbsent(question.id, () => <int>{});
      if (_isMultiSelect) {
        if (!selected.remove(optionIndex)) selected.add(optionIndex);
      } else {
        selected
          ..clear()
          ..add(optionIndex);
      }
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() => _current++);
    } else {
      _finish();
    }
  }

  void _previous() {
    if (_current > 0) setState(() => _current--);
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final correct = _scoring.scoreAnswers(_questions, _answers);

    setState(() {
      _finished = true;
      _correct = correct;
      _saving = true;
    });

    try {
      await ref.read(repositoryProvider).saveQuizAttempt(
            subjectId: widget.subjectId ?? 0,
            correct: correct,
            total: _questions.length,
            elapsedSeconds: _clock.elapsed.inSeconds,
            quizMode: widget.mode.label,
            answers: _answers,
            questions: _questions,
          );
    } catch (_) {
      // A failed save must not lose the user's answers on screen; report it
      // and carry on.
      if (mounted) {
        showAppSnackBar(
            context, 'Your result could not be saved to this device');
      }
    }

    if (!mounted) return;
    ref
      ..invalidate(quizAttemptsProvider)
      ..invalidate(progressStatsProvider)
      ..invalidate(activitiesProvider);
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenPerformanceWatcher(
      name: 'Quiz',
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mode.title),
          actions: [
            if (_questions.isNotEmpty && !_finished)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.lg),
                  child: ValueListenableBuilder<int>(
                    valueListenable: _elapsed,
                    builder: (context, seconds, _) => Text(
                      AppTime.stopwatch(seconds),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildControls(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingView(message: 'Loading questions…');
    }
    if (_questions.isEmpty) {
      return EmptyStateView(
        icon: Icons.quiz_outlined,
        title: 'Nothing to quiz',
        message: _error,
        actionLabel: 'Go back',
        onAction: () => Navigator.of(context).maybePop(),
      );
    }
    if (_finished) return _buildResult();

    final question = _questions[_current];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
          child: ProgressBar(
            value: (_current + 1) / _questions.length,
            label: 'Question ${_current + 1} of ${_questions.length}',
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            children: [
              Row(
                children: [
                  Pill(label: _typeLabel(question), dense: true),
                  const SizedBox(width: AppSpacing.sm),
                  if (_isMultiSelect)
                    const Pill(label: 'Select all that apply', dense: true),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(question.prompt,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xl),
              // Correctly lazy already, but given stable keys so a selection
              // change does not rebuild every option row.
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: question.options.length,
                itemBuilder: (context, index) => Padding(
                  key: ValueKey('${question.id}:$index'),
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _OptionTile(
                    label: question.options[index],
                    selected: _answers[question.id]?.contains(index) ?? false,
                    onTap: () => _select(index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildControls() {
    if (_loading || _questions.isEmpty || _finished) return null;
    return ActionBar(
      children: [
        OutlinedButton(
          onPressed: _current == 0 ? null : _previous,
          child: const Text('Back'),
        ),
        FilledButton(
          onPressed: _next,
          child: Text(_current == _questions.length - 1 ? 'Finish' : 'Next'),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final score = _scoring.accuracy(_correct, _questions.length);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Column(
              children: [
                ContentCard(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Text(
                        _scoring.grade(score),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text('${score.round()}%', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.sm),
                      Text(_scoring.feedback(score),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '$_correct of ${_questions.length} correct'
                        ' • ${AppTime.stopwatch(_clock.elapsed.inSeconds)}'
                        '${_saving ? ' • saving…' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverSectionHeader(
            title: 'Review',
            subtitle: 'Tap a question to see the explanation',
          ),
        // `ListView.separated` over review cards: the previous version built
        // every card up front, each containing an animated ExpansionTile.
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          sliver: SliverList.separated(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return _ReviewCard(
                key: ValueKey('review:${question.id}'),
                question: question,
                selected: _answers[question.id] ?? const <int>{},
                index: index,
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ),
      ],
    );
  }

  /// Precomputed once per question instead of `replaceAll` + `toUpperCase` on
  /// every build (which the timer previously triggered once a second).
  static String _typeLabel(QuizQuestion question) =>
      question.type.replaceAll('_', ' ').toUpperCase();
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: selected ? scheme.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? scheme.primary : scheme.outline,
        ),
        title: Text(label),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    super.key,
    required this.question,
    required this.selected,
    required this.index,
  });

  final QuizQuestion question;
  final Set<int> selected;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final correct = question.isCorrect(selected);

    return Card(
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          radius: 14,
          backgroundColor:
              correct ? scheme.primary : scheme.errorContainer,
          foregroundColor:
              correct ? scheme.onPrimary : scheme.onErrorContainer,
          child: Icon(correct ? Icons.check : Icons.close, size: 15),
        ),
        title: Text('Q${index + 1}. ${question.prompt}',
            maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(correct ? 'Correct' : 'Incorrect'),
        childrenPadding:
            const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        children: [
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    question.correctIndexes.contains(i)
                        ? Icons.check_circle
                        : selected.contains(i)
                            ? Icons.cancel
                            : Icons.circle_outlined,
                    size: 18,
                    color: question.correctIndexes.contains(i)
                        ? scheme.primary
                        : selected.contains(i)
                            ? scheme.error
                            : scheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      question.options[i],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: question.correctIndexes.contains(i)
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (question.explanation.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text('Explanation', style: theme.textTheme.labelMedium),
            Text(question.explanation, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/quiz_scoring_service.dart';

enum QuizMode { quick, subject, exam, lesson, mistakes }

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.mode,
    required this.title,
    this.subjectId,
    this.lessonId,
  });

  final QuizMode mode;
  final String title;
  final int? subjectId;
  final int? lessonId;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  List<QuizQuestion> _questions = [];
  final Map<int, Set<int>> _answers = {};
  int _current = 0;
  bool _loading = true;
  bool _finished = false;
  int _correct = 0;
  DateTime _startTime = DateTime.now();
  Timer? _timer;
  int _elapsedSeconds = 0;
  int? _attemptId;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _loadQuestions();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_finished) {
        setState(() => _elapsedSeconds =
            DateTime.now().difference(_startTime).inSeconds);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final repository = ref.read(repositoryProvider);
    List<QuizQuestion> questions;
    switch (widget.mode) {
      case QuizMode.lesson:
        questions = await repository.loadQuestions(lessonId: widget.lessonId);
      case QuizMode.subject:
        questions = await repository.loadQuestions(subjectId: widget.subjectId);
      case QuizMode.exam:
        questions = await repository.loadQuestions();
        questions = (questions..shuffle()).take(10).toList();
      case QuizMode.mistakes:
        questions = await _loadMistakes();
      case QuizMode.quick:
        questions = await repository.loadQuestions();
        questions = (questions..shuffle()).take(5).toList();
    }
    if (mounted) {
      setState(() {
        _questions = questions;
        _loading = false;
      });
    }
  }

  Future<List<QuizQuestion>> _loadMistakes() async {
    final repository = ref.read(repositoryProvider);
    final attempts = await repository.loadQuizAttempts();
    final mistakeQuestionIds = <int>{};
    for (final attempt in attempts) {
      final answers = await repository.loadQuizAnswers(attempt.id);
      for (final answer in answers) {
        if (!answer.isCorrect) mistakeQuestionIds.add(answer.questionId);
      }
    }
    if (mistakeQuestionIds.isEmpty) return [];
    final allQuestions = await repository.loadQuestions();
    return allQuestions
        .where((q) => mistakeQuestionIds.contains(q.id))
        .toList();
  }

  void _selectOption(int questionId, int optionIndex, bool multi) {
    setState(() {
      final current = _answers[questionId] ?? <int>{};
      if (multi) {
        if (current.contains(optionIndex)) {
          current.remove(optionIndex);
        } else {
          current.add(optionIndex);
        }
      } else {
        current
          ..clear()
          ..add(optionIndex);
      }
      _answers[questionId] = current;
    });
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final scoring = const QuizScoringService();
    final correct = scoring.scoreAnswers(_questions, _answers);
    final repository = ref.read(repositoryProvider);
    final attemptId = await repository.saveQuizAttempt(
      subjectId: widget.subjectId ?? 0,
      correct: correct,
      total: _questions.length,
      elapsedSeconds: _elapsedSeconds,
      quizMode: switch (widget.mode) {
        QuizMode.quick => 'quick',
        QuizMode.subject => 'subject',
        QuizMode.exam => 'exam',
        QuizMode.lesson => 'lesson',
        QuizMode.mistakes => 'mistakes',
      },
      answers: _answers,
      questions: _questions,
    );
    if (mounted) {
      setState(() {
        _finished = true;
        _correct = correct;
        _attemptId = attemptId;
      });
      ref.invalidate(quizAttemptsProvider);
      ref.invalidate(progressStatsProvider);
      ref.invalidate(activitiesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$_elapsedSeconds s',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? EmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'No questions available',
                  subtitle: widget.mode == QuizMode.mistakes
                      ? 'You have no mistakes to review. Great job!'
                      : 'Questions for this selection are not available yet.',
                )
              : _finished
                  ? _buildResult()
                  : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_current];
    final isMulti = question.type == 'multiple_answer';
    final selected = _answers[question.id] ?? <int>{};

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_current + 1} of ${_questions.length}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (isMulti)
                    Text('Select all that apply',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                  value: (_current + 1) / _questions.length),
              const SizedBox(height: 20),
              Text(
                question.prompt,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.type.replaceAll('_', ' ').toUpperCase(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            itemCount: question.options.length,
            itemBuilder: (context, i) {
              final isSelected = selected.contains(i);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    leading: Icon(
                      isMulti
                          ? (isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank)
                          : (isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off),
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
                    title: Text(question.options[i]),
                    onTap: () =>
                        _selectOption(question.id, i, isMulti),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                if (_current > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _current--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      if (_current < _questions.length - 1) {
                        setState(() => _current++);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(
                        _current == _questions.length - 1 ? 'Finish' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final total = _questions.length;
    final score = total == 0 ? 0.0 : (_correct / total) * 100;
    final scoring = const QuizScoringService();
    final grade = scoring.grade(score);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Quiz Complete',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer)),
                const SizedBox(height: 16),
                Text('$_correct / $total',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer)),
                Text('${score.round()}% • Grade: $grade',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer)),
                const SizedBox(height: 8),
                Text(
                  scoring.feedback(score),
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Review',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (var i = 0; i < _questions.length; i++)
          _ReviewCard(
            question: _questions[i],
            selected: _answers[_questions[i].id] ?? <int>{},
            index: i + 1,
          ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.check),
          label: const Text('Done'),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.question,
    required this.selected,
    required this.index,
  });

  final QuizQuestion question;
  final Set<int> selected;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isCorrect = question.isCorrect(selected);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : scheme.error,
        ),
        title: Text('Q$index: ${question.prompt}',
            maxLines: 2, overflow: TextOverflow.ellipsis),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    question.correctIndexes.contains(i)
                        ? Icons.check_circle
                        : (selected.contains(i)
                            ? Icons.cancel
                            : Icons.circle_outlined),
                    size: 18,
                    color: question.correctIndexes.contains(i)
                        ? Colors.green
                        : (selected.contains(i) ? scheme.error : scheme.outline),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(question.options[i])),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Explanation: ${question.explanation}',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';
import 'quiz_screen.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attemptsAsync = ref.watch(quizAttemptsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return PageFrame(
      title: 'Practice',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PracticeCard(
            icon: Icons.bolt_outlined,
            title: 'Quick Quiz',
            subtitle: 'Random questions from all subjects',
            onTap: () => _startQuiz(context, QuizMode.quick, null, 'Quick Quiz'),
          ),
          _PracticeCard(
            icon: Icons.subject_outlined,
            title: 'Subject Quiz',
            subtitle: 'Practice a specific subject',
            onTap: () => _pickSubject(context, subjectsAsync.valueOrNull ?? []),
          ),
          _PracticeCard(
            icon: Icons.timer_outlined,
            title: 'Exam Mode',
            subtitle: 'Timed quiz across multiple subjects',
            onTap: () => _startQuiz(context, QuizMode.exam, null, 'Exam Mode'),
          ),
          _PracticeCard(
            icon: Icons.error_outline_outlined,
            title: 'Review Mistakes',
            subtitle: 'Review questions you answered incorrectly',
            onTap: () => _startQuiz(context, QuizMode.mistakes, null, 'Review Mistakes'),
          ),
          const SectionTitle('Quiz history'),
          attemptsAsync.when(
            data: (attempts) {
              if (attempts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No quizzes yet. Take your first quiz!'),
                );
              }
              return Column(
                children: [
                  for (final attempt in attempts.take(10))
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: attempt.score >= 70
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.errorContainer,
                          child: Text(
                            '${attempt.score.round()}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: attempt.score >= 70
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                            ),
                          ),
                        ),
                        title: Text('${attempt.correctAnswers}/${attempt.totalQuestions} correct'),
                        subtitle: Text(
                          '${attempt.quizMode} • ${_formatDate(attempt.completedAt)}',
                        ),
                        trailing: Text('${attempt.score.round()}%'),
                      ),
                    ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _pickSubject(BuildContext context, List<Subject> subjects) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Choose a subject',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            for (final s in subjects)
              ListTile(
                leading: Icon(s.iconData),
                title: Text(s.name),
                subtitle: Text('${s.description} • ${s.totalLessons} lessons'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _startQuiz(context, QuizMode.subject, s.id, s.name);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context, QuizMode mode, int? subjectId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          mode: mode,
          subjectId: subjectId,
          title: title,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

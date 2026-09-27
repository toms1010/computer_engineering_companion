import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';
import '../practice/quiz_screen.dart';

class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({super.key, required this.lessonId});
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(lessonDetailProvider(lessonId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
        actions: [
          _CompleteButton(lessonId: lessonId),
        ],
      ),
      body: detailAsync.when(
        data: (detail) {
          final lesson = detail.lesson;
          if (lesson == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Lesson not found',
              subtitle: 'This lesson could not be loaded.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(lesson.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _ContentSection(
                title: 'Concept',
                icon: Icons.lightbulb_outline,
                content: lesson.concept,
              ),
              if (lesson.definition.isNotEmpty)
                _ContentSection(
                  title: 'Definition',
                  icon: Icons.book_outlined,
                  content: lesson.definition,
                ),
              if (lesson.formula.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Formula',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                FormulaBlock(lesson.formula),
              ],
              _ContentSection(
                title: 'Explanation',
                icon: Icons.menu_book_outlined,
                content: lesson.explanation,
              ),
              if (lesson.workedExample.isNotEmpty)
                _ContentSection(
                  title: 'Worked Example',
                  icon: Icons.calculate_outlined,
                  content: lesson.workedExample,
                  code: true,
                ),
              if (lesson.engineeringExample.isNotEmpty)
                _ContentSection(
                  title: 'Engineering Example',
                  icon: Icons.engineering_outlined,
                  content: lesson.engineeringExample,
                ),
              if (lesson.commonMistakes.isNotEmpty)
                _ContentSection(
                  title: 'Common Mistakes',
                  icon: Icons.warning_amber_outlined,
                  content: lesson.commonMistakes,
                ),
              if (detail.topics.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Topics',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final topic in detail.topics)
                  Card(
                    child: ExpansionTile(
                      leading: const Icon(Icons.topic_outlined),
                      title: Text(topic.title,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(topic.content,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      mode: QuizMode.lesson,
                      lessonId: lessonId,
                      title: '${lesson.title} Quiz',
                    ),
                  ),
                ),
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Take Lesson Quiz'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load lesson',
          subtitle: '$e',
        ),
      ),
    );
  }
}

class _CompleteButton extends ConsumerWidget {
  const _CompleteButton({required this.lessonId});
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(lessonDetailProvider(lessonId));
    final isCompleted = detailAsync.valueOrNull?.lesson?.isCompleted ?? false;
    return IconButton(
      icon: Icon(isCompleted ? Icons.check_circle : Icons.check_circle_outline),
      onPressed: isCompleted
          ? null
          : () async {
              await ref.read(repositoryProvider).completeLesson(lessonId);
              ref.invalidate(lessonDetailProvider(lessonId));
              ref.invalidate(subjectsProvider);
              ref.invalidate(progressStatsProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lesson completed!'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({
    required this.title,
    required this.icon,
    required this.content,
    this.code = false,
  });

  final String title, content;
  final IconData icon;
  final bool code;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          if (code)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurface,
                ),
              ),
            )
          else
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
        ],
      ),
    );
  }
}

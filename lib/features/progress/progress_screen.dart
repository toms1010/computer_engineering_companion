import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(progressStatsProvider);

    return PageFrame(
      title: 'Progress',
      child: statsAsync.when(
        data: (stats) {
          final percent = (stats.overallProgress * 100).round();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERALL PROGRESS',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                      const SizedBox(height: 4),
                      Text('$percent%',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer)),
                      const SizedBox(height: 12),
                      ProgressLine(stats.overallProgress),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ResultCard(
                    label: 'Lessons completed',
                    value: '${stats.lessonsCompleted}',
                    icon: Icons.menu_book_outlined,
                  ),
                  ResultCard(
                    label: 'Quiz accuracy',
                    value: '${stats.quizAccuracy.round()}%',
                    icon: Icons.quiz_outlined,
                  ),
                  ResultCard(
                    label: 'Study streak',
                    value: '${stats.studyStreakDays} days',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  ResultCard(
                    label: 'Study time',
                    value: _formatDuration(stats.totalStudyMinutes),
                    icon: Icons.timer_outlined,
                  ),
                ],
              ),
              const SectionTitle('Strong areas'),
              if (stats.strongSubjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Complete more lessons to see strong areas.'),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in stats.strongSubjects)
                      Chip(
                        avatar: const Icon(Icons.check_circle, size: 18),
                        label: Text(s),
                      ),
                  ],
                ),
              const SectionTitle('Needs review'),
              if (stats.needsReviewSubjects.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Nothing needs review. Great job!'),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final s in stats.needsReviewSubjects)
                      Chip(
                        avatar: Icon(Icons.refresh,
                            size: 18,
                            color: Theme.of(context).colorScheme.error),
                        label: Text(s),
                      ),
                  ],
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load progress',
          subtitle: '$e',
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';
import '../calculators/number_system_calculator_screen.dart';
import '../calculators/electronics_calculator_screen.dart';
import '../simulators/cpu_scheduling_screen.dart';
import '../learning/subject_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final activitiesAsync = ref.watch(activitiesProvider);
    final progressAsync = ref.watch(progressStatsProvider);
    final name = ref.watch(profileNameProvider).valueOrNull ?? 'Student';

    return PageFrame(
      title: 'Home',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_greeting()}, $name',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Continue your engineering journey.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          progressAsync.when(
            data: (stats) => _ProgressCard(stats: stats),
            loading: () => const Card(
                child: Padding(
                    padding: EdgeInsets.all(22),
                    child: Center(child: CircularProgressIndicator()))),
            error: (_, __) => const SizedBox.shrink(),
          ),
          subjectsAsync.when(
            data: (subjects) {
              final next = subjects
                  .where((s) => s.progress < 1.0)
                  .cast<Subject?>()
                  .firstWhere((s) => true, orElse: () => subjects.isEmpty ? null : subjects.first);
              if (next == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Continue learning'),
                  _SubjectCard(subject: next),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SectionTitle('Quick tools'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickTool(
                'Ohm\'s Law',
                Icons.bolt_outlined,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ElectronicsCalculatorScreen(initial: 'ohms'))),
              ),
              _QuickTool(
                'Number System',
                Icons.numbers_outlined,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const NumberSystemCalculatorScreen())),
              ),
              _QuickTool(
                'CPU Scheduling',
                Icons.timeline_outlined,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CpuSchedulingScreen())),
              ),
              _QuickTool(
                'Subnetting',
                Icons.lan_outlined,
                () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const NumberSystemCalculatorScreen())),
              ),
            ],
          ),
          const SectionTitle('Recent activity'),
          activitiesAsync.when(
            data: (activities) {
              if (activities.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No activity yet. Start learning!'),
                );
              }
              return Column(
                children: [
                  for (final item in activities.take(5))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.history,
                          color: Theme.of(context).colorScheme.primary),
                      title: Text(item.description),
                      subtitle: Text(_timeAgo(item.createdAt)),
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.stats});
  final ProgressStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (stats.overallProgress * 100).round();
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OVERALL PROGRESS',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: scheme.onPrimaryContainer)),
            const SizedBox(height: 4),
            Text('$percent%',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer)),
            const SizedBox(height: 12),
            ProgressLine(stats.overallProgress),
            const SizedBox(height: 12),
            Text(
              '${stats.lessonsCompleted} of ${stats.totalLessons} lessons • ${stats.quizzesCompleted} quizzes',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});
  final Subject subject;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SubjectDetailScreen(subject: subject)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subject.iconData,
                    color: scheme.onSecondaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      '${subject.completedLessons}/${subject.totalLessons} lessons',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    ProgressLine(subject.progress),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTool extends StatelessWidget {
  const _QuickTool(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 52) / 2,
      height: 88,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const Spacer(),
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

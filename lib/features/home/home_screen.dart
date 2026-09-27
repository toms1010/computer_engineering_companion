import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../../domain/entities/entities.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjects = ref.watch(subjectsProvider);
    final activities = ref.watch(activityProvider);
    final completed =
        subjects.fold(0, (total, subject) => total + subject.completedLessons);
    final lessonTotal =
        subjects.fold(0, (total, subject) => total + subject.totalLessons);
    final next = subjects.firstWhere((subject) => subject.progress < 1,
        orElse: () => subjects.first);
    return PageFrame(
        title: 'Home',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good morning, ${ref.watch(profileNameProvider)} 👋',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Let’s continue your Computer Engineering journey.'),
          const SizedBox(height: 22),
          Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('STUDY PROGRESS'),
                        Text('${((completed / lessonTotal) * 100).round()}%',
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        ProgressLine(completed / lessonTotal),
                        const SizedBox(height: 12),
                        Text(
                            '$completed lessons completed • ${activities.length} activities'),
                      ]))),
          const SectionTitle('Continue learning'),
          SubjectCard(
              subject: next,
              onComplete: () =>
                  ref.read(subjectsProvider.notifier).complete(next)),
          const SectionTitle('Quick tools'),
          const Wrap(spacing: 10, runSpacing: 10, children: [
            QuickTool('Ohm’s Law', Icons.bolt_outlined),
            QuickTool('CPU Scheduling', Icons.timeline_outlined),
            QuickTool('Logic Gates', Icons.account_tree_outlined),
            QuickTool('Subnetting', Icons.lan_outlined)
          ]),
          const SectionTitle('Recent activity'),
          ...activities.take(3).map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(item.description),
              subtitle: const Text('Saved locally'))),
        ]));
  }
}

class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject, this.onComplete});
  final Subject subject;
  final VoidCallback? onComplete;
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          leading: const Icon(Icons.menu_book),
          title: Text(subject.name,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subject.description),
            const SizedBox(height: 10),
            ProgressLine(subject.progress)
          ]),
          trailing: onComplete == null
              ? null
              : IconButton(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle_outline))));
}

class QuickTool extends StatelessWidget {
  const QuickTool(this.label, this.icon, {super.key});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 150,
      height: 100,
      child: Card(
          child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon),
                        const Spacer(),
                        Text(label,
                            style: const TextStyle(fontWeight: FontWeight.w700))
                      ])))));
}

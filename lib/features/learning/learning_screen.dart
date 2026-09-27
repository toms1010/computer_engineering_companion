import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';
import '../home/home_screen.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});
  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  String query = '', category = 'All';
  @override
  Widget build(BuildContext context) {
    final list = ref
        .watch(subjectsProvider)
        .where((s) =>
            (category == 'All' || s.category == category) &&
            (query.isEmpty ||
                s.name.toLowerCase().contains(query.toLowerCase())))
        .toList();
    return PageFrame(
        title: 'Learn',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              onChanged: (v) => setState(() => query = v),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search subjects, lessons, and topics')),
          const SizedBox(height: 12),
          Wrap(
              spacing: 8,
              children: [
                'All',
                'Programming',
                'Hardware',
                'Networking',
                'Electronics',
                'Mathematics'
              ]
                  .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: category == c,
                      onSelected: (_) => setState(() => category = c)))
                  .toList()),
          const SectionTitle('Subjects'),
          ...list.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SubjectCard(
                  subject: s,
                  onComplete: () =>
                      ref.read(subjectsProvider.notifier).complete(s))))
        ]));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_providers.dart';
import '../../core/widgets/ui.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
      title: 'Practice',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              'Quick Quiz',
              'Subject Quiz',
              'Timed Quiz',
              'Review Mistakes'
            ]
                .map((label) => SizedBox(
                    width: 160,
                    height: 100,
                    child: Card(
                        child: InkWell(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => QuizPage(title: label))),
                            child: Center(
                                child: Text(label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)))))))
                .toList()),
        const SectionTitle('Simulators'),
        const ListTile(
            leading: Icon(Icons.timeline),
            title: Text('CPU Scheduling'),
            subtitle: Text('FCFS, SJF, SRTF, Round Robin, Priority')),
        const ListTile(
            leading: Icon(Icons.account_tree), title: Text('Digital Logic')),
        const ListTile(leading: Icon(Icons.lan), title: Text('Networking'))
      ]));
}

class QuizPage extends ConsumerStatefulWidget {
  const QuizPage({super.key, required this.title});
  final String title;
  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  int current = 0;
  final choices = <int, int>{};
  @override
  Widget build(BuildContext context) {
    final questions = ref.read(repositoryProvider).questions();
    final q = questions[current];
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Question ${current + 1} of ${questions.length}'),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: (current + 1) / questions.length),
              const SizedBox(height: 24),
              Text(q.prompt, style: Theme.of(context).textTheme.headlineSmall),
              ...List.generate(
                  q.options.length,
                  (i) => Card(
                        child: ListTile(
                          selected: choices[q.id] == i,
                          leading: Icon(choices[q.id] == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off),
                          title: Text(q.options[i]),
                          onTap: () => setState(() => choices[q.id] = i),
                        ),
                      )),
              const Spacer(),
              FilledButton(
                  onPressed: choices[q.id] == null
                      ? null
                      : () {
                          if (current < questions.length - 1) {
                            setState(() => current++);
                          } else {
                            final score = questions
                                .where((item) =>
                                    choices[item.id] != null &&
                                    item.correctIndexes
                                        .contains(choices[item.id]))
                                .length;
                            ref.read(repositoryProvider).saveQuiz(
                                correct: score, total: questions.length);
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                        title: const Text('Quiz complete'),
                                        content: Text(
                                            'Score: $score / ${questions.length}'),
                                        actions: [
                                          TextButton(
                                              onPressed: () => Navigator.of(
                                                      context)
                                                  .popUntil((r) => r.isFirst),
                                              child: const Text('Done'))
                                        ]));
                          }
                        },
                  child:
                      Text(current == questions.length - 1 ? 'Finish' : 'Next'))
            ])));
  }
}

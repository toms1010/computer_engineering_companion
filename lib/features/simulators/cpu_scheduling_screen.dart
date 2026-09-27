import 'package:flutter/material.dart';

class CpuSchedulingScreen extends StatefulWidget {
  const CpuSchedulingScreen({super.key});
  @override
  State<CpuSchedulingScreen> createState() => _CpuSchedulingScreenState();
}

class _CpuSchedulingScreenState extends State<CpuSchedulingScreen> {
  String algorithm = 'FCFS';
  final burst = TextEditingController(text: '5');
  final arrival = TextEditingController(text: '0');
  final priority = TextEditingController(text: '1');
  final quantum = TextEditingController(text: '2');
  final processes = <Map<String, int>>[
    {'arrival': 0, 'burst': 5, 'priority': 1},
    {'arrival': 1, 'burst': 3, 'priority': 2},
    {'arrival': 2, 'burst': 2, 'priority': 3}
  ];
  @override
  void dispose() {
    burst.dispose();
    arrival.dispose();
    priority.dispose();
    quantum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _calculate();
    return Scaffold(
        appBar: AppBar(title: const Text('CPU Scheduling')),
        body: SafeArea(
            child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Professional simulator',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          DropdownButtonFormField(
              initialValue: algorithm,
              decoration: const InputDecoration(labelText: 'Algorithm'),
              items: ['FCFS', 'SJF', 'SRTF', 'Round Robin', 'Priority']
                  .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                  .toList(),
              onChanged: (v) => setState(() => algorithm = v!)),
          if (algorithm == 'Round Robin') ...[
            const SizedBox(height: 10),
            TextField(
                controller: quantum,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantum'))
          ],
          const SizedBox(height: 16),
          Text('Processes',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          ...processes.asMap().entries.map((e) => ListTile(
              leading: CircleAvatar(child: Text('P${e.key + 1}')),
              title: Text(
                  'Arrival ${e.value['arrival']}  •  Burst ${e.value['burst']}'),
              subtitle: Text('Priority ${e.value['priority']}'))),
          const SizedBox(height: 8),
          FilledButton.icon(
              onPressed: () {
                setState(() => processes.add({
                      'arrival': int.tryParse(arrival.text) ?? 0,
                      'burst': int.tryParse(burst.text) ?? 1,
                      'priority': int.tryParse(priority.text) ?? 1
                    }));
              },
              icon: const Icon(Icons.add),
              label: const Text('Add process')),
          const SizedBox(height: 22),
          FilledButton(
              onPressed: () => setState(() {}),
              child: const Text('Run simulation')),
          const SizedBox(height: 22),
          Text('Gantt chart',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
              children: result
                  .map((r) => Container(
                      margin: const EdgeInsets.only(right: 2, bottom: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Text('P${r['p']}  ${r['start']}–${r['end']}')))
                  .toList()),
          const SizedBox(height: 12),
          Text('Results',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          DataTable(
              columns: const [
                DataColumn(label: Text('Process')),
                DataColumn(label: Text('Completion')),
                DataColumn(label: Text('Turnaround')),
                DataColumn(label: Text('Waiting'))
              ],
              rows: result
                  .map((r) => DataRow(cells: [
                        DataCell(Text('P${r['p']}')),
                        DataCell(Text('${r['end']}')),
                        DataCell(Text('${r['turn']}')),
                        DataCell(Text('${r['wait']}'))
                      ]))
                  .toList()),
          Text(
            'Average waiting time: ${(result.map((r) => r['wait']!).reduce((a, b) => a + b) / result.length).toStringAsFixed(1)}',
          )
        ])));
  }

  List<Map<String, int>> _calculate() {
    final ordered = [...processes];
    if (algorithm == 'SJF')
      ordered.sort((a, b) => a['burst']!.compareTo(b['burst']!));
    if (algorithm == 'Priority')
      ordered.sort((a, b) => a['priority']!.compareTo(b['priority']!));
    var time = 0;
    return ordered.asMap().entries.map((e) {
      time = time < e.value['arrival']! ? e.value['arrival']! : time;
      final start = time;
      time += e.value['burst']!;
      return {
        'p': processes.indexOf(e.value) + 1,
        'start': start,
        'end': time,
        'turn': time - e.value['arrival']!,
        'wait': start - e.value['arrival']!
      };
    }).toList();
  }
}

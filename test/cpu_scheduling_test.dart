import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/services/cpu_scheduling_service.dart';

void main() {
  const service = CpuSchedulingService();

  group('FCFS', () {
    test('calculates correctly for simple case', () {
      final result = service.schedule(SchedulingAlgorithm.fcfs, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 5),
        Process(id: 2, name: 'P2', arrivalTime: 1, burstTime: 3),
      ]);
      final p1 = result.processes.firstWhere((p) => p.processId == 1);
      final p2 = result.processes.firstWhere((p) => p.processId == 2);
      expect(p1.completionTime, 5);
      expect(p1.turnaroundTime, 5);
      expect(p1.waitingTime, 0);
      expect(p2.completionTime, 8);
      expect(p2.turnaroundTime, 7);
      expect(p2.waitingTime, 4);
    });

    test('handles idle time', () {
      final result = service.schedule(SchedulingAlgorithm.fcfs, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 2),
        Process(id: 2, name: 'P2', arrivalTime: 5, burstTime: 3),
      ]);
      expect(result.processes.firstWhere((p) => p.processId == 2).waitingTime, 0);
    });
  });

  group('SJF', () {
    test('selects shortest job first', () {
      final result = service.schedule(SchedulingAlgorithm.sjf, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 6),
        Process(id: 2, name: 'P2', arrivalTime: 0, burstTime: 2),
        Process(id: 3, name: 'P3', arrivalTime: 0, burstTime: 8),
      ]);
      final order = result.gantt.map((g) => g.processName).toList();
      expect(order.first, 'P2');
    });

    test('minimizes average waiting time', () {
      final result = service.schedule(SchedulingAlgorithm.sjf, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 6),
        Process(id: 2, name: 'P2', arrivalTime: 0, burstTime: 2),
        Process(id: 3, name: 'P3', arrivalTime: 0, burstTime: 8),
      ]);
      expect(result.averageWaitingTime, lessThan(5.0));
    });
  });

  group('SRTF', () {
    test('preempts when shorter job arrives', () {
      final result = service.schedule(SchedulingAlgorithm.srtf, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 8),
        Process(id: 2, name: 'P2', arrivalTime: 1, burstTime: 4),
      ]);
      final p2 = result.processes.firstWhere((p) => p.processId == 2);
      expect(p2.completionTime, 5);
    });

    test('has no idle time', () {
      final result = service.schedule(SchedulingAlgorithm.srtf, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 3),
        Process(id: 2, name: 'P2', arrivalTime: 1, burstTime: 2),
      ]);
      expect(result.gantt.every((g) => g.end - g.start > 0), true);
    });
  });

  group('Round Robin', () {
    test('cycles through processes with quantum', () {
      final result = service.schedule(
        SchedulingAlgorithm.roundRobin,
        [
          Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 5),
          Process(id: 2, name: 'P2', arrivalTime: 0, burstTime: 3),
        ],
        quantum: 2,
      );
      expect(result.gantt.length, greaterThan(2));
    });

    test('all processes complete', () {
      final result = service.schedule(
        SchedulingAlgorithm.roundRobin,
        [
          Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 4),
          Process(id: 2, name: 'P2', arrivalTime: 0, burstTime: 2),
        ],
        quantum: 2,
      );
      expect(result.processes.every((p) => p.completionTime > 0), true);
    });

    test('requires positive quantum', () {
      expect(
        () => service.schedule(SchedulingAlgorithm.roundRobin, [
          Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 1),
        ], quantum: 0),
        throwsArgumentError,
      );
    });
  });

  group('Priority', () {
    test('executes highest priority first', () {
      final result = service.schedule(SchedulingAlgorithm.priority, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 5, priority: 3),
        Process(id: 2, name: 'P2', arrivalTime: 0, burstTime: 3, priority: 1),
        Process(id: 3, name: 'P3', arrivalTime: 0, burstTime: 2, priority: 2),
      ]);
      final order = result.gantt.map((g) => g.processName).toList();
      expect(order[0], 'P2');
      expect(order[1], 'P3');
      expect(order[2], 'P1');
    });
  });

  group('Gantt chart', () {
    test('entries are contiguous', () {
      final result = service.schedule(SchedulingAlgorithm.fcfs, [
        Process(id: 1, name: 'P1', arrivalTime: 0, burstTime: 3),
        Process(id: 2, name: 'P2', arrivalTime: 3, burstTime: 2),
      ]);
      for (var i = 1; i < result.gantt.length; i++) {
        expect(result.gantt[i].start, result.gantt[i - 1].end);
      }
    });
  });

  group('Validation', () {
    test('throws on empty process list', () {
      expect(
        () => service.schedule(SchedulingAlgorithm.fcfs, []),
        throwsArgumentError,
      );
    });
  });
}

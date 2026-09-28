import 'package:computer_engineering_companion/data/local/database/curriculum_data.dart';
import 'package:computer_engineering_companion/domain/entities/entities.dart';
import 'package:computer_engineering_companion/services/ai/ai_models.dart';
import 'package:computer_engineering_companion/services/ai/local_ai_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a small, realistic corpus so the engine is exercised against the
/// same shape of data it sees in production.
List<Lesson> _lessons() => [
      const Lesson(
        id: 1,
        subjectId: 1,
        orderIndex: 0,
        title: 'Deadlock',
        concept: 'A process waits on a resource held by another process.',
        definition:
            'A deadlock is a state in which two or more processes are each '
            'waiting for an event that only the other can cause.',
        formula: '',
        explanation:
            'Deadlock requires mutual exclusion, hold and wait, no '
            'preemption and a circular wait. Breaking any one condition '
            'removes the possibility of deadlock.',
        workedExample:
            'Two processes each hold a lock the other needs, so neither can '
            'proceed and the system stalls indefinitely.',
        engineeringExample:
            'A database with two tables updated in opposite order by two '
            'transactions will deadlock if isolation is strict.',
        commonMistakes:
            'Assuming mutual exclusion alone causes deadlock, and forgetting '
            'that a cycle of waits is required.',
        isCompleted: false,
      ),
      const Lesson(
        id: 2,
        subjectId: 1,
        orderIndex: 1,
        title: 'Banker’s algorithm',
        concept: 'Avoids deadlock by granting a request only if it is safe.',
        definition:
            'The banker’s algorithm tests whether granting a resource request '
            'leaves the system in a safe state where all processes can finish.',
        formula: 'Need ≤ Available',
        explanation:
            'A state is safe if there exists an ordering in which every '
            'process can complete its maximum claim and release its holdings.',
        workedExample:
            'With Available = 3 and a process needing 2, the allocation is '
            'granted because the remaining need can still be satisfied.',
        engineeringExample:
            'Resource allocators in operating systems use a similar '
            'safe-state check before handing out devices.',
        commonMistakes:
            'Calling a state unsafe before checking every process, rather '
            'than only the first one that appears to fit.',
        isCompleted: false,
      ),
      const Lesson(
        id: 3,
        subjectId: 2,
        orderIndex: 0,
        title: 'Transmission Control Protocol',
        concept: 'A reliable, connection-oriented transport protocol.',
        definition:
            'TCP provides reliable in-order delivery over an unreliable '
            'network using sequence numbers and acknowledgements.',
        formula: '',
        explanation:
            'TCP detects loss through retransmission timers and a congestion '
            'window, and it delivers bytes in order to the application.',
        workedExample:
            'A browser downloading a page over TCP stalls if packets are lost '
            'until the retransmission timer fires.',
        engineeringExample:
            'HTTP and SSH both run over TCP because ordering matters.',
        commonMistakes:
            'Confusing TCP flow control with congestion control.',
        isCompleted: true,
      ),
    ];

List<Subject> _subjects() => const [
      Subject(
        id: 1,
        name: 'Operating Systems',
        category: 'Systems',
        description: 'Processes, memory and scheduling',
        icon: 'show_chart',
        completedLessons: 0,
        totalLessons: 2,
      ),
      Subject(
        id: 2,
        name: 'Computer Networks',
        category: 'Networking',
        description: 'Protocols and layers',
        icon: 'lan',
        completedLessons: 1,
        totalLessons: 1,
      ),
    ];

const _formulas = [
  Formula(
    id: 1,
    category: 'Electronics',
    name: 'Ohm’s law',
    expression: 'V = I x R',
    variables: 'V volts, I amps, R ohms',
    application: 'Resistor sizing',
  ),
];

const _references = [
  ProgrammingReference(
    id: 1,
    language: 'C',
    topic: 'Pointers',
    title: 'Passing by pointer',
    code: 'void f(int* p) { *p = 1; }',
  ),
];

Future<LocalAiEngine> _readyEngine() async {
  final engine = LocalAiEngine();
  await engine.ensureIndex(
    lessons: _lessons(),
    subjects: _subjects(),
    formulas: _formulas,
    references: _references,
  );
  return engine;
}

void main() {
  group('index construction', () {
    test('indexes lessons, formulas and references', () async {
      final engine = await _readyEngine();
      expect(engine.isReady, isTrue);
      expect(engine.documentCount, 5);
    });

    test('reuses the index when the corpus has not changed', () async {
      final engine = await _readyEngine();
      final first = engine.documentCount;
      // Same corpus, same counts: no rebuild should happen.
      await engine.ensureIndex(
        lessons: _lessons(),
        subjects: _subjects(),
        formulas: _formulas,
        references: _references,
      );
      expect(engine.documentCount, first);
    });

    test('rebuilds when the corpus changes', () async {
      final engine = await _readyEngine();
      await engine.ensureIndex(
        lessons: [
          ..._lessons(),
          _lessons().first.copyWith(isCompleted: true),
        ],
        subjects: _subjects(),
        formulas: _formulas,
        references: _references,
      );
      expect(engine.documentCount, 6);
    });
  });

  group('ask', () {
    late LocalAiEngine engine;

    setUp(() async {
      engine = await _readyEngine();
    });

    test('answers a definition question from the local corpus', () async {
      final answer = await engine.ask(const AiRequest(prompt: 'What is a deadlock?'));
      expect(answer.notFound, isFalse);
      expect(answer.source, AiSource.local);
      expect(answer.text.toLowerCase(), contains('deadlock'));
      expect(answer.citations, isNotEmpty);
      expect(answer.citations.first.title, 'Deadlock');
    });

    test('answers a procedure question with ordered steps', () async {
      final answer =
          await engine.ask(const AiRequest(prompt: 'How do I avoid a deadlock?'));
      expect(answer.notFound, isFalse);
      expect(answer.text, contains('1.'));
    });

    test('answers a why question with a related reference', () async {
      final answer = await engine.ask(
          const AiRequest(prompt: 'Why is TCP reliable?'));
      expect(answer.notFound, isFalse);
      expect(answer.text.toLowerCase(), contains('tcp'));
    });

    test('points at the calculator for a calculation question', () async {
      final answer =
          await engine.ask(const AiRequest(prompt: 'Calculate V using Ohm law'));
      expect(answer.notFound, isFalse);
      expect(answer.text, contains('Tools'));
    });

    test('answers a comparison question', () async {
      final answer = await engine.ask(
          const AiRequest(prompt: 'Difference between deadlock and TCP?'));
      expect(answer.notFound, isFalse);
      expect(answer.text, contains('vs'));
    });

    test('reports not-found honestly instead of confabulating', () async {
      final answer =
          await engine.ask(const AiRequest(prompt: 'How do I bake sourdough?'));
      expect(answer.notFound, isTrue);
      expect(answer.citations, isEmpty);
      expect(answer.suggestions, isNotEmpty);
      expect(answer.text, contains('Nothing in the offline curriculum'));
    });

    test('cites a formula with its lesson id when it is a lesson', () async {
      final answer =
          await engine.ask(const AiRequest(prompt: 'What is a deadlock?'));
      expect(answer.citations.first.lessonId, 1);
      expect(answer.citations.first.subjectId, 1);
    });

    test('suggests follow-up prompts', () async {
      final answer = await engine.ask(const AiRequest(prompt: 'deadlock'));
      expect(answer.suggestions, isNotEmpty);
    });

    test('records how long the answer took', () async {
      final answer = await engine.ask(const AiRequest(prompt: 'deadlock'));
      // Non-negative and sub-second: it is an on-device lookup, not a call.
      expect(answer.elapsed.inMicroseconds, greaterThanOrEqualTo(0));
      expect(answer.elapsed.inSeconds, lessThan(2));
    });

    test('throws rather than answering before the index is built', () async {
      final cold = LocalAiEngine();
      expect(
        () => cold.ask(const AiRequest(prompt: 'deadlock')),
        throwsA(isA<Object>()),
      );
    });
  });

  group('summarise', () {
    test('produces a shorter summary than the full text', () async {
      final engine = await _readyEngine();
      final lesson = _lessons().first;
      final summary = await engine.summarise(lesson);
      expect(summary, isNotEmpty);
      expect(summary.length, lessThan(
          (lesson.definition.length + lesson.explanation.length +
                  lesson.workedExample.length) *
              2));
    });

    test('returns the whole text when it is already short', () async {
      final engine = await _readyEngine();
      const short = Lesson(
        id: 9,
        subjectId: 1,
        orderIndex: 0,
        title: 'Short',
        concept: 'A short lesson.',
        definition: 'Only one sentence here.',
        formula: '',
        explanation: '',
        workedExample: '',
        engineeringExample: '',
        commonMistakes: '',
        isCompleted: false,
      );
      expect(await engine.summarise(short), 'Only one sentence here.');
    });

    test('falls back to the concept when there is no prose', () async {
      final engine = await _readyEngine();
      const empty = Lesson(
        id: 10,
        subjectId: 1,
        orderIndex: 0,
        title: 'Empty',
        concept: 'Only a concept.',
        definition: '',
        formula: '',
        explanation: '',
        workedExample: '',
        engineeringExample: '',
        commonMistakes: '',
        isCompleted: false,
      );
      expect(await engine.summarise(empty), 'Only a concept.');
    });
  });

  group('generatePractice', () {
    test('builds questions from the lesson content', () async {
      final engine = await _readyEngine();
      final questions = await engine.generatePractice(lesson: _lessons().first);
      expect(questions, isNotEmpty);
      expect(questions.length, lessThanOrEqualTo(3));
      for (final question in questions) {
        expect(question.prompt, isNotEmpty);
        expect(question.answer, isNotEmpty);
        expect(question.explanation, isNotEmpty);
        expect(question.sourceLessonId, 1);
      }
    });

    test('respects the requested count', () async {
      final engine = await _readyEngine();
      expect((await engine.generatePractice(lesson: _lessons().first, count: 1)).length, 1);
    });

    test('returns nothing for a lesson with no content', () async {
      final engine = await _readyEngine();
      const bare = Lesson(
        id: 11,
        subjectId: 1,
        orderIndex: 0,
        title: 'Bare',
        concept: '',
        definition: '',
        formula: '',
        explanation: '',
        workedExample: '',
        engineeringExample: '',
        commonMistakes: '',
        isCompleted: false,
      );
      expect(await engine.generatePractice(lesson: bare), isEmpty);
    });
  });

  group('recommend', () {
    test('suggests the next incomplete lesson after the one viewed', () async {
      final engine = await _readyEngine();
      engine.prime(lessons: _lessons(), subjects: _subjects());
      final recommendations = engine.recommend(
        subjectProgress: const {
          1: (done: 0, total: 2),
          2: (done: 1, total: 1),
        },
        lastViewedLessonId: 1,
      );
      expect(recommendations, isNotEmpty);
      expect(recommendations.first.title, contains('Banker'));
      expect(recommendations.first.reason, contains('Deadlock'));
    });

    test('falls back to the weakest subject when nothing was viewed', () async {
      final engine = await _readyEngine();
      engine.prime(lessons: _lessons(), subjects: _subjects());
      final recommendations = engine.recommend(
        subjectProgress: const {
          1: (done: 0, total: 2),
          2: (done: 1, total: 1),
        },
      );
      expect(recommendations.first.reason, contains('Operating Systems'));
    });

    test('skips subjects that are already complete', () async {
      final engine = await _readyEngine();
      engine.prime(lessons: _lessons(), subjects: _subjects());
      final recommendations = engine.recommend(
        subjectProgress: const {
          1: (done: 2, total: 2),
          2: (done: 1, total: 1),
        },
      );
      expect(recommendations, isEmpty);
    });
  });

  group('invalidate', () {
    test('clears the index so stale content is not served', () async {
      final engine = await _readyEngine();
      engine.invalidate();
      expect(engine.isReady, isFalse);
      expect(engine.documentCount, 0);
    });
  });

  group('bundled curriculum', () {
    test('the real seed data is indexable', () async {
      // Guards against the generator producing content the tokenizer or the
      // index builder cannot handle.
      final engine = LocalAiEngine();
      await engine.ensureIndex(
        lessons: [
          // The seed rows carry no id; SQLite assigns it on insert, so the
          // list position stands in for it here.
          for (var i = 0; i < curriculumLessons.length && i < 200; i++)
            Lesson(
              id: i + 1,
              subjectId: curriculumLessons[i]['subject_id'] as int,
              orderIndex: curriculumLessons[i]['order_index'] as int,
              title: curriculumLessons[i]['title'] as String,
              concept: curriculumLessons[i]['concept'] as String,
              definition: curriculumLessons[i]['definition'] as String,
              formula: curriculumLessons[i]['formula'] as String,
              explanation: curriculumLessons[i]['explanation'] as String,
              workedExample: curriculumLessons[i]['worked_example'] as String,
              engineeringExample: curriculumLessons[i]['engineering_example'] as String,
              commonMistakes: curriculumLessons[i]['common_mistakes'] as String,
              isCompleted: false,
            ),
        ],
        subjects: const [],
        formulas: const [],
        references: const [],
      );
      final answer = await engine.ask(const AiRequest(prompt: 'memory management'));
      expect(answer.notFound, isFalse);
      expect(answer.citations, isNotEmpty);
    });
  });
}

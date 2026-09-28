import 'package:computer_engineering_companion/domain/entities/entities.dart';
import 'package:computer_engineering_companion/domain/services/progress_service.dart';
import 'package:flutter_test/flutter_test.dart';

const _service = ProgressService();

Subject _subject(int id, {int done = 0, int total = 10}) => Subject(
      id: id,
      name: 'Subject $id',
      category: 'Systems',
      description: '',
      icon: 'memory',
      completedLessons: done,
      totalLessons: total,
    );

Lesson _lesson(int id, int subjectId, {bool completed = false}) => Lesson(
      id: id,
      subjectId: subjectId,
      orderIndex: id,
      title: 'Lesson $id',
      concept: '',
      definition: '',
      formula: '',
      explanation: '',
      workedExample: '',
      engineeringExample: '',
      commonMistakes: '',
      isCompleted: completed,
    );

QuizAttempt _attempt(int id, int subjectId, double score) => QuizAttempt(
      id: id,
      subjectId: subjectId,
      score: score,
      correctAnswers: 1,
      totalQuestions: 1,
      elapsedSeconds: 10,
      quizMode: 'quick',
      completedAt: DateTime(2026, 1, 1),
    );

StudySession _session(DateTime when, {int minutes = 1}) => StudySession(
      id: when.millisecondsSinceEpoch,
      subjectId: 1,
      durationMinutes: minutes,
      createdAt: when,
    );

void main() {
  group('computeStats', () {
    test('counts lessons across every subject', () {
      final stats = _service.computeStats(
        subjects: [_subject(1), _subject(2)],
        allLessons: [
          _lesson(1, 1, completed: true),
          _lesson(2, 1),
          _lesson(3, 2, completed: true),
          _lesson(4, 2, completed: true),
        ],
        attempts: const [],
        sessions: const [],
      );
      expect(stats.totalLessons, 4);
      expect(stats.lessonsCompleted, 3);
      expect(stats.overallProgress, 0.75);
    });

    test('averages quiz accuracy', () {
      final stats = _service.computeStats(
        subjects: [_subject(1)],
        allLessons: [_lesson(1, 1)],
        attempts: [_attempt(1, 1, 80), _attempt(2, 1, 60)],
        sessions: const [],
      );
      expect(stats.quizzesCompleted, 2);
      expect(stats.quizAccuracy, 70);
    });

    test('an empty history does not divide by zero', () {
      final stats = _service.computeStats(
        subjects: const [],
        allLessons: const [],
        attempts: const [],
        sessions: const [],
      );
      expect(stats.overallProgress, 0);
      expect(stats.quizAccuracy, 0);
      expect(stats.studyStreakDays, 0);
      expect(stats.totalStudyMinutes, 0);
    });

    test('sums study minutes', () {
      final stats = _service.computeStats(
        subjects: [_subject(1)],
        allLessons: [_lesson(1, 1)],
        attempts: const [],
        sessions: [
          _session(DateTime(2026, 3, 1), minutes: 30),
          _session(DateTime(2026, 3, 2), minutes: 45),
        ],
      );
      expect(stats.totalStudyMinutes, 75);
    });

    test('a subject at 75% or more counts as strong', () {
      final stats = _service.computeStats(
        subjects: [_subject(1, done: 8, total: 10)],
        allLessons: [
          for (var i = 0; i < 8; i++) _lesson(i, 1, completed: true),
          _lesson(100, 1),
          _lesson(101, 1),
        ],
        attempts: const [],
        sessions: const [],
      );
      expect(stats.strongSubjects, contains('Subject 1'));
      expect(stats.needsReviewSubjects, isNot(contains('Subject 1')));
    });

    test('a subject under 50% counts as needing review', () {
      final stats = _service.computeStats(
        subjects: [_subject(1, done: 2, total: 10)],
        allLessons: [
          for (var i = 0; i < 2; i++) _lesson(i, 1, completed: true),
          for (var i = 0; i < 8; i++) _lesson(100 + i, 1),
        ],
        attempts: const [],
        sessions: const [],
      );
      expect(stats.needsReviewSubjects, contains('Subject 1'));
    });

    test('a low quiz average flags a subject even when lessons are done', () {
      final stats = _service.computeStats(
        subjects: [_subject(1, done: 6, total: 10)],
        allLessons: [
          for (var i = 0; i < 6; i++) _lesson(i, 1, completed: true),
          for (var i = 0; i < 4; i++) _lesson(100 + i, 1),
        ],
        attempts: [_attempt(1, 1, 40)],
        sessions: const [],
      );
      expect(stats.needsReviewSubjects, contains('Subject 1'));
    });

    test('a strong subject with good scores is not flagged for review', () {
      final stats = _service.computeStats(
        subjects: [_subject(1, done: 9, total: 10)],
        allLessons: [
          for (var i = 0; i < 9; i++) _lesson(i, 1, completed: true),
          _lesson(100, 1),
        ],
        attempts: [_attempt(1, 1, 90)],
        sessions: const [],
      );
      expect(stats.needsReviewSubjects, isEmpty);
      expect(stats.strongSubjects, contains('Subject 1'));
    });
  });

  group('computeStreak', () {
    // A single fixed time of day, so the fixtures differ by exactly whole
    // days rather than by the microseconds between successive `now` reads.
    final wall = DateTime.now();
    final now = DateTime(wall.year, wall.month, wall.day, 14, 30);
    DateTime day(int offset) => now.subtract(Duration(days: offset));

    test('an empty history has no streak', () {
      expect(_service.computeStreak(const []), 0);
    });

    test('a single day is a streak of one', () {
      expect(_service.computeStreak([day(0)]), 1);
    });

    test('consecutive days count up', () {
      expect(_service.computeStreak([day(0), day(1), day(2)]), 3);
    });

    test('a gap breaks the streak', () {
      expect(_service.computeStreak([day(0), day(1), day(3), day(4)]), 2);
    });

    test('a streak that ended yesterday is still alive', () {
      // Being one day behind must not read as zero every morning.
      expect(_service.computeStreak([day(1), day(2), day(3)]), 3);
    });

    test('a streak that ended long ago is zero', () {
      expect(_service.computeStreak([day(5), day(6), day(7)]), 0);
    });

    test('only the most recent run is counted', () {
      expect(_service.computeStreak([day(0), day(1), day(5), day(6)]), 2);
    });
  });

  group('computeStatsFromDays', () {
    test('accepts pre-reduced study days', () {
      final stats = _service.computeStatsFromDays(
        subjects: [_subject(1, done: 1, total: 2)],
        allLessons: [
          _lesson(1, 1, completed: true),
          _lesson(2, 1),
        ],
        attempts: const [],
        totalStudyMinutes: 90,
        studyDays: [
          DateTime.now(),
          DateTime.now().subtract(const Duration(days: 1)),
        ],
      );
      expect(stats.studyStreakDays, 2);
      expect(stats.totalStudyMinutes, 90);
      expect(stats.lessonsCompleted, 1);
    });

    test('matches computeStats for the same input', () {
      final subjects = [_subject(1, done: 3, total: 4)];
      final lessons = [
        _lesson(1, 1, completed: true),
        _lesson(2, 1, completed: true),
        _lesson(3, 1, completed: true),
        _lesson(4, 1),
      ];
      final attempts = [_attempt(1, 1, 75)];
      final sessions = [
        _session(DateTime.now()),
        _session(DateTime.now().subtract(const Duration(days: 1))),
      ];

      final viaSessions = _service.computeStats(
        subjects: subjects,
        allLessons: lessons,
        attempts: attempts,
        sessions: sessions,
      );
      final viaDays = _service.computeStatsFromDays(
        subjects: subjects,
        allLessons: lessons,
        attempts: attempts,
        totalStudyMinutes: 2,
        studyDays: [
          DateTime.now(),
          DateTime.now().subtract(const Duration(days: 1)),
        ],
      );

      expect(viaDays.lessonsCompleted, viaSessions.lessonsCompleted);
      expect(viaDays.totalLessons, viaSessions.totalLessons);
      expect(viaDays.quizAccuracy, viaSessions.quizAccuracy);
      expect(viaDays.studyStreakDays, viaSessions.studyStreakDays);
      expect(viaDays.totalStudyMinutes, viaSessions.totalStudyMinutes);
      expect(viaDays.strongSubjects, viaSessions.strongSubjects);
      expect(viaDays.needsReviewSubjects, viaSessions.needsReviewSubjects);
    });
  });

  group('scale', () {
    test('handles the real curriculum size without excessive work', () {
      // 15 subjects and 340 lessons is the production shape; the previous
      // implementation did 15 full passes over the lesson list here.
      final subjects = [for (var i = 0; i < 15; i++) _subject(i + 1)];
      final lessons = <Lesson>[];
      for (var subjectId = 1; subjectId <= 15; subjectId++) {
        for (var i = 0; i < 23; i++) {
          lessons.add(_lesson(lessons.length + 1, subjectId,
              completed: i.isEven));
        }
      }
      final attempts = [
        for (var i = 0; i < 200; i++) _attempt(i, (i % 15) + 1, 60 + (i % 40).toDouble()),
      ];

      final stopwatch = Stopwatch()..start();
      final stats = _service.computeStats(
        subjects: subjects,
        allLessons: lessons,
        attempts: attempts,
        sessions: [
          for (var i = 0; i < 500; i++)
            _session(DateTime.now().subtract(Duration(days: i % 30))),
        ],
      );
      stopwatch.stop();

      expect(stats.totalLessons, 345);
      expect(stats.quizzesCompleted, 200);
      // Generous bound: the point is that it is not quadratic.
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });
  });
}

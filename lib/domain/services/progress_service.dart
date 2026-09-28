import '../../domain/entities/entities.dart';

/// Per-subject breakdown backing the progress screen.
class SubjectProgress {
  const SubjectProgress({
    required this.subject,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.quizzesTaken,
    required this.averageScore,
  });

  final Subject subject;
  final int lessonsCompleted, totalLessons, quizzesTaken;
  final double averageScore;

  double get lessonProgress =>
      totalLessons == 0 ? 0 : lessonsCompleted / totalLessons;
}

/// Derives the progress dashboard from local data.
///
/// Single pass over each collection. The previous implementation scanned all
/// 340 lessons once per subject (15 × 340 = 5 100 comparisons) plus the same
/// again per quiz attempt, on every progress recompute — which happened
/// after every completed lesson and every finished quiz, while the user sat
/// on that screen.
class ProgressService {
  const ProgressService();

  ProgressStats computeStats({
    required List<Subject> subjects,
    required List<Lesson> allLessons,
    required List<QuizAttempt> attempts,
    required List<StudySession> sessions,
  }) {
    return computeStatsFromDays(
      subjects: subjects,
      allLessons: allLessons,
      attempts: attempts,
      totalStudyMinutes: sessions.fold(0, (sum, s) => sum + s.durationMinutes),
      studyDays: sessions
          .map((s) => DateTime(
              s.createdAt.year, s.createdAt.month, s.createdAt.day))
          .toSet()
          .toList(),
    );
  }

  /// Preferred entry point: the caller supplies the distinct study days
  /// already reduced in SQL, so no `DateTime` list needs building or sorting
  /// on the UI isolate.
  ///
  /// [studyDays] must be sorted newest first.
  ProgressStats computeStatsFromDays({
    required List<Subject> subjects,
    required List<Lesson> allLessons,
    required List<QuizAttempt> attempts,
    required int totalStudyMinutes,
    required List<DateTime> studyDays,
  }) {
    final lessonsBySubject = <int, ({int done, int total})>{};
    var completed = 0;
    for (final lesson in allLessons) {
      final entry = lessonsBySubject.putIfAbsent(lesson.subjectId, () => (done: 0, total: 0));
      if (lesson.isCompleted) {
        completed++;
        lessonsBySubject[lesson.subjectId] = (done: entry.done + 1, total: entry.total + 1);
      } else {
        lessonsBySubject[lesson.subjectId] = (done: entry.done, total: entry.total + 1);
      }
    }

    final attemptsBySubject = <int, ({int count, double total})>{};
    var accuracyTotal = 0.0;
    for (final attempt in attempts) {
      accuracyTotal += attempt.score;
      final entry = attemptsBySubject.putIfAbsent(attempt.subjectId, () => (count: 0, total: 0.0));
      attemptsBySubject[attempt.subjectId] =
          (count: entry.count + 1, total: entry.total + attempt.score);
    }

    final strong = <String>[];
    final review = <String>[];

    for (final subject in subjects) {
      final lessons = lessonsBySubject[subject.id] ?? (done: 0, total: 0);
      final quiz = attemptsBySubject[subject.id] ?? (count: 0, total: 0.0);
      if (lessons.total == 0) continue;

      final lessonProgress = lessons.done / lessons.total;
      final averageScore = quiz.count == 0 ? 0.0 : quiz.total / quiz.count;

      if (lessonProgress >= 0.75) strong.add(subject.name);

      // Flagged if the subject is barely started *or* the quiz scores show
      // trouble — either alone is a reason to go back over it.
      final barelyStarted = lessonProgress < 0.5;
      final struggling = quiz.count > 0 && averageScore < 70;
      if (barelyStarted || struggling) review.add(subject.name);
    }

    return ProgressStats(
      lessonsCompleted: completed,
      totalLessons: allLessons.length,
      quizzesCompleted: attempts.length,
      quizAccuracy: attempts.isEmpty ? 0.0 : accuracyTotal / attempts.length,
      studyStreakDays: computeStreak(studyDays),
      totalStudyMinutes: totalStudyMinutes,
      strongSubjects: strong,
      needsReviewSubjects: review,
    );
  }

  /// Counts consecutive study days ending today or yesterday.
  ///
  /// A streak is still alive if the user studied yesterday but not yet today,
  /// so an unbroken run is not reported as zero every morning.
  int computeStreak(List<DateTime> sortedDescendingDays) {
    if (sortedDescendingDays.isEmpty) return 0;

    // Normalise to midnight before comparing. Differences between raw
    // timestamps truncate: a session at 23:59 and one at 00:01 the next
    // morning are a full calendar day apart, but a raw duration between them
    // is only minutes and would report a gap.
    final days = [for (final day in sortedDescendingDays) _day(day)]
      ..sort((a, b) => b.compareTo(a));

    final today = _day(DateTime.now());
    if (today.difference(days.first).inDays > 1) return 0;

    var streak = 1;
    for (var i = 1; i < days.length; i++) {
      if (days[i - 1].difference(days[i]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

import '../../domain/entities/entities.dart';

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

class ProgressService {
  const ProgressService();

  ProgressStats computeStats({
    required List<Subject> subjects,
    required List<Lesson> allLessons,
    required List<QuizAttempt> attempts,
    required List<StudySession> sessions,
  }) {
    final totalLessons = allLessons.length;
    final completed = allLessons.where((l) => l.isCompleted).length;
    final totalMinutes =
        sessions.fold(0, (sum, s) => sum + s.durationMinutes);
    final accuracy = attempts.isEmpty
        ? 0.0
        : attempts.fold(0.0, (sum, a) => sum + a.score) / attempts.length;

    final subjectProgress = subjects.map((subject) {
      final subjectLessons =
          allLessons.where((l) => l.subjectId == subject.id).toList();
      final done = subjectLessons.where((l) => l.isCompleted).length;
      final subjectAttempts =
          attempts.where((a) => a.subjectId == subject.id).toList();
      final avg = subjectAttempts.isEmpty
          ? 0.0
          : subjectAttempts.fold(0.0, (s, a) => s + a.score) /
              subjectAttempts.length;
      return SubjectProgress(
        subject: subject,
        lessonsCompleted: done,
        totalLessons: subjectLessons.length,
        quizzesTaken: subjectAttempts.length,
        averageScore: avg,
      );
    }).toList();

    final strong = subjectProgress
        .where((p) => p.totalLessons > 0 && p.lessonProgress >= 0.75)
        .map((p) => p.subject.name)
        .toList();
    final review = subjectProgress
        .where((p) =>
            p.totalLessons > 0 &&
            p.lessonProgress < 0.5 &&
            (p.quizzesTaken == 0 || p.averageScore < 70))
        .map((p) => p.subject.name)
        .toList();

    return ProgressStats(
      lessonsCompleted: completed,
      totalLessons: totalLessons,
      quizzesCompleted: attempts.length,
      quizAccuracy: accuracy,
      studyStreakDays: _computeStreak(sessions),
      totalStudyMinutes: totalMinutes,
      strongSubjects: strong,
      needsReviewSubjects: review,
    );
  }

  int _computeStreak(List<StudySession> sessions) {
    if (sessions.isEmpty) return 0;
    final days = sessions
        .map((s) => DateTime(s.createdAt.year, s.createdAt.month, s.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    var streak = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i - 1].difference(days[i]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}

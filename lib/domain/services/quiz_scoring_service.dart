import '../../domain/entities/entities.dart';

class QuizScoringService {
  const QuizScoringService();

  bool isAnswerCorrect(QuizQuestion question, Set<int> selected) =>
      question.isCorrect(selected);

  int scoreAnswers(List<QuizQuestion> questions, Map<int, Set<int>> answers) {
    var correct = 0;
    for (final question in questions) {
      final selected = answers[question.id];
      if (selected != null && isAnswerCorrect(question, selected)) {
        correct++;
      }
    }
    return correct;
  }

  double accuracy(int correct, int total) =>
      total == 0 ? 0 : (correct / total) * 100;

  String grade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  String feedback(double score) {
    if (score >= 90) return 'Excellent! You have mastered this material.';
    if (score >= 80) return 'Great job! Review the questions you missed.';
    if (score >= 70) return 'Good work. Review the lesson and try again.';
    if (score >= 60) return 'Passing, but more study is recommended.';
    return 'Keep studying. Review the lesson material and retry.';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:computer_engineering_companion/domain/entities/entities.dart';
import 'package:computer_engineering_companion/domain/services/quiz_scoring_service.dart';

void main() {
  const service = QuizScoringService();

  QuizQuestion makeQuestion(int id, Set<int> correct) {
    return QuizQuestion(
      id: id,
      subjectId: 1,
      lessonId: 0,
      prompt: 'Question $id',
      type: 'multiple_choice',
      explanation: 'Explanation $id',
      options: ['A', 'B', 'C', 'D'],
      correctIndexes: correct,
    );
  }

  group('QuizScoringService', () {
    test('correct single answer', () {
      final q = makeQuestion(1, {2});
      expect(service.isAnswerCorrect(q, {2}), true);
      expect(service.isAnswerCorrect(q, {0}), false);
    });

    test('multiple answer requires all correct', () {
      final q = makeQuestion(1, {0, 2});
      expect(service.isAnswerCorrect(q, {0, 2}), true);
      expect(service.isAnswerCorrect(q, {0}), false);
      expect(service.isAnswerCorrect(q, {0, 1}), false);
    });

    test('empty selection is wrong', () {
      final q = makeQuestion(1, {0});
      expect(service.isAnswerCorrect(q, {}), false);
    });

    test('scoreAnswers counts correct', () {
      final questions = [
        makeQuestion(1, {0}),
        makeQuestion(2, {1}),
        makeQuestion(3, {2}),
      ];
      final answers = {
        1: {0},
        2: {1},
        3: {0},
      };
      expect(service.scoreAnswers(questions, answers), 2);
    });

    test('unanswered questions are wrong', () {
      final questions = [
        makeQuestion(1, {0}),
        makeQuestion(2, {1}),
      ];
      final answers = {1: {0}};
      expect(service.scoreAnswers(questions, answers), 1);
    });

    test('accuracy calculation', () {
      expect(service.accuracy(3, 4), 75.0);
      expect(service.accuracy(0, 0), 0.0);
    });

    test('grades', () {
      expect(service.grade(95), 'A');
      expect(service.grade(85), 'B');
      expect(service.grade(75), 'C');
      expect(service.grade(65), 'D');
      expect(service.grade(50), 'F');
    });

    test('feedback messages', () {
      expect(service.feedback(95), contains('Excellent'));
      expect(service.feedback(50), contains('Keep studying'));
    });
  });
}

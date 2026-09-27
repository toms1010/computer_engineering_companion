import 'package:flutter/material.dart';

class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.completedLessons,
    required this.totalLessons,
  });

  final int id;
  final String name, category, description, icon;
  final int completedLessons, totalLessons;

  double get progress =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;

  bool get isComplete => totalLessons > 0 && completedLessons >= totalLessons;

  IconData get iconData => iconMap[icon] ?? Icons.school_outlined;

  static const iconMap = <String, IconData>{
    'code': Icons.code,
    'memory': Icons.memory,
    'dns': Icons.dns_outlined,
    'lan': Icons.lan_outlined,
    'account_tree': Icons.account_tree_outlined,
    'bolt': Icons.bolt_outlined,
    'developer_board': Icons.developer_board_outlined,
    'settings_input_antenna': Icons.settings_input_antenna_outlined,
    'show_chart': Icons.show_chart_outlined,
    'functions': Icons.functions_outlined,
    'calculate': Icons.calculate_outlined,
    'science': Icons.science_outlined,
    'terminal': Icons.terminal_outlined,
    'router': Icons.router_outlined,
    'memory_alt': Icons.memory_outlined,
    'smart_toy': Icons.smart_toy_outlined,
  };

  Subject copyWith({int? completedLessons}) => Subject(
        id: id,
        name: name,
        category: category,
        description: description,
        icon: icon,
        completedLessons: completedLessons ?? this.completedLessons,
        totalLessons: totalLessons,
      );

  factory Subject.fromMap(Map<String, Object?> m) => Subject(
        id: m['id'] as int,
        name: m['name'] as String,
        category: m['category'] as String,
        description: m['description'] as String,
        icon: m['icon'] as String,
        completedLessons: m['completed_lessons'] as int? ?? 0,
        totalLessons: m['total_lessons'] as int? ?? 0,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'icon': icon,
        'completed_lessons': completedLessons,
        'total_lessons': totalLessons,
      };
}

class Lesson {
  const Lesson({
    required this.id,
    required this.subjectId,
    required this.orderIndex,
    required this.title,
    required this.concept,
    required this.definition,
    required this.formula,
    required this.explanation,
    required this.workedExample,
    required this.engineeringExample,
    required this.commonMistakes,
    required this.isCompleted,
  });

  final int id, subjectId, orderIndex;
  final String title, concept, definition, formula, explanation;
  final String workedExample, engineeringExample, commonMistakes;
  final bool isCompleted;

  Lesson copyWith({bool? isCompleted}) => Lesson(
        id: id,
        subjectId: subjectId,
        orderIndex: orderIndex,
        title: title,
        concept: concept,
        definition: definition,
        formula: formula,
        explanation: explanation,
        workedExample: workedExample,
        engineeringExample: engineeringExample,
        commonMistakes: commonMistakes,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  factory Lesson.fromMap(Map<String, Object?> m) => Lesson(
        id: m['id'] as int,
        subjectId: m['subject_id'] as int,
        orderIndex: m['order_index'] as int,
        title: m['title'] as String,
        concept: m['concept'] as String,
        definition: m['definition'] as String,
        formula: m['formula'] as String,
        explanation: m['explanation'] as String,
        workedExample: m['worked_example'] as String,
        engineeringExample: m['engineering_example'] as String,
        commonMistakes: m['common_mistakes'] as String,
        isCompleted: (m['is_completed'] as int? ?? 0) == 1,
      );
}

class Topic {
  const Topic({
    required this.id,
    required this.lessonId,
    required this.orderIndex,
    required this.title,
    required this.content,
  });

  final int id, lessonId, orderIndex;
  final String title, content;

  factory Topic.fromMap(Map<String, Object?> m) => Topic(
        id: m['id'] as int,
        lessonId: m['lesson_id'] as int,
        orderIndex: m['order_index'] as int,
        title: m['title'] as String,
        content: m['content'] as String,
      );
}

enum QuizType {
  multipleChoice('multiple_choice'),
  trueFalse('true_false'),
  multipleAnswer('multiple_answer'),
  codeOutput('code_output'),
  formula('formula'),
  calculation('calculation'),
  numberConversion('number_conversion');

  const QuizType(this.label);
  final String label;

  static QuizType fromLabel(String label) =>
      QuizType.values.firstWhere((t) => t.label == label,
          orElse: () => QuizType.multipleChoice);
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.subjectId,
    required this.lessonId,
    required this.prompt,
    required this.type,
    required this.explanation,
    required this.options,
    required this.correctIndexes,
  });

  final int id, subjectId, lessonId;
  final String prompt, type, explanation;
  final List<String> options;
  final Set<int> correctIndexes;

  QuizType get quizType => QuizType.fromLabel(type);

  bool isCorrect(Set<int> selected) =>
      selected.length == correctIndexes.length &&
      selected.containsAll(correctIndexes);

  factory QuizQuestion.fromMap(Map<String, Object?> m, List<String> options) =>
      QuizQuestion(
        id: m['id'] as int,
        subjectId: m['subject_id'] as int,
        lessonId: m['lesson_id'] as int? ?? 0,
        prompt: m['question'] as String,
        type: m['type'] as String,
        explanation: m['explanation'] as String,
        options: options,
        correctIndexes: (m['correct_answers'] as String)
            .split(',')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => int.parse(s.trim()))
            .toSet(),
      );
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.subjectId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.elapsedSeconds,
    required this.quizMode,
    required this.completedAt,
  });

  final int id, subjectId, correctAnswers, totalQuestions, elapsedSeconds;
  final double score;
  final String quizMode;
  final DateTime completedAt;

  factory QuizAttempt.fromMap(Map<String, Object?> m) => QuizAttempt(
        id: m['id'] as int,
        subjectId: m['subject_id'] as int? ?? 0,
        score: (m['score'] as num).toDouble(),
        correctAnswers: m['correct_answers'] as int,
        totalQuestions: m['total_questions'] as int,
        elapsedSeconds: m['elapsed_seconds'] as int? ?? 0,
        quizMode: m['quiz_mode'] as String,
        completedAt: DateTime.parse(m['completed_at'] as String),
      );
}

class QuizAnswer {
  const QuizAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selectedAnswers,
    required this.isCorrect,
  });

  final int id, attemptId, questionId;
  final Set<int> selectedAnswers;
  final bool isCorrect;

  factory QuizAnswer.fromMap(Map<String, Object?> m) => QuizAnswer(
        id: m['id'] as int,
        attemptId: m['attempt_id'] as int,
        questionId: m['question_id'] as int,
        selectedAnswers: (m['selected_answers'] as String)
            .split(',')
            .where((s) => s.trim().isNotEmpty)
            .map((s) => int.parse(s.trim()))
            .toSet(),
        isCorrect: (m['is_correct'] as int? ?? 0) == 1,
      );
}

class ActivityItem {
  const ActivityItem(this.id, this.description, this.createdAt);
  final int id;
  final String description;
  final DateTime createdAt;
}

class Note {
  const Note({
    this.id,
    required this.title,
    required this.content,
    this.subjectId,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id, subjectId;
  final String title, content;
  final DateTime createdAt, updatedAt;

  factory Note.fromMap(Map<String, Object?> m) => Note(
        id: m['id'] as int?,
        title: m['title'] as String,
        content: m['content'] as String,
        subjectId: m['subject_id'] as int?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );
}

class Bookmark {
  const Bookmark({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.label,
    required this.createdAt,
  });

  final int id, itemId;
  final String itemType, label;
  final DateTime createdAt;

  String get key => '$itemType:$itemId';

  factory Bookmark.fromMap(Map<String, Object?> m) => Bookmark(
        id: m['id'] as int,
        itemType: m['item_type'] as String,
        itemId: m['item_id'] as int,
        label: m['label'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

class StudySession {
  const StudySession({
    required this.id,
    required this.subjectId,
    required this.durationMinutes,
    required this.createdAt,
  });

  final int id, subjectId, durationMinutes;
  final DateTime createdAt;

  factory StudySession.fromMap(Map<String, Object?> m) => StudySession(
        id: m['id'] as int,
        subjectId: m['subject_id'] as int? ?? 0,
        durationMinutes: m['duration_minutes'] as int,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}

class ProgrammingReference {
  const ProgrammingReference({
    required this.id,
    required this.language,
    required this.topic,
    required this.title,
    required this.code,
  });

  final int id;
  final String language, topic, title, code;

  factory ProgrammingReference.fromMap(Map<String, Object?> m) =>
      ProgrammingReference(
        id: m['id'] as int,
        language: m['language'] as String,
        topic: m['topic'] as String,
        title: m['title'] as String,
        code: m['code'] as String,
      );
}

class Formula {
  const Formula({
    required this.id,
    required this.category,
    required this.name,
    required this.expression,
    required this.variables,
    required this.application,
  });

  final int id;
  final String category, name, expression, variables, application;

  factory Formula.fromMap(Map<String, Object?> m) => Formula(
        id: m['id'] as int,
        category: m['category'] as String,
        name: m['name'] as String,
        expression: m['expression'] as String,
        variables: m['variables'] as String? ?? '',
        application: m['application'] as String? ?? '',
      );
}

class ProgressStats {
  const ProgressStats({
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.quizzesCompleted,
    required this.quizAccuracy,
    required this.studyStreakDays,
    required this.totalStudyMinutes,
    required this.strongSubjects,
    required this.needsReviewSubjects,
  });

  final int lessonsCompleted, totalLessons, quizzesCompleted;
  final double quizAccuracy;
  final int studyStreakDays, totalStudyMinutes;
  final List<String> strongSubjects, needsReviewSubjects;

  double get overallProgress =>
      totalLessons == 0 ? 0 : lessonsCompleted / totalLessons;
}

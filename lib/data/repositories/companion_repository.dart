import 'package:sqflite/sqflite.dart';
import '../local/database/app_database.dart';
import '../../domain/entities/entities.dart';

class CompanionRepository {
  Database? _database;

  Future<Database> get db async => _database ??= await AppDatabase.instance.database;

  Future<void> initialize() async {
    await db;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<List<Subject>> loadSubjects() async {
    final database = await db;
    final rows = await database.query('subjects', orderBy: 'id');
    final subjects = rows.map(Subject.fromMap).toList();
    if (subjects.isEmpty) return subjects;
    final lessonCounts = await _lessonCounts(database);
    return [
      for (final s in subjects)
        Subject(
          id: s.id,
          name: s.name,
          category: s.category,
          description: s.description,
          icon: s.icon,
          completedLessons: lessonCounts[s.id]?['done'] ?? 0,
          totalLessons: lessonCounts[s.id]?['total'] ?? 0,
        )
    ];
  }

  Future<Map<int, Map<String, int>>> _lessonCounts(Database database) async {
    final rows = await database.rawQuery(
        'SELECT subject_id, COUNT(*) as total, SUM(is_completed) as done FROM lessons GROUP BY subject_id');
    return {
      for (final r in rows)
        r['subject_id'] as int: {
          'total': r['total'] as int,
          'done': r['done'] as int? ?? 0,
        }
    };
  }

  Future<List<Lesson>> loadLessons(int subjectId) async {
    final database = await db;
    final rows = await database.query('lessons',
        where: 'subject_id = ?', whereArgs: [subjectId], orderBy: 'order_index');
    return rows.map(Lesson.fromMap).toList();
  }

  Future<Lesson?> loadLesson(int lessonId) async {
    final database = await db;
    final rows = await database
        .query('lessons', where: 'id = ?', whereArgs: [lessonId]);
    if (rows.isEmpty) return null;
    return Lesson.fromMap(rows.first);
  }

  Future<List<Topic>> loadTopics(int lessonId) async {
    final database = await db;
    final rows = await database.query('topics',
        where: 'lesson_id = ?', whereArgs: [lessonId], orderBy: 'order_index');
    return rows.map(Topic.fromMap).toList();
  }

  Future<void> completeLesson(int lessonId) async {
    final database = await db;
    await database.update('lessons', {'is_completed': 1},
        where: 'id = ?', whereArgs: [lessonId]);
    final lesson = await loadLesson(lessonId);
    if (lesson != null) {
      await _activity('Completed lesson: ${lesson.title}');
      await database.insert('study_sessions', {
        'subject_id': lesson.subjectId,
        'duration_minutes': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> uncompleteLesson(int lessonId) async {
    final database = await db;
    await database.update('lessons', {'is_completed': 0},
        where: 'id = ?', whereArgs: [lessonId]);
  }

  Future<List<QuizQuestion>> loadQuestions({int? subjectId, int? lessonId}) async {
    final database = await db;
    final where = <String>[];
    final args = <Object>[];
    if (subjectId != null) {
      where.add('subject_id = ?');
      args.add(subjectId);
    }
    if (lessonId != null) {
      where.add('lesson_id = ?');
      args.add(lessonId);
    }
    final rows = await database.query('quiz_questions',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'id');
    final questions = <QuizQuestion>[];
    for (final row in rows) {
      final options = await database.query('quiz_options',
          where: 'question_id = ?', whereArgs: [row['id']], orderBy: 'id');
      questions.add(QuizQuestion.fromMap(
        row,
        options.map((o) => o['option_text'] as String).toList(),
      ));
    }
    return questions;
  }

  Future<int> saveQuizAttempt({
    required int subjectId,
    required int correct,
    required int total,
    required int elapsedSeconds,
    required String quizMode,
    required Map<int, Set<int>> answers,
    required List<QuizQuestion> questions,
  }) async {
    final database = await db;
    final now = DateTime.now();
    final attemptId = await database.insert('quiz_attempts', {
      'subject_id': subjectId,
      'score': total == 0 ? 0.0 : correct / total * 100.0,
      'correct_answers': correct,
      'total_questions': total,
      'elapsed_seconds': elapsedSeconds,
      'quiz_mode': quizMode,
      'completed_at': now.toIso8601String(),
    });
    for (final entry in answers.entries) {
      final question = questions.firstWhere((q) => q.id == entry.key);
      await database.insert('quiz_answers', {
        'attempt_id': attemptId,
        'question_id': entry.key,
        'selected_answers': entry.value.join(','),
        'is_correct': question.isCorrect(entry.value) ? 1 : 0,
      });
    }
    await _activity(
        'Completed quiz: $correct / $total correct ($quizMode)');
    return attemptId;
  }

  Future<List<QuizAttempt>> loadQuizAttempts() async {
    final database = await db;
    final rows = await database
        .query('quiz_attempts', orderBy: 'completed_at DESC');
    return rows.map(QuizAttempt.fromMap).toList();
  }

  Future<List<QuizAnswer>> loadQuizAnswers(int attemptId) async {
    final database = await db;
    final rows = await database
        .query('quiz_answers', where: 'attempt_id = ?', whereArgs: [attemptId]);
    return rows.map(QuizAnswer.fromMap).toList();
  }

  Future<List<ActivityItem>> loadActivities() async {
    final database = await db;
    final rows = await database
        .query('recent_activity', orderBy: 'created_at DESC', limit: 50);
    return rows
        .map((r) => ActivityItem(
            r['id'] as int,
            r['description'] as String,
            DateTime.parse(r['created_at'] as String)))
        .toList();
  }

  Future<void> _activity(String description) async {
    final database = await db;
    await database.insert('recent_activity', {
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Note>> loadNotes() async {
    final database = await db;
    final rows = await database.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<void> saveNote(Note note) async {
    final database = await db;
    final now = DateTime.now();
    if (note.id == null) {
      await database.insert('notes', {
        'title': note.title,
        'content': note.content,
        'subject_id': note.subjectId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
    } else {
      await database.update(
          'notes',
          {
            'title': note.title,
            'content': note.content,
            'subject_id': note.subjectId,
            'updated_at': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [note.id]);
    }
  }

  Future<void> deleteNote(int id) async {
    final database = await db;
    await database.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Bookmark>> loadBookmarks() async {
    final database = await db;
    final rows = await database.query('bookmarks', orderBy: 'created_at DESC');
    return rows.map(Bookmark.fromMap).toList();
  }

  Future<bool> isBookmarked(String itemType, int itemId) async {
    final database = await db;
    final rows = await database.query('bookmarks',
        where: 'item_type = ? AND item_id = ?', whereArgs: [itemType, itemId]);
    return rows.isNotEmpty;
  }

  Future<void> toggleBookmark(String itemType, int itemId, String label) async {
    final database = await db;
    final rows = await database.query('bookmarks',
        where: 'item_type = ? AND item_id = ?', whereArgs: [itemType, itemId]);
    if (rows.isEmpty) {
      await database.insert('bookmarks', {
        'item_type': itemType,
        'item_id': itemId,
        'label': label,
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      await database.delete('bookmarks',
          where: 'item_type = ? AND item_id = ?', whereArgs: [itemType, itemId]);
    }
  }

  Future<List<StudySession>> loadStudySessions() async {
    final database = await db;
    final rows = await database.query('study_sessions', orderBy: 'created_at DESC');
    return rows.map(StudySession.fromMap).toList();
  }

  Future<List<ProgrammingReference>> loadReferences({String? language}) async {
    final database = await db;
    final rows = await database.query('programming_references',
        where: language == null ? null : 'language = ?',
        whereArgs: language == null ? null : [language],
        orderBy: 'language, topic');
    return rows.map(ProgrammingReference.fromMap).toList();
  }

  Future<List<Formula>> loadFormulas({String? category}) async {
    final database = await db;
    final rows = await database.query('formulas',
        where: category == null ? null : 'category = ?',
        whereArgs: category == null ? null : [category],
        orderBy: 'category, name');
    return rows.map(Formula.fromMap).toList();
  }

  Future<void> resetAll() async {
    await AppDatabase.instance.reset();
  }
}

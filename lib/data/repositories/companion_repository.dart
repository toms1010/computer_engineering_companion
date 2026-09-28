import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/error_reporter.dart';
import '../../domain/entities/entities.dart';
import '../../services/performance/performance_logger.dart';
import '../../services/performance/performance_metrics.dart';
import '../local/database/app_database.dart';
import '../local/sync/sync_queue.dart';

/// The single data source for the application.
///
/// Everything the UI reads goes through here, which keeps SQL out of the
/// widget layer and gives one place to enforce the offline-first rules:
///
///  * reads come from SQLite first and always, so the app is fully usable
///    with no network;
///  * every read is instrumented, so a slow query is attributable;
///  * every local mutation is written to the sync queue in the same
///    transaction, so a change can never be persisted but not queued.
class CompanionRepository {
  CompanionRepository();

  Database? _database;
  Future<Database>? _opening;

  /// Reference content (formulas, code snippets) is bundled and immutable
  /// for the life of a database version, so it is read once and served from
  /// memory. The old code re-read 39 rows on every rebuild of every screen.
  List<Formula>? _formulaCache;
  List<ProgrammingReference>? _referenceCache;

  final SyncQueue _syncQueue = SyncQueue.instance;

  Future<Database> get db {
    final existing = _database;
    if (existing != null) return Future.value(existing);
    return _opening ??= _open();
  }

  Future<Database> _open() async {
    final database = await AppDatabase.instance.database;
    _database = database;
    return database;
  }

  /// Warms the database without blocking the first frame. The UI does not
  /// need to await this; providers will queue behind the same open call.
  Future<void> initialize() => guard(() => db, operation: 'db_initialize');

  Future<void> close() async {
    _formulaCache = null;
    _referenceCache = null;
    await _database?.close();
    _database = null;
  }

  /// Clears the in-memory caches after a reset or a migration.
  void invalidateCaches() {
    _formulaCache = null;
    _referenceCache = null;
  }

  // -----------------------------------------------------------------------
  // Instrumentation
  // -----------------------------------------------------------------------

  Future<T> _timed<T>(String label, Future<T> Function(Database db) action) {
    final trace =
        PerformanceLogger.instance.start('DB $label', PerfCategory.database);
    return guard(
      () async {
        final database = await db;
        try {
          return await action(database);
        } finally {
          trace.stop();
        }
      },
      operation: 'db_$label',
    );
  }

  // -----------------------------------------------------------------------
  // Curriculum
  // -----------------------------------------------------------------------

  Future<List<Subject>> loadSubjects() => _timed('loadSubjects', (db) async {
        final rows = await db.query('subjects', orderBy: 'id');
        // Completion counts come from one aggregate instead of 15 per-subject
        // queries. `lessons.subject_id` is indexed, so this is a single pass.
        final countRows = await db.rawQuery('''
          SELECT subject_id,
                 COUNT(*) AS total,
                 SUM(is_completed) AS done
          FROM lessons
          GROUP BY subject_id
        ''');
        final counts = <int, ({int total, int done})>{
          for (final r in countRows)
            r['subject_id'] as int: (
              total: r['total'] as int,
              done: r['done'] as int? ?? 0,
            ),
        };
        return [
          for (final row in rows)
            () {
              final subject = Subject.fromMap(row);
              final count = counts[subject.id];
              return count == null
                  ? subject
                  : subject.copyWith(
                      completedLessons: count.done,
                      totalLessons: count.total,
                    );
            }(),
        ];
      });

  /// A single query for every lesson, grouped by subject.
  ///
  /// Replaces the previous pattern of 15 sequential `loadLessons` calls,
  /// which the progress screen ran on every invalidation.
  Future<Map<int, List<Lesson>>> loadAllLessonsGrouped() =>
      _timed('loadAllLessonsGrouped', (db) async {
        final rows = await db.query('lessons', orderBy: 'subject_id, order_index');
        final grouped = <int, List<Lesson>>{};
        for (final row in rows) {
          grouped.putIfAbsent(row['subject_id'] as int, () => []).add(Lesson.fromMap(row));
        }
        return grouped;
      });

  /// Every lesson in one query, used by the assistant's index build.
  Future<List<Lesson>> loadAllLessons() => _timed('loadAllLessons', (db) async {
        final rows = await db.query('lessons', orderBy: 'subject_id, order_index');
        return rows.map(Lesson.fromMap).toList(growable: false);
      });

  Future<List<Lesson>> loadLessons(int subjectId) =>
      _timed('loadLessons', (db) async {
        final rows = await db.query('lessons',
            where: 'subject_id = ?',
            whereArgs: [subjectId],
            orderBy: 'order_index');
        return rows.map(Lesson.fromMap).toList(growable: false);
      });

  Future<Lesson?> loadLesson(int lessonId) => _timed('loadLesson', (db) async {
        final rows = await db
            .query('lessons', where: 'id = ?', whereArgs: [lessonId], limit: 1);
        if (rows.isEmpty) return null;
        return Lesson.fromMap(rows.first);
      });

  Future<List<Topic>> loadTopics(int lessonId) => _timed('loadTopics', (db) async {
        final rows = await db.query('topics',
            where: 'lesson_id = ?', whereArgs: [lessonId], orderBy: 'order_index');
        return rows.map(Topic.fromMap).toList(growable: false);
      });

  /// Searches lesson text. Uses `LIKE` with a leading wildcard, which cannot
  /// use an index, but the corpus is 340 lessons held locally — measured in
  /// single-digit milliseconds — and it keeps search working offline without
  /// a separate index to maintain.
  Future<List<Lesson>> searchLessons(String query, {int limit = 40}) =>
      _timed('searchLessons', (db) async {
        final term = '%${_escapeLike(query.trim())}%';
        final rows = await db.query(
          'lessons',
          where: 'title LIKE ? ESCAPE \'\\\' '
              'OR concept LIKE ? ESCAPE \'\\\' '
              'OR definition LIKE ? ESCAPE \'\\\' '
              'OR explanation LIKE ? ESCAPE \'\\\'',
          whereArgs: [term, term, term, term],
          orderBy: 'title',
          limit: limit,
        );
        return rows.map(Lesson.fromMap).toList(growable: false);
      });

  // -----------------------------------------------------------------------
  // Lesson completion
  // -----------------------------------------------------------------------

  /// Marks a lesson complete (or not) and records the accompanying study
  /// session, activity entry and sync-queue item in one transaction.
  Future<void> setLessonCompleted(int lessonId, bool completed) =>
      _timed('setLessonCompleted', (db) async {
        await db.transaction((txn) async {
          await txn.update('lessons', {'is_completed': completed ? 1 : 0},
              where: 'id = ?', whereArgs: [lessonId]);

          if (completed) {
            final rows = await txn
                .query('lessons', where: 'id = ?', whereArgs: [lessonId], limit: 1);
            if (rows.isEmpty) return;
            final lesson = Lesson.fromMap(rows.first);
            final now = DateTime.now().toIso8601String();
            await txn.insert('study_sessions', {
              'subject_id': lesson.subjectId,
              'duration_minutes': 1,
              'created_at': now,
            });
            await txn.insert('recent_activity', {
              'description': 'Completed lesson: ${lesson.title}',
              'created_at': now,
            });
            await _syncQueue.enqueue(
              txn,
              entityType: SyncEntity.lesson,
              entityId: lessonId.toString(),
              operation: SyncOperation.upsert,
              payload: {'is_completed': true},
            );
          }
        });
      });

  // -----------------------------------------------------------------------
  // Quiz
  // -----------------------------------------------------------------------

  /// Loads questions with their options in two queries.
  ///
  /// The previous implementation issued one `quiz_options` query per
  /// question: 666 queries and 2 660 rows for a full-bank load. The options
  /// are fetched in a single `IN` query and stitched back together in
  /// memory.
  Future<List<QuizQuestion>> loadQuestions({int? subjectId, int? lessonId}) =>
      _timed('loadQuestions', (db) async {
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
        final questionRows = await db.query(
          'quiz_questions',
          where: where.isEmpty ? null : where.join(' AND '),
          whereArgs: args.isEmpty ? null : args,
          orderBy: 'id',
        );
        if (questionRows.isEmpty) return const [];

        final ids = questionRows.map((r) => r['id'] as int).toList(growable: false);
        final optionRows = await db.query(
          'quiz_options',
          where: 'question_id IN (${List.filled(ids.length, '?').join(',')})',
          whereArgs: ids,
          orderBy: 'question_id, id',
        );
        final optionsByQuestion = <int, List<String>>{};
        for (final row in optionRows) {
          optionsByQuestion
              .putIfAbsent(row['question_id'] as int, () => [])
              .add(row['option_text'] as String);
        }
        return [
          for (final row in questionRows)
            QuizQuestion.fromMap(
              row,
              optionsByQuestion[row['id'] as int] ?? const [],
            ),
        ];
      });

  /// Randomly ordered question ids for the same filter, so a quiz can be
  /// assembled in SQL instead of loading and shuffling the whole bank.
  Future<List<QuizQuestion>> loadRandomQuestions({
    int? subjectId,
    int? lessonId,
    required int limit,
  }) =>
      _timed('loadRandomQuestions', (db) async {
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
        final ids = await db.rawQuery(
          'SELECT id FROM quiz_questions '
          '${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')} '} '
          'ORDER BY RANDOM() LIMIT ?',
          [...args, limit],
        );
        if (ids.isEmpty) return const [];
        final idList = ids.map((r) => r['id'] as int).toList(growable: false);
        final rows = await db.query(
          'quiz_questions',
          where: 'id IN (${List.filled(idList.length, '?').join(',')})',
          whereArgs: idList,
        );
        final byId = {for (final r in rows) r['id'] as int: r};
        final optionRows = await db.query(
          'quiz_options',
          where: 'question_id IN (${List.filled(idList.length, '?').join(',')})',
          whereArgs: idList,
          orderBy: 'question_id, id',
        );
        final optionsByQuestion = <int, List<String>>{};
        for (final row in optionRows) {
          optionsByQuestion
              .putIfAbsent(row['question_id'] as int, () => [])
              .add(row['option_text'] as String);
        }
        // Preserve the random order chosen in SQL.
        return [
          for (final id in idList)
            if (byId[id] != null)
              QuizQuestion.fromMap(
                  byId[id]!, optionsByQuestion[id] ?? const []),
        ];
      });

  Future<int> saveQuizAttempt({
    required int subjectId,
    required int correct,
    required int total,
    required int elapsedSeconds,
    required String quizMode,
    required Map<int, Set<int>> answers,
    required List<QuizQuestion> questions,
  }) =>
      _timed('saveQuizAttempt', (db) async {
        final now = DateTime.now();
        final attemptId = await db.transaction<int>((txn) async {
          final id = await txn.insert('quiz_attempts', {
            'subject_id': subjectId,
            'score': total == 0 ? 0.0 : correct / total * 100.0,
            'correct_answers': correct,
            'total_questions': total,
            'elapsed_seconds': elapsedSeconds,
            'quiz_mode': quizMode,
            'completed_at': now.toIso8601String(),
          });

          // Correctness is computed once here rather than per rendered row
          // on the review screen.
          final byId = {for (final q in questions) q.id: q};
          final batch = txn.batch();
          for (final entry in answers.entries) {
            final question = byId[entry.key];
            if (question == null) continue;
            batch.insert('quiz_answers', {
              'attempt_id': id,
              'question_id': entry.key,
              'selected_answers': entry.value.join(','),
              'is_correct': question.isCorrect(entry.value) ? 1 : 0,
            });
          }
          await batch.commit(noResult: true);

          await txn.insert('recent_activity', {
            'description': 'Completed quiz: $correct / $total correct ($quizMode)',
            'created_at': now.toIso8601String(),
          });
          await _syncQueue.enqueue(
            txn,
            entityType: SyncEntity.quizAttempt,
            entityId: id.toString(),
            operation: SyncOperation.upsert,
            payload: {
              'subject_id': subjectId,
              'score': total == 0 ? 0.0 : correct / total * 100.0,
              'correct': correct,
              'total': total,
              'mode': quizMode,
            },
          );
          return id;
        });
        return attemptId;
      });

  Future<List<QuizAttempt>> loadQuizAttempts({int limit = 50}) =>
      _timed('loadQuizAttempts', (db) async {
        final rows = await db.query('quiz_attempts',
            orderBy: 'completed_at DESC', limit: limit);
        return rows.map(QuizAttempt.fromMap).toList(growable: false);
      });

  Future<List<QuizAnswer>> loadQuizAnswers(int attemptId) =>
      _timed('loadQuizAnswers', (db) async {
        final rows = await db.query('quiz_answers',
            where: 'attempt_id = ?', whereArgs: [attemptId]);
        return rows.map(QuizAnswer.fromMap).toList(growable: false);
      });

  /// Loads the full review set for a mistake-review session: every wrongly
  /// answered question on previous attempts, with the user's selection.
  ///
  /// Replaces an N+1 that ran one query per attempt and then reloaded all
  /// 665 questions to look up the prompts.
  Future<List<ReviewEntry>> loadMistakesForReview({int subjectId = 0, int limit = 20}) =>
      _timed('loadMistakesForReview', (db) async {
        final attemptFilter = subjectId == 0 ? '' : 'AND a.subject_id = ?';
        final args = subjectId == 0 ? <Object?>[] : <Object?>[subjectId];
        final rows = await db.rawQuery('''
          SELECT ans.question_id AS question_id,
                 ans.selected_answers AS selected,
                 MIN(ans.id) AS first_seen
          FROM quiz_answers ans
          JOIN quiz_attempts a ON a.id = ans.attempt_id
          WHERE ans.is_correct = 0 $attemptFilter
          GROUP BY ans.question_id
          ORDER BY first_seen DESC
          LIMIT ?
        ''', [...args, limit]);

        if (rows.isEmpty) return const [];
        final ids = rows.map((r) => r['question_id'] as int).toList(growable: false);
        final placeholders = List.filled(ids.length, '?').join(',');
        final questionRows =
            await db.query('quiz_questions', where: 'id IN ($placeholders)', whereArgs: ids);
        final byId = {for (final r in questionRows) r['id'] as int: r};
        final optionRows = await db.rawQuery('''
          SELECT question_id, option_text
          FROM quiz_options
          WHERE question_id IN ($placeholders)
          ORDER BY question_id, id
        ''', ids);
        final optionsByQuestion = <int, List<String>>{};
        for (final row in optionRows) {
          optionsByQuestion
              .putIfAbsent(row['question_id'] as int, () => [])
              .add(row['option_text'] as String);
        }
        return [
          for (final row in rows)
            if (byId[row['question_id'] as int] != null)
              ReviewEntry(
                question: QuizQuestion.fromMap(
                  byId[row['question_id'] as int]!,
                  optionsByQuestion[row['question_id'] as int] ?? const [],
                ),
                selected: _parseIndexes(row['selected'] as String?),
              ),
        ];
      });

  // -----------------------------------------------------------------------
  // Activity, notes, bookmarks
  // -----------------------------------------------------------------------

  Future<List<ActivityItem>> loadActivities({int limit = 20}) =>
      _timed('loadActivities', (db) async {
        final rows = await db.query('recent_activity',
            orderBy: 'created_at DESC', limit: limit);
        return rows
            .map((r) => ActivityItem(
                r['id'] as int,
                r['description'] as String,
                DateTime.tryParse(r['created_at'] as String) ?? DateTime.now()))
            .toList(growable: false);
      });

  Future<List<Note>> loadNotes({int limit = 200}) => _timed('loadNotes', (db) async {
        final rows = await db.query('notes', orderBy: 'updated_at DESC', limit: limit);
        return rows.map(Note.fromMap).toList(growable: false);
      });

  Future<Note?> loadNote(int id) => _timed('loadNote', (db) async {
        final rows = await db.query('notes', where: 'id = ?', whereArgs: [id], limit: 1);
        if (rows.isEmpty) return null;
        return Note.fromMap(rows.first);
      });

  /// Persists a note and returns it with its assigned id, queueing the change
  /// in the same transaction.
  Future<Note> saveNote(Note note) => _timed('saveNote', (db) async {
        final now = DateTime.now().toIso8601String();
        late int id;
        await db.transaction((txn) async {
          if (note.id == null) {
            id = await txn.insert('notes', {
              'title': note.title,
              'content': note.content,
              'subject_id': note.subjectId,
              'created_at': now,
              'updated_at': now,
            });
          } else {
            id = note.id!;
            await txn.update(
              'notes',
              {
                'title': note.title,
                'content': note.content,
                'subject_id': note.subjectId,
                'updated_at': now,
              },
              where: 'id = ?',
              whereArgs: [id],
            );
          }
          await _syncQueue.enqueue(
            txn,
            entityType: SyncEntity.note,
            entityId: id.toString(),
            operation: SyncOperation.upsert,
            payload: {
              'title': note.title,
              'content': note.content,
              'subject_id': note.subjectId,
              'updated_at': now,
            },
          );
        });
        return Note(
          id: id,
          title: note.title,
          content: note.content,
          subjectId: note.subjectId,
          createdAt: note.createdAt,
          updatedAt: DateTime.tryParse(now) ?? DateTime.now(),
        );
      });

  Future<void> deleteNote(int id) => _timed('deleteNote', (db) async {
        await db.transaction((txn) async {
          await txn.delete('notes', where: 'id = ?', whereArgs: [id]);
          await _syncQueue.enqueue(
            txn,
            entityType: SyncEntity.note,
            entityId: id.toString(),
            operation: SyncOperation.delete,
          );
        });
      });

  Future<List<Bookmark>> loadBookmarks() => _timed('loadBookmarks', (db) async {
        final rows = await db.query('bookmarks', orderBy: 'created_at DESC');
        return rows.map(Bookmark.fromMap).toList(growable: false);
      });

  /// Returns the new bookmarked state.
  Future<bool> toggleBookmark(String itemType, int itemId, String label) =>
      _timed('toggleBookmark', (db) async {
        late bool nowBookmarked;
        await db.transaction((txn) async {
          final rows = await txn.query('bookmarks',
              where: 'item_type = ? AND item_id = ?',
              whereArgs: [itemType, itemId],
              limit: 1);
          nowBookmarked = rows.isEmpty;
          if (nowBookmarked) {
            await txn.insert('bookmarks', {
              'item_type': itemType,
              'item_id': itemId,
              'label': label,
              'created_at': DateTime.now().toIso8601String(),
            });
          } else {
            await txn.delete('bookmarks',
                where: 'item_type = ? AND item_id = ?',
                whereArgs: [itemType, itemId]);
          }
          await _syncQueue.enqueue(
            txn,
            entityType: SyncEntity.bookmark,
            entityId: '$itemType:$itemId',
            operation:
                nowBookmarked ? SyncOperation.upsert : SyncOperation.delete,
            payload: {'label': label},
          );
        });
        return nowBookmarked;
      });

  Future<List<StudySession>> loadStudySessions() =>
      _timed('loadStudySessions', (db) async {
        final rows =
            await db.query('study_sessions', orderBy: 'created_at DESC');
        return rows.map(StudySession.fromMap).toList(growable: false);
      });

  /// Distinct study days, computed in SQL.
  ///
  /// The old code materialised a `DateTime` per session, built a set, sorted
  /// it, and walked it on the UI thread — on every progress recompute, with a
  /// session row added per completed lesson and per quiz.
  Future<List<DateTime>> loadStudyDays() => _timed('loadStudyDays', (db) async {
        final rows = await db.rawQuery(
            "SELECT DISTINCT date(created_at) AS day FROM study_sessions "
            "WHERE created_at IS NOT NULL ORDER BY day DESC");
        return [
          for (final row in rows)
            if (DateTime.tryParse(row['day'] as String) != null)
              DateTime.parse(row['day'] as String),
        ];
      });

  // -----------------------------------------------------------------------
  // Reference content
  // -----------------------------------------------------------------------

  Future<List<Formula>> loadFormulas({String? category}) =>
      _timed('loadFormulas', (db) async {
        if (category != null) {
          final rows = await db.query('formulas',
              where: 'category = ?',
              whereArgs: [category],
              orderBy: 'category, name');
          return rows.map(Formula.fromMap).toList(growable: false);
        }
        return _formulaCache ??= await _readAllFormulas(db);
      });

  Future<List<Formula>> _readAllFormulas(Database db) async {
    final rows = await db.query('formulas', orderBy: 'category, name');
    return rows.map(Formula.fromMap).toList(growable: false);
  }

  Future<List<ProgrammingReference>> loadReferences({String? language}) =>
      _timed('loadReferences', (db) async {
        if (language != null) {
          final rows = await db.query('programming_references',
              where: 'language = ?', whereArgs: [language], orderBy: 'topic');
          return rows.map(ProgrammingReference.fromMap).toList(growable: false);
        }
        return _referenceCache ??= await _readAllReferences(db);
      });

  Future<List<ProgrammingReference>> _readAllReferences(Database db) async {
    final rows =
        await db.query('programming_references', orderBy: 'language, topic');
    return rows.map(ProgrammingReference.fromMap).toList(growable: false);
  }

  // -----------------------------------------------------------------------
  // Maintenance
  // -----------------------------------------------------------------------

  /// Wipes user data and re-seeds the curriculum. Explicit user action.
  Future<void> resetAll() async {
    invalidateCaches();
    await AppDatabase.instance.reset();
  }

  /// Row counts per table, used by the diagnostics screen.
  Future<Map<String, int>> tableCounts() => _timed('tableCounts', (db) async {
        final result = <String, int>{};
        for (final table in AppConstants.resettableTables) {
          final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
          result[table] = (rows.first['c'] as int?) ?? 0;
        }
        return result;
      });

  static Set<int> _parseIndexes(String? raw) => (raw ?? '')
      .split(',')
      .where((s) => s.trim().isNotEmpty)
      .map((s) => int.tryParse(s.trim()))
      .whereType<int>()
      .toSet();

  /// Escapes LIKE wildcards so a search for `50%` is a literal search.
  static String _escapeLike(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
}

/// A question the user previously got wrong, with what they chose.
class ReviewEntry {
  const ReviewEntry({required this.question, required this.selected});

  final QuizQuestion question;
  final Set<int> selected;
}

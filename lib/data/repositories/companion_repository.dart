import 'package:sqflite/sqflite.dart';
import '../local/database/app_database.dart';
import '../local/database/database_seed.dart';
import '../../domain/entities/entities.dart';

/// Single data boundary: SQLite is primary; memory is only a platform fallback.
class CompanionRepository {
  Database? _database;
  final _subjects = seededSubjects().map(Subject.fromMap).toList();
  final _activities = <ActivityItem>[];
  final _notes = <Note>[];
  final _bookmarks = <String>{};
  Future<void> initialize() async {
    try {
      _database = await AppDatabase.instance.database;
      _subjects
        ..clear()
        ..addAll(await loadSubjects());
      _activities
        ..clear()
        ..addAll(await loadActivities());
      _notes
        ..clear()
        ..addAll(await loadNotes());
      _bookmarks
        ..clear()
        ..addAll(await loadBookmarks());
    } catch (_) {}
  }

  List<Subject> subjects() => List.of(_subjects);
  List<ActivityItem> activities() => List.of(_activities);
  List<Note> notes() => List.of(_notes.reversed);
  Set<String> bookmarks() => Set.of(_bookmarks);
  Future<List<Subject>> loadSubjects() async => _database == null
      ? List.of(_subjects)
      : (await _database!.query('subjects', orderBy: 'name'))
          .map(Subject.fromMap)
          .toList();
  Future<List<ActivityItem>> loadActivities() async {
    if (_database == null) return List.of(_activities);
    final rows = await _database!
        .query('recent_activity', orderBy: 'created_at DESC', limit: 20);
    return rows
        .map((r) => ActivityItem(r['description'] as String,
            DateTime.parse(r['created_at'] as String)))
        .toList();
  }

  List<QuizQuestion> questions() => seedQuestions
      .map((q) => QuizQuestion(
          id: q['id'] as int,
          subjectId: q['subjectId'] as int,
          prompt: q['prompt'] as String,
          options: List<String>.from(q['options'] as List),
          correctIndexes: Set<int>.from(q['answers'] as List),
          type: q['type'] as String,
          explanation: q['explanation'] as String))
      .toList();
  Future<void> completeLesson(Subject subject) async {
    final completed =
        (subject.completedLessons + 1).clamp(0, subject.totalLessons);
    final index = _subjects.indexWhere((s) => s.id == subject.id);
    _subjects[index] = subject.copyWith(completedLessons: completed);
    final activity =
        ActivityItem('Completed a lesson in ${subject.name}', DateTime.now());
    _activities.insert(0, activity);
    if (_database == null) return;
    await _database!.update('subjects', {'completed_lessons': completed},
        where: 'id = ?', whereArgs: [subject.id]);
    await _activity(activity.description);
  }

  Future<void> saveQuiz({required int correct, required int total}) async {
    final activity = ActivityItem(
        'Completed a quiz: $correct / $total correct', DateTime.now());
    _activities.insert(0, activity);
    if (_database == null) return;
    await _database!.insert('quiz_attempts', {
      'score': total == 0 ? 0 : correct / total * 100,
      'correct_answers': correct,
      'total_questions': total,
      'elapsed_seconds': 0,
      'quiz_mode': 'practice',
      'completed_at': DateTime.now().toIso8601String()
    });
    await _activity(activity.description);
  }

  Future<void> _activity(String description) async =>
      _database!.insert('recent_activity', {
        'description': description,
        'created_at': DateTime.now().toIso8601String()
      });
  Future<List<Note>> loadNotes() async {
    if (_database == null) return List.of(_notes.reversed);
    final rows = await _database!.query('notes', orderBy: 'updated_at DESC');
    return rows
        .map((r) => Note(
            id: r['id'] as int,
            title: r['title'] as String,
            content: r['content'] as String,
            subjectId: r['subject_id'] as int?,
            updatedAt: DateTime.parse(r['updated_at'] as String)))
        .toList();
  }

  Future<void> saveNote(Note note) async {
    final now = DateTime.now();
    _notes.removeWhere((n) => n.id == note.id);
    _notes.add(Note(
        id: note.id ?? now.microsecondsSinceEpoch,
        title: note.title,
        content: note.content,
        subjectId: note.subjectId,
        updatedAt: now));
    if (_database == null) return;
    final values = {
      'title': note.title,
      'content': note.content,
      'subject_id': note.subjectId,
      'updated_at': now.toIso8601String()
    };
    if (note.id == null) {
      await _database!
          .insert('notes', {...values, 'created_at': now.toIso8601String()});
    } else {
      await _database!
          .update('notes', values, where: 'id = ?', whereArgs: [note.id]);
    }
  }

  Future<void> deleteNote(int id) async {
    if (_database == null) {
      _notes.removeWhere((n) => n.id == id);
    } else {
      await _database!.delete('notes', where: 'id = ?', whereArgs: [id]);
    }
  }

  Future<Set<String>> loadBookmarks() async => _database == null
      ? Set.of(_bookmarks)
      : (await _database!.query('bookmarks'))
          .map((r) => r['label'] as String)
          .toSet();
  Future<void> toggleBookmark(String label) async {
    if (_database == null) {
      _bookmarks.contains(label)
          ? _bookmarks.remove(label)
          : _bookmarks.add(label);
      return;
    }
    final rows = await _database!
        .query('bookmarks', where: 'label = ?', whereArgs: [label]);
    if (rows.isEmpty) {
      await _database!.insert('bookmarks', {
        'item_type': 'subject',
        'item_id': 0,
        'label': label,
        'created_at': DateTime.now().toIso8601String()
      });
    } else {
      await _database!
          .delete('bookmarks', where: 'label = ?', whereArgs: [label]);
    }
  }
}

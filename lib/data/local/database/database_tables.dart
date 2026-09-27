class DatabaseTables {
  static const statements = <String>[
    'CREATE TABLE subjects (id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL, description TEXT NOT NULL, icon TEXT NOT NULL, completed_lessons INTEGER NOT NULL DEFAULT 0, total_lessons INTEGER NOT NULL DEFAULT 4)',
    'CREATE TABLE lessons (id INTEGER PRIMARY KEY, subject_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL, is_completed INTEGER NOT NULL DEFAULT 0)',
    'CREATE TABLE topics (id INTEGER PRIMARY KEY, lesson_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT NOT NULL)',
    'CREATE TABLE quiz_questions (id INTEGER PRIMARY KEY, subject_id INTEGER NOT NULL, question TEXT NOT NULL, type TEXT NOT NULL, explanation TEXT NOT NULL)',
    'CREATE TABLE quiz_options (id INTEGER PRIMARY KEY, question_id INTEGER NOT NULL, option_text TEXT NOT NULL, is_correct INTEGER NOT NULL DEFAULT 0)',
    'CREATE TABLE quiz_attempts (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER, score REAL NOT NULL, correct_answers INTEGER NOT NULL, total_questions INTEGER NOT NULL, elapsed_seconds INTEGER NOT NULL, quiz_mode TEXT NOT NULL, completed_at TEXT NOT NULL)',
    'CREATE TABLE quiz_answers (id INTEGER PRIMARY KEY AUTOINCREMENT, attempt_id INTEGER NOT NULL, question_id INTEGER NOT NULL, selected_answers TEXT NOT NULL, is_correct INTEGER NOT NULL)',
    'CREATE TABLE progress (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER NOT NULL, lessons_completed INTEGER NOT NULL DEFAULT 0, quizzes_completed INTEGER NOT NULL DEFAULT 0, accuracy REAL NOT NULL DEFAULT 0)',
    'CREATE TABLE bookmarks (id INTEGER PRIMARY KEY AUTOINCREMENT, item_type TEXT NOT NULL, item_id INTEGER NOT NULL, label TEXT NOT NULL, created_at TEXT NOT NULL)',
    'CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, content TEXT NOT NULL, subject_id INTEGER, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)',
    'CREATE TABLE recent_activity (id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT NOT NULL, created_at TEXT NOT NULL)',
    'CREATE TABLE study_sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, subject_id INTEGER, duration_minutes INTEGER NOT NULL, created_at TEXT NOT NULL)',
    'CREATE TABLE programming_references (id INTEGER PRIMARY KEY AUTOINCREMENT, language TEXT NOT NULL, topic TEXT NOT NULL, title TEXT NOT NULL, code TEXT NOT NULL)',
    'CREATE TABLE formulas (id INTEGER PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, name TEXT NOT NULL, expression TEXT NOT NULL)'
  ];
}

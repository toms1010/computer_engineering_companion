class AppConstants {
  static const appName = 'Computer Engineering Companion';
  static const databaseName = 'engineering_companion.db';
  static const databaseVersion = 3;

  /// Tables cleared by "reset all data" in Settings. Curriculum tables are
  /// immediately re-seeded, so this is a reset, not a wipe.
  static const resettableTables = <String>[
    'quiz_answers',
    'quiz_attempts',
    'quiz_options',
    'quiz_questions',
    'topics',
    'lessons',
    'subjects',
    'progress',
    'bookmarks',
    'notes',
    'recent_activity',
    'study_sessions',
    'programming_references',
    'formulas',
    'sync_queue',
  ];

  static const subjectCategories = [
    'All',
    'Programming',
    'Hardware',
    'Systems',
    'Networking',
    'Electronics',
    'Mathematics',
    'Science',
  ];

  static const formulaCategories = [
    'Mathematics',
    'Physics',
    'Electronics',
    'Digital Logic',
    'Networking',
    'Computer Architecture',
    'Operating Systems',
    'Data Communications',
    'Embedded Systems',
    'Programming',
  ];

  static const programmingLanguages = [
    'C',
    'C++',
    'Python',
    'Java',
    'Dart',
  ];
}

/// Index definitions applied on create and on upgrade.
///
/// Every one of these backs a query the app actually runs. The pre-existing
/// schema had no indexes at all, so `loadLessons`, `loadTopics`,
/// `loadQuestions` and `loadQuizAnswers` were all full table scans, and
/// `loadSubjects` grouped 340 rows on every rebuild.
abstract final class DatabaseIndexes {
  static const statements = <String>[
    // Curriculum lookups: filtered by subject / lesson on every screen.
    'CREATE INDEX IF NOT EXISTS idx_lessons_subject ON lessons(subject_id, order_index)',
    'CREATE INDEX IF NOT EXISTS idx_topics_lesson ON topics(lesson_id, order_index)',

    // Quiz: the heaviest read in the app. A subject or lesson filter ran a
    // scan over 665 rows and then one options query per row.
    'CREATE INDEX IF NOT EXISTS idx_questions_subject ON quiz_questions(subject_id, id)',
    'CREATE INDEX IF NOT EXISTS idx_questions_lesson ON quiz_questions(lesson_id, id)',
    'CREATE INDEX IF NOT EXISTS idx_options_question ON quiz_options(question_id, id)',

    // Attempt history is always read newest-first and capped.
    'CREATE INDEX IF NOT EXISTS idx_attempts_completed ON quiz_attempts(completed_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_answers_attempt ON quiz_answers(attempt_id)',

    // Bookmark lookups are by (type, id) and happen once per visible card.
    'CREATE UNIQUE INDEX IF NOT EXISTS idx_bookmarks_item ON bookmarks(item_type, item_id)',

    'CREATE INDEX IF NOT EXISTS idx_notes_updated ON notes(updated_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_activity_created ON recent_activity(created_at DESC)',
    'CREATE INDEX IF NOT EXISTS idx_sessions_created ON study_sessions(created_at DESC)',

    // Reference content is filtered by these two columns.
    'CREATE INDEX IF NOT EXISTS idx_references_language ON programming_references(language, topic)',
    'CREATE INDEX IF NOT EXISTS idx_formulas_category ON formulas(category, name)',
  ];
}

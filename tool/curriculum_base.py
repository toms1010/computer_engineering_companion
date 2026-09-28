"""Generates lib/data/local/database/curriculum_data.dart with the full
Computer Engineering curriculum: subjects, lessons, topics, quiz questions,
formulas, and programming references."""

import os

LESSONS = []
TOPICS = []
QUIZ_QUESTIONS = []
QUIZ_OPTIONS = []
FORMULAS = []
REFERENCES = []

_QID = [1]
_OID = [1]
CURRENT_SUBJECT = [0]
QUESTION_MARK = [0]


def dart_str(s):
    if isinstance(s, list):
        return '[' + ', '.join(dart_str(x) for x in s) + ']'
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n').replace('$', '\\$') + "'"


def dart_text(v):
    """Flatten list values into a single '; '-joined string for TEXT columns."""
    if isinstance(v, list):
        return dart_str('; '.join(str(x) for x in v))
    return dart_str(v)


def q(prompt, options, answers, explanation='', type_='multiple_choice'):
    qid = _QID[0]
    _QID[0] += 1
    QUIZ_QUESTIONS.append({
        'id': qid,
        'subject_id': 0,
        'lesson_id': 0,
        'question': prompt,
        'type': type_,
        'explanation': explanation,
        'correct_answers': ','.join(str(a) for a in answers),
    })
    for i, opt in enumerate(options):
        QUIZ_OPTIONS.append({
            'question_id': qid,
            'option_text': opt,
            'is_correct': 1 if i in answers else 0,
        })
    return qid


def lesson(subject_id, order, title, concept, definition='', formula='',
           explanation='', worked='', eng='', mistakes='', practice=None,
           quiz=None, topics=None):
    lid = len(LESSONS) + 1
    LESSONS.append({
        'id': lid,
        'subject_id': subject_id,
        'order_index': order,
        'title': title,
        'concept': concept,
        'definition': definition,
        'formula': formula,
        'explanation': explanation,
        'worked_example': worked,
        'engineering_example': eng,
        'common_mistakes': mistakes,
        'practice_questions': practice or [],
        'quiz': quiz or [],
    })
    for i, (t, c) in enumerate(topics or []):
        TOPICS.append({
            'lesson_id': lid,
            'order_index': i,
            'title': t,
            'content': c,
        })
    for _qq in QUIZ_QUESTIONS[QUESTION_MARK[0]:]:
        _qq['subject_id'] = subject_id
        _qq['lesson_id'] = lid
    QUESTION_MARK[0] = len(QUIZ_QUESTIONS)
    return lid


def formula(category, name, expression, variables='', application=''):
    FORMULAS.append({
        'category': category,
        'name': name,
        'expression': expression,
        'variables': variables,
        'application': application,
    })


def reference(language, topic, title, code):
    REFERENCES.append({
        'language': language,
        'topic': topic,
        'title': title,
        'code': code,
    })


SUBJECTS = []


def subject(sid, name, category, description, icon):
    CURRENT_SUBJECT[0] = sid
    SUBJECTS.append({
        'id': sid,
        'name': name,
        'category': category,
        'description': description,
        'icon': icon,
    })




def generate():
    lines = []
    lines.append("library;")
    lines.append("")
    lines.append("/// GENERATED FILE — DO NOT EDIT BY HAND.")
    lines.append("/// Regenerate with: python3 tool/generate_curriculum.py")
    lines.append("import 'package:sqflite/sqflite.dart';")
    lines.append("")
    lines.append("const curriculumSubjects = <Map<String, Object>>[")
    for s in SUBJECTS:
        lines.append("  {'id': %d, 'name': %s, 'category': %s, 'description': %s, 'icon': %s},"
                     % (s['id'], dart_str(s['name']), dart_str(s['category']),
                        dart_str(s['description']), dart_str(s['icon'])))
    lines.append("];")
    lines.append("")
    lines.append("const curriculumLessons = <Map<String, Object>>[")
    for l in LESSONS:
        lines.append("  {")
        lines.append("    'subject_id': %d," % l['subject_id'])
        lines.append("    'order_index': %d," % l['order_index'])
        lines.append("    'title': %s," % dart_text(l['title']))
        lines.append("    'concept': %s," % dart_text(l['concept']))
        lines.append("    'definition': %s," % dart_text(l['definition']))
        lines.append("    'formula': %s," % dart_text(l['formula']))
        lines.append("    'explanation': %s," % dart_text(l['explanation']))
        lines.append("    'worked_example': %s," % dart_text(l['worked_example']))
        lines.append("    'engineering_example': %s," % dart_text(l['engineering_example']))
        lines.append("    'common_mistakes': %s," % dart_text(l['common_mistakes']))
        lines.append("  },")
    lines.append("];")
    lines.append("")
    lines.append("const curriculumTopics = <Map<String, Object>>[")
    for t in TOPICS:
        lines.append("  {'lesson_id': %d, 'order_index': %d, 'title': %s, 'content': %s},"
                     % (t['lesson_id'], t['order_index'], dart_str(t['title']), dart_str(t['content'])))
    lines.append("];")
    lines.append("")
    lines.append("const curriculumQuizQuestions = <Map<String, Object>>[")
    for qq in QUIZ_QUESTIONS:
        lines.append("  {'id': %d, 'subject_id': %d, 'lesson_id': %d, 'question': %s, 'type': %s, 'explanation': %s, 'correct_answers': %s},"
                     % (qq['id'], qq['subject_id'], qq['lesson_id'], dart_str(qq['question']),
                        dart_str(qq['type']), dart_str(qq['explanation']), dart_str(qq['correct_answers'])))
    lines.append("];")
    lines.append("")
    lines.append("const curriculumQuizOptions = <Map<String, Object>>[")
    for qo in QUIZ_OPTIONS:
        lines.append("  {'question_id': %d, 'option_text': %s, 'is_correct': %d},"
                     % (qo['question_id'], dart_str(qo['option_text']), qo['is_correct']))
    lines.append("];")
    lines.append("")
    lines.append("const curriculumFormulas = <Map<String, Object>>[")
    for f in FORMULAS:
        lines.append("  {'category': %s, 'name': %s, 'expression': %s, 'variables': %s, 'application': %s},"
                     % (dart_str(f['category']), dart_str(f['name']), dart_text(f['expression']),
                        dart_text(f['variables']), dart_text(f['application'])))
    lines.append("];")
    lines.append("")
    lines.append("const curriculumProgrammingReferences = <Map<String, Object>>[")
    for r in REFERENCES:
        lines.append("  {'language': %s, 'topic': %s, 'title': %s, 'code': %s},"
                     % (dart_str(r['language']), dart_str(r['topic']), dart_str(r['title']), dart_text(r['code'])))
    lines.append("];")
    lines.append("")
    lines.append("/// Seeds the bundled curriculum in bounded chunks.")
    lines.append("///")
    lines.append("/// A single 3.7k-row batch marshals every row across the platform")
    lines.append("/// channel before any of it is written, which blocks the UI thread for")
    lines.append("/// long enough to drop the first frames. Chunking plus an explicit yield")
    lines.append("/// between chunks keeps the splash animating while the seed runs.")
    lines.append("///")
    lines.append("/// [onProgress] receives a 0..1 value so the UI can show real progress")
    lines.append("/// instead of an indefinite spinner.")
    lines.append("Future<void> seedDatabase(")
    lines.append("  Database db, {")
    lines.append("  void Function(double progress)? onProgress,")
    lines.append("  int chunkSize = 200,")
    lines.append("}) async {")
    lines.append("  const tables = <String, List<Map<String, Object>>>{")
    lines.append("    'subjects': curriculumSubjects,")
    lines.append("    'lessons': curriculumLessons,")
    lines.append("    'topics': curriculumTopics,")
    lines.append("    'quiz_questions': curriculumQuizQuestions,")
    lines.append("    'quiz_options': curriculumQuizOptions,")
    lines.append("    'formulas': curriculumFormulas,")
    lines.append("    'programming_references': curriculumProgrammingReferences,")
    lines.append("  };")
    lines.append("  final total = tables.values.fold<int>(0, (sum, rows) => sum + rows.length);")
    lines.append("  var written = 0;")
    lines.append("  for (final entry in tables.entries) {")
    lines.append("    final rows = entry.value;")
    lines.append("    for (var start = 0; start < rows.length; start += chunkSize) {")
    lines.append("      final end =")
    lines.append("          (start + chunkSize) < rows.length ? start + chunkSize : rows.length;")
    lines.append("      final batch = db.batch();")
    lines.append("      for (final row in rows.sublist(start, end)) {")
    lines.append("        batch.insert(entry.key, row);")
    lines.append("      }")
    lines.append("      await batch.commit(noResult: true);")
    lines.append("      written += end - start;")
    lines.append("      onProgress?.call(total == 0 ? 1 : written / total);")
    lines.append("      // Yield so the event loop can paint between chunks.")
    lines.append("      await Future<void>.delayed(Duration.zero);")
    lines.append("    }")
    lines.append("  }")
    lines.append("}")
    return '\n'.join(lines) + '\n'

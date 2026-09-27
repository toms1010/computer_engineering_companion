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


def dart_str(s):
    if isinstance(s, list):
        return '[' + ', '.join(dart_str(x) for x in s) + ']'
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('\n', '\\n').replace('$', '\\$') + "'"


def q(prompt, options, answers, explanation='', type_='multiple_choice'):
    qid = _QID[0]
    _QID[0] += 1
    QUIZ_QUESTIONS.append({
        'id': qid,
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
    SUBJECTS.append({
        'id': sid,
        'name': name,
        'category': category,
        'description': description,
        'icon': icon,
    })




def generate():
    lines = []
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
        lines.append("    'title': %s," % dart_str(l['title']))
        lines.append("    'concept': %s," % dart_str(l['concept']))
        lines.append("    'definition': %s," % dart_str(l['definition']))
        lines.append("    'formula': %s," % dart_str(l['formula']))
        lines.append("    'explanation': %s," % dart_str(l['explanation']))
        lines.append("    'worked_example': %s," % dart_str(l['worked_example']))
        lines.append("    'engineering_example': %s," % dart_str(l['engineering_example']))
        lines.append("    'common_mistakes': %s," % dart_str(l['common_mistakes']))
        pq = ', '.join(dart_str(p) for p in l['practice_questions'])
        lines.append("    'practice_questions': [%s]," % pq)
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
        lines.append("  {'id': %d, 'question': %s, 'type': %s, 'explanation': %s, 'correct_answers': %s},"
                     % (qq['id'], dart_str(qq['question']), dart_str(qq['type']),
                        dart_str(qq['explanation']), dart_str(qq['correct_answers'])))
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
                     % (dart_str(f['category']), dart_str(f['name']), dart_str(f['expression']),
                        dart_str(f['variables']), dart_str(f['application'])))
    lines.append("];")
    lines.append("")
    lines.append("const curriculumProgrammingReferences = <Map<String, Object>>[")
    for r in REFERENCES:
        lines.append("  {'language': %s, 'topic': %s, 'title': %s, 'code': %s},"
                     % (dart_str(r['language']), dart_str(r['topic']), dart_str(r['title']), dart_str(r['code'])))
    lines.append("];")
    lines.append("")
    lines.append("Future<void> seedDatabase(Database db) async {")
    lines.append("  final batch = db.batch();")
    lines.append("  for (final s in curriculumSubjects) {")
    lines.append("    batch.insert('subjects', s);")
    lines.append("  }")
    lines.append("  for (final l in curriculumLessons) {")
    lines.append("    batch.insert('lessons', l);")
    lines.append("  }")
    lines.append("  for (final t in curriculumTopics) {")
    lines.append("    batch.insert('topics', t);")
    lines.append("  }")
    lines.append("  for (final qq in curriculumQuizQuestions) {")
    lines.append("    batch.insert('quiz_questions', qq);")
    lines.append("  }")
    lines.append("  for (final qo in curriculumQuizOptions) {")
    lines.append("    batch.insert('quiz_options', qo);")
    lines.append("  }")
    lines.append("  for (final f in curriculumFormulas) {")
    lines.append("    batch.insert('formulas', f);")
    lines.append("  }")
    lines.append("  for (final r in curriculumProgrammingReferences) {")
    lines.append("    batch.insert('programming_references', r);")
    lines.append("  }")
    lines.append("  await batch.commit(noResult: true);")
    lines.append("}")
    return '\n'.join(lines) + '\n'

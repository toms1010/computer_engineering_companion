import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/error/app_exception.dart';
import '../../domain/entities/entities.dart';
import '../../domain/services/knowledge_index.dart';
import '../performance/performance_monitor.dart';
import 'ai_models.dart';

/// Answers questions entirely on the device.
///
/// This is not a language model and does not pretend to be one. It is a
/// retrieval-and-composition engine over the bundled curriculum:
///
///  1. retrieve the most relevant passages with a BM25 index;
///  2. classify the intent ("what is", "how do i", "why", "difference");
///  3. compose an answer from the retrieved text, citing the source.
///
/// That makes it fast (no network, no model load, no key), private (nothing
/// leaves the device), and — for a syllabus the user already has installed —
/// more reliably correct than a small general model. It also degrades
/// honestly: when nothing matches it says so rather than confabulating.
class LocalAiEngine {
  LocalAiEngine();

  KnowledgeIndex? _index;
  List<Lesson> _lessons = const [];
  List<Subject> _subjects = const [];
  String? _signature;

  bool get isReady => _index != null;
  int get documentCount => _index?.documentCount ?? 0;

  /// Rebuilds the index if the underlying curriculum changed.
  ///
  /// Cheap when nothing changed: the signature check avoids a rebuild on
  /// every assistant open, which would otherwise re-read the whole corpus.
  Future<KnowledgeIndex> ensureIndex({
    required List<Lesson> lessons,
    required List<Subject> subjects,
    required List<Formula> formulas,
    required List<ProgrammingReference> references,
  }) {
    final signature = '${lessons.length}:${subjects.length}:'
        '${formulas.length}:${references.length}:'
        '${lessons.isEmpty ? 0 : lessons.last.id}';
    if (signature == _signature && _index != null) {
      return Future.value(_index!);
    }
    _lessons = lessons;
    _subjects = subjects;
    _signature = signature;
    return _build(lessons, subjects, formulas, references);
  }

  Future<KnowledgeIndex> _build(
    List<Lesson> lessons,
    List<Subject> subjects,
    List<Formula> formulas,
    List<ProgrammingReference> references,
  ) async {
    final subjectNames = {for (final s in subjects) s.id: s.name};
    final documents = <Map<String, Object?>>[
      for (final lesson in lessons)
        {
          'id': 'lesson:${lesson.id}',
          'type': 'lesson',
          'title': lesson.title,
          'heading': subjectNames[lesson.subjectId] ?? '',
          'subject': subjectNames[lesson.subjectId] ?? '',
          'formula': lesson.formula,
          'body': [
            lesson.concept,
            lesson.definition,
            lesson.explanation,
            lesson.workedExample,
            lesson.engineeringExample,
            lesson.commonMistakes,
          ].where((s) => s.isNotEmpty).join('\n'),
        },
      for (final formula in formulas)
        {
          'id': 'formula:${formula.id}',
          'type': 'formula',
          'title': formula.name,
          'heading': formula.category,
          'subject': formula.category,
          'formula': formula.expression,
          'body': [formula.variables, formula.application]
              .where((s) => s.isNotEmpty)
              .join('\n'),
        },
      for (final reference in references)
        {
          'id': 'reference:${reference.id}',
          'type': 'reference',
          'title': reference.title,
          'heading': reference.topic,
          'subject': reference.language,
          'formula': '',
          'body': reference.code,
        },
    ];

    // Tokenising ~420 documents costs far more than the query itself, so it
    // runs on a background isolate. The UI thread stays free to animate while
    // the index is built.
    final serialised = await compute(KnowledgeIndex.buildIndexInIsolate, documents);
    final index = KnowledgeIndex.deserialize(serialised);
    _index = index;
    return index;
  }

  /// Seeds the engine with the local corpus for the non-`ask` capabilities.
  void prime({
    required List<Lesson> lessons,
    required List<Subject> subjects,
  }) {
    _lessons = lessons;
    _subjects = subjects;
  }

  // ---------------------------------------------------------------------
  // Question answering
  // ---------------------------------------------------------------------

  Future<AiAnswer> ask(AiRequest request) async {
    final trace = PerformanceMonitor.instance.trackAi('local.ask',
        context: {'length': request.prompt.length});
    try {
      final index = _index;
      if (index == null) {
        throw const AiException(
            'The local knowledge index is still being prepared.');
      }
      final hits = index.search(request.prompt, limit: request.maxResults);
      if (hits.isEmpty) {
        return AiAnswer(
          text: _notFoundMessage(request.prompt),
          source: AiSource.local,
          citations: const [],
          elapsed: trace.stop(),
          notFound: true,
          suggestions: _defaultSuggestions(request.prompt),
        );
      }

      final answer = _compose(request.prompt, hits);
      return AiAnswer(
        text: answer.$1,
        source: AiSource.local,
        citations: [
          for (final hit in hits.take(3))
            AiCitation(
              title: hit.document.title,
              snippet: hit.snippet,
              type: hit.document.type,
              lessonId: _lessonIdOf(hit.document),
              subjectId: _subjectIdOf(hit.document),
            ),
        ],
        elapsed: trace.stop(),
        suggestions: _followUps(request.prompt, hits),
      );
    } catch (error, stackTrace) {
      trace.stop(succeeded: false);
      throw AiException(
        'The on-device assistant could not answer that.',
        cause: error,
        context: {'stack': stackTrace.toString().split('\n').first},
      );
    }
  }

  /// Composes an answer from retrieved passages.
  ///
  /// Structured by detected intent so the same corpus reads differently for
  /// "what is X" versus "how do I solve X" versus "why does X happen".
  (String, String) _compose(String prompt, List<KnowledgeHit> hits) {
    final intent = _detectIntent(prompt);
    final primary = hits.first;
    final subject = primary.document.heading;
    final buffer = StringBuffer();

    switch (intent) {
      case _Intent.definition:
        buffer.writeln('**${primary.document.title}** — $subject');
        if (primary.document.formula.isNotEmpty) {
          buffer.writeln(primary.document.formula);
        }
        buffer.writeln();
        buffer.writeln(primary.snippet);
      case _Intent.procedure:
        buffer.writeln('**${primary.document.title}**');
        buffer.writeln();
        buffer.writeln('To work through this:');
        for (var i = 0; i < hits.length && i < 3; i++) {
          buffer.writeln('${i + 1}. ${hits[i].snippet.isEmpty ? hits[i].document.title : hits[i].snippet}');
        }
      case _Intent.reason:
        buffer.writeln('**${primary.document.title}** — $subject');
        buffer.writeln();
        buffer.writeln(primary.snippet);
        if (hits.length > 1) {
          buffer
            ..writeln()
            ..writeln('Related: ${hits[1].document.title} — ${hits[1].snippet}');
        }
      case _Intent.comparison:
        buffer.writeln('**${primary.document.title}** vs '
            '**${hits.length > 1 ? hits[1].document.title : 'related topics'}**');
        buffer.writeln();
        for (final hit in hits.take(2)) {
          buffer.writeln('• ${hit.snippet}');
        }
      case _Intent.calculation:
        buffer.writeln('**${primary.document.title}**');
        if (primary.document.formula.isNotEmpty) {
          buffer
            ..writeln()
            ..writeln('Use: ${primary.document.formula}');
        }
        buffer
          ..writeln()
          ..writeln(primary.snippet);
        buffer.writeln();
        buffer.writeln('Open Tools → the matching calculator to plug in your values.');
      case _Intent.general:
        buffer.writeln('**${primary.document.title}** — $subject');
        buffer.writeln();
        buffer.writeln(primary.snippet);
        for (final hit in hits.skip(1).take(2)) {
          buffer
            ..writeln()
            ..writeln('Also see **${hit.document.title}** — ${hit.snippet}');
        }
    }

    if (hits.any((h) => h.document.type == 'lesson')) {
      buffer
        ..writeln()
        ..write('All of this comes from the on-device curriculum, so it works '
            'with no internet and nothing was sent anywhere.');
    }
    return (buffer.toString().trim(), intent.name);
  }

  _Intent _detectIntent(String prompt) {
    final p = prompt.toLowerCase();
    const definitionCues = [
      'what is', 'what are', 'define', 'meaning of', 'explain what',
      'introduction to', 'about',
    ];
    const procedureCues = [
      'how do i', 'how to', 'steps', 'procedure', 'algorithm for', 'implement',
    ];
    const reasonCues = [
      'why', 'cause', 'because', 'reason', 'what happens',
    ];
    const comparisonCues = [
      'difference between', 'vs', 'versus', 'compare', 'better than',
    ];
    const calculationCues = [
      'calculate', 'compute', 'formula for', 'value of', 'solve for', 'how much',
    ];

    if (comparisonCues.any(p.contains)) return _Intent.comparison;
    if (calculationCues.any(p.contains)) return _Intent.calculation;
    if (definitionCues.any(p.contains)) return _Intent.definition;
    if (procedureCues.any(p.contains)) return _Intent.procedure;
    if (reasonCues.any(p.contains)) return _Intent.reason;
    return _Intent.general;
  }

  String _notFoundMessage(String prompt) {
    return 'Nothing in the offline curriculum matches "$prompt".\n\n'
        'The assistant searches the 340 lessons, 39 formulas and code '
        'reference that ship with the app. Try a core term such as '
        '"scheduling", "TCP", "Ohm law" or "binary tree".';
  }

  List<String> _defaultSuggestions(String prompt) => [
        'What is deadlock?',
        'How do I subnet a class C network?',
        'Why does context switching cost time?',
      ];

  List<String> _followUps(String prompt, List<KnowledgeHit> hits) {
    final suggestions = <String>[];
    for (final hit in hits.take(2)) {
      if (hit.document.type == 'lesson') {
        suggestions.add('Show me a worked example of ${hit.document.title}');
      } else if (hit.document.type == 'formula') {
        suggestions.add('What are the variables in ${hit.document.title}?');
      }
    }
    if (suggestions.length < 2) {
      suggestions.addAll(_defaultSuggestions(prompt).take(2 - suggestions.length));
    }
    return suggestions.take(3).toList();
  }

  int? _lessonIdOf(KnowledgeDocument doc) {
    if (!doc.id.startsWith('lesson:')) return null;
    return int.tryParse(doc.id.substring('lesson:'.length));
  }

  int? _subjectIdOf(KnowledgeDocument doc) {
    if (doc.id.startsWith('lesson:') && _lessons.isNotEmpty) {
      final lessonId = _lessonIdOf(doc);
      for (final lesson in _lessons) {
        if (lesson.id == lessonId) return lesson.subjectId;
      }
    }
    for (var i = 0; i < _subjects.length; i++) {
      if (_subjects[i].name == doc.subject) return _subjects[i].id;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Summaries
  // ---------------------------------------------------------------------

  /// Extractive summary of a lesson: the sentences carrying the most
  /// distinctive terms, in their original order so the prose still reads.
  Future<String> summarise(Lesson lesson, {int maxSentences = 4}) async {
    final trace = PerformanceMonitor.instance.trackAi('local.summarise',
        context: {'lesson': lesson.id});
    final text = [
      lesson.definition,
      lesson.explanation,
      lesson.workedExample,
    ].where((s) => s.trim().isNotEmpty).join(' ').trim();

    if (text.isEmpty) {
      trace.stop();
      return lesson.concept.isEmpty
          ? 'This lesson has no summary text yet.'
          : lesson.concept;
    }

    final sentences = _splitSentences(text);
    if (sentences.length <= maxSentences) {
      trace.stop();
      return text;
    }

    // Term frequency across the lesson, then score each sentence by the
    // sum of the frequencies of its own terms. Classic extractive
    // summarisation: no model, deterministic, and it keeps the author's
    // wording intact.
    final frequency = <String, int>{};
    for (final sentence in sentences) {
      for (final term in KnowledgeIndex.tokenize(sentence)) {
        frequency[term] = (frequency[term] ?? 0) + 1;
      }
    }

    final scored = <(int, double)>[];
    for (var i = 0; i < sentences.length; i++) {
      final terms = KnowledgeIndex.tokenize(sentences[i]);
      if (terms.isEmpty) continue;
      // Normalise by length so a long sentence does not win by containing
      // more words.
      final score = terms.fold<double>(0, (sum, t) => sum + (frequency[t] ?? 0)) /
          math.sqrt(terms.length);
      scored.add((i, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));

    final chosen = scored.take(maxSentences).map((e) => e.$1).toList()..sort();
    trace.stop();
    return chosen.map((i) => sentences[i]).join(' ');
  }

  static List<String> _splitSentences(String text) => text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((s) => s.trim())
      .where((s) => s.length > 24)
      .toList(growable: false);

  // ---------------------------------------------------------------------
  // Recommendations
  // ---------------------------------------------------------------------

  /// What to study next, from local progress only.
  ///
  /// Priority order: the lesson you were last reading, then the first
  /// incomplete lesson in the weakest subject. No network, no profiling.
  List<StudyRecommendation> recommend({
    required Map<int, ({int done, int total})> subjectProgress,
    int? lastViewedLessonId,
    int limit = 4,
  }) {
    final recommendations = <StudyRecommendation>[];

    if (lastViewedLessonId != null) {
      for (var i = 0; i < _lessons.length; i++) {
        final lesson = _lessons[i];
        if (lesson.id != lastViewedLessonId) continue;
        final next = _nextIncompleteLesson(lesson.subjectId, lesson.orderIndex);
        if (next != null) {
          recommendations.add(StudyRecommendation(
            title: next.title,
            reason: 'Next lesson after "${lesson.title}"',
            lessonId: next.id,
            subjectId: next.subjectId,
          ));
        }
        break;
      }
    }

    // Weakest subject first: lowest completion, then fewest lessons done.
    final weak = subjectProgress.entries.toList()
      ..sort((a, b) {
        final aRatio = a.value.total == 0 ? 1.0 : a.value.done / a.value.total;
        final bRatio = b.value.total == 0 ? 1.0 : b.value.done / b.value.total;
        return aRatio.compareTo(bRatio);
      });

    for (final entry in weak) {
      if (recommendations.length >= limit) break;
      if (entry.value.done >= entry.value.total) continue;
      final subject = _subjects.where((s) => s.id == entry.key).firstOrNull;
      if (subject == null) continue;
      final next = _nextIncompleteLesson(entry.key, -1);
      recommendations.add(StudyRecommendation(
        title: next?.title ?? subject.name,
        reason: '${subject.name} is ${entry.value.done} of '
            '${entry.value.total} lessons complete',
        lessonId: next?.id,
        subjectId: entry.key,
      ));
    }
    return recommendations.take(limit).toList();
  }

  Lesson? _nextIncompleteLesson(int subjectId, int afterOrderIndex) {
    final candidates = _lessons
        .where((l) => l.subjectId == subjectId && !l.isCompleted)
        .toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (candidates.isEmpty) return null;
    for (final lesson in candidates) {
      if (lesson.orderIndex > afterOrderIndex) return lesson;
    }
    return candidates.first;
  }

  // ---------------------------------------------------------------------
  // Practice generation
  // ---------------------------------------------------------------------

  /// Builds practice questions from lesson content.
  ///
  /// Generated from the definition, formula and worked example, so every
  /// question is answerable from the installed curriculum and each one
  /// carries an explanation the user can check.
  Future<List<GeneratedQuestion>> generatePractice({
    required Lesson lesson,
    int count = 3,
  }) async {
    final trace = PerformanceMonitor.instance.trackAi('local.practice',
        context: {'lesson': lesson.id});
    final questions = <GeneratedQuestion>[];

    if (lesson.definition.trim().isNotEmpty) {
      questions.add(GeneratedQuestion(
        prompt: 'Define: ${lesson.title}.',
        answer: _firstSentence(lesson.definition),
        explanation: lesson.concept.isEmpty
            ? 'From the lesson on ${lesson.title}.'
            : lesson.concept,
        sourceLessonId: lesson.id,
      ));
    }
    if (lesson.formula.trim().isNotEmpty) {
      questions.add(GeneratedQuestion(
        prompt: 'Which formula applies to ${lesson.title}?',
        answer: lesson.formula,
        explanation: lesson.explanation.isEmpty
            ? 'The formula recorded for ${lesson.title}.'
            : lesson.explanation,
        sourceLessonId: lesson.id,
      ));
    }
    if (lesson.workedExample.trim().isNotEmpty) {
      questions.add(GeneratedQuestion(
        prompt: 'Work through a ${lesson.title} example.',
        answer: _firstSentence(lesson.workedExample),
        explanation: lesson.engineeringExample.isEmpty
            ? 'Worked example from the lesson.'
            : lesson.engineeringExample,
        sourceLessonId: lesson.id,
      ));
    }
    if (lesson.commonMistakes.trim().isNotEmpty && questions.length < count) {
      questions.add(GeneratedQuestion(
        prompt: 'What is the most common mistake with ${lesson.title}?',
        answer: _firstSentence(lesson.commonMistakes),
        explanation: 'Recorded as a common pitfall for this lesson.',
        sourceLessonId: lesson.id,
      ));
    }

    trace.stop();
    // Deterministic count: callers get a predictable number of questions.
    return questions.take(count).toList();
  }

  static String _firstSentence(String text) => _splitSentences(text).firstOrNull ??
      text.trim();

  /// Drops the cached index. Called after a data reset.
  void invalidate() {
    _index = null;
    _signature = null;
    _lessons = const [];
    _subjects = const [];
  }
}

enum _Intent { definition, procedure, reason, comparison, calculation, general }

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

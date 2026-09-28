/// Request and response shapes for the assistant.
///
/// Nothing here mentions a provider. The UI talks to `AiService`, which
/// decides whether an answer comes from the on-device engine or, only if the
/// user has explicitly enabled it, a remote one.
class AiRequest {
  const AiRequest({
    required this.prompt,
    this.subjectId,
    this.lessonId,
    this.maxResults = 5,
  });

  final String prompt;

  /// Optional scope, so "explain this" works without re-typing the topic.
  final int? subjectId, lessonId;

  final int maxResults;

  bool get isEmpty => prompt.trim().isEmpty;
}

/// Where an answer came from. Surfaced in the UI so the user always knows
/// whether their question left the device.
enum AiSource {
  /// On-device retrieval over the bundled curriculum. No network, no data
  /// leaves the phone.
  local,

  /// A user-configured remote model. Only reachable after explicit opt-in.
  remote,
}

/// A cited passage backing an answer.
class AiCitation {
  const AiCitation({
    required this.title,
    required this.snippet,
    required this.type,
    this.lessonId,
    this.subjectId,
  });

  final String title, snippet, type;
  final int? lessonId, subjectId;
}

/// A complete answer.
class AiAnswer {
  const AiAnswer({
    required this.text,
    required this.source,
    required this.citations,
    required this.elapsed,
    this.suggestions = const [],
    this.notFound = false,
  });

  final String text;
  final AiSource source;
  final List<AiCitation> citations;
  final Duration elapsed;

  /// Follow-up prompts, so the user can drill in without rephrasing.
  final List<String> suggestions;

  /// True when nothing in the local corpus matched, so the UI can say so
  /// plainly instead of inventing an answer.
  final bool notFound;
}

/// Structured study advice derived from local progress.
class StudyRecommendation {
  const StudyRecommendation({
    required this.title,
    required this.reason,
    this.lessonId,
    this.subjectId,
  });

  final String title, reason;
  final int? lessonId, subjectId;
}

/// A practice question generated from local lesson content.
class GeneratedQuestion {
  const GeneratedQuestion({
    required this.prompt,
    required this.answer,
    required this.explanation,
    required this.sourceLessonId,
  });

  final String prompt, answer, explanation;
  final int sourceLessonId;
}

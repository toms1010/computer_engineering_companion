import '../../core/error/error_reporter.dart';
import '../../data/repositories/companion_repository.dart';
import '../../domain/entities/entities.dart';
import '../performance/performance_monitor.dart';
import 'ai_models.dart';
import 'local_ai_engine.dart';
import 'remote_ai_engine.dart';

/// The assistant's single entry point.
///
/// Owns the local engine and the optional remote one, and guarantees a
/// usable answer in every state:
///
///  * local index ready            → on-device answer
///  * remote enabled and reachable → remote answer
///  * remote enabled but failing   → silently falls back to on-device
///  * nothing matches              → an explicit "not in the curriculum"
///
/// Callers never need to know which path answered, except to tell the user
/// where the answer came from, which [AiAnswer.source] carries.
class AiService {
  AiService({
    required CompanionRepository repository,
    required LocalAiEngine local,
    required RemoteAiEngine remote,
  })  : _repository = repository,
        _local = local,
        _remote = remote;

  final CompanionRepository _repository;
  final LocalAiEngine _local;
  final RemoteAiEngine _remote;

  bool get isRemoteEnabled => _remote.isEnabled;

  set remoteEnabled(bool value) => _remote.setEnabled(value);

  bool get isIndexReady => _local.isReady;

  int get indexedDocuments => _local.documentCount;

  /// Builds the local index. Cheap and idempotent after the first call, and
  /// runs entirely off the UI thread apart from reading the corpus.
  Future<void> warmUp() async {
    final trace = PerformanceMonitor.instance.trackAi('warmup');
    try {
      final subjects = await _repository.loadSubjects();
      final lessons = await _repository.loadAllLessons();
      final formulas = await _repository.loadFormulas();
      final references = await _repository.loadReferences();
      _local.prime(lessons: lessons, subjects: subjects);
      await _local.ensureIndex(
        lessons: lessons,
        subjects: subjects,
        formulas: formulas,
        references: references,
      );
      trace.stop(extra: {'documents': _local.documentCount});
    } catch (error, stackTrace) {
      trace.stop(succeeded: false);
      throw ErrorReporter.instance.report(error,
          stackTrace: stackTrace, operation: 'ai_warmup');
    }
  }

  /// Answers a question, preferring the on-device engine.
  ///
  /// The remote provider is only consulted when the user has explicitly
  /// enabled it, and a remote failure is never surfaced as a dead end.
  Future<AiAnswer> ask(AiRequest request) {
    if (request.isEmpty) {
      return Future.value(const AiAnswer(
        text: 'Type a question to ask the assistant.',
        source: AiSource.local,
        citations: [],
        elapsed: Duration.zero,
      ));
    }
    return guard(_ask, operation: 'ai_ask', screen: 'assistant');
  }

  Future<AiAnswer> _ask() async {
    // Local first: it is private, instant, and always available.
    if (_local.isReady) {
      final local = await _local.ask(_current);
      if (!local.notFound) return local;
    }

    if (await _remote.isUsable) {
      final remote = await _remote.ask(_current);
      if (remote != null) return remote;
    }

    if (_local.isReady) {
      return _local.ask(_current);
    }

    // Index still building: wait for it rather than erroring out.
    await warmUp();
    return _local.ask(_current);
  }

  /// The request currently being answered. Set by [ask] so the remote engine
  /// can be called without re-plumbing the argument.
  late AiRequest _current = const AiRequest(prompt: '');

  Future<AiAnswer> askWith(AiRequest request) {
    _current = request;
    return ask(request);
  }

  /// Extractive summary of a lesson, produced on-device.
  Future<String> summarise(Lesson lesson) {
    return guard(() => _local.summarise(lesson),
        operation: 'ai_summarise', screen: 'lesson');
  }

  /// Practice questions generated from a lesson's own content.
  Future<List<GeneratedQuestion>> generatePractice(Lesson lesson,
          {int count = 3}) =>
      guard(() => _local.generatePractice(lesson: lesson, count: count),
          operation: 'ai_practice', screen: 'lesson');

  /// Study recommendations from local progress.
  List<StudyRecommendation> recommend({
    required List<Subject> subjects,
    int? lastViewedLessonId,
  }) {
    final progress = {
      for (final subject in subjects)
        subject.id: (done: subject.completedLessons, total: subject.totalLessons),
    };
    return _local.recommend(
      subjectProgress: progress,
      lastViewedLessonId: lastViewedLessonId,
    );
  }

  /// Drops the index. Call after a data reset so stale content is not served.
  void invalidate() => _local.invalidate();
}

import 'log_level.dart';

/// Centralised logging facade.
///
/// Two jobs:
///  * give every log line one consistent, greppable format;
///  * make the volume environment-aware, so development is verbose and
///    production only carries warnings, errors and slow-operation reports.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  /// Keys whose values are never written to the log, in any form.
  static const Set<String> redactedKeys = {
    'password',
    'passwd',
    'secret',
    'token',
    'api_key',
    'apikey',
    'authorization',
    'auth',
    'session',
    'cookie',
    'credential',
    'private_key',
    'email',
  };

  static const String _redacted = '<redacted>';

  final List<LogRecord> _buffer = <LogRecord>[];
  static const int _maxBuffered = 400;

  /// Minimum level that will be emitted. Adjustable from settings.
  LogLevel minimumLevel = LogLevel.debug;

  /// When false, only levels enabled in release are emitted.
  bool verbose = true;

  bool get isDebugBuild => _debugBuild;
  static final bool _debugBuild = _detectDebug();

  static bool _detectDebug() {
    bool debug = false;
    assert(() {
      debug = true;
      return true;
    }());
    return debug;
  }

  /// Recent records, newest last. Bounded so a long session cannot grow the
  /// heap without limit.
  List<LogRecord> get records => List.unmodifiable(_buffer);

  void clearBuffer() => _buffer.clear();

  bool shouldLog(LogLevel level) {
    if (level.index < minimumLevel.index) return false;
    if (isDebugBuild) return true;
    return level.enabledInRelease;
  }

  void debug(String message, {Map<String, Object?> context = const {}}) =>
      log(LogLevel.debug, message, context: context);

  void info(String message, {Map<String, Object?> context = const {}}) =>
      log(LogLevel.info, message, context: context);

  void warn(String message,
          {Map<String, Object?> context = const {}, Object? error}) =>
      log(LogLevel.warn, message, context: context, error: error);

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) =>
      log(LogLevel.error, message,
          context: context, error: error, stackTrace: stackTrace);

  void perf(String message, {Map<String, Object?> context = const {}}) =>
      log(LogLevel.perf, message, context: context);

  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!shouldLog(level)) return;

    final safeContext = _redact(context);
    final record = LogRecord(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      context: safeContext,
      errorType: error?.runtimeType.toString(),
      // The full trace is only retained in development; in release it would
      // both leak internals and bloat the buffer.
      hasStackTrace: stackTrace != null && isDebugBuild,
    );
    _buffer.add(record);
    if (_buffer.length > _maxBuffered) {
      _buffer.removeRange(0, _buffer.length - _maxBuffered);
    }
    _emit(record, error: error, stackTrace: stackTrace);
  }

  void _emit(LogRecord record, {Object? error, StackTrace? stackTrace}) {
    final line = record.format();
    // ignore: avoid_print
    print(line);
    if (stackTrace != null && isDebugBuild) {
      // ignore: avoid_print
      print(stackTrace);
    }
    if (isDebugBuild) {
      // ignore: avoid_print
      print(error);
    }
  }

  /// Strips sensitive values before anything reaches a log sink.
  static Map<String, Object?> _redact(Map<String, Object?> context) {
    if (context.isEmpty) return const {};
    final result = <String, Object?>{};
    for (final entry in context.entries) {
      final key = entry.key.toLowerCase();
      final sensitive = redactedKeys.any((k) => key.contains(k));
      result[entry.key] = sensitive ? _redacted : entry.value;
    }
    return result;
  }
}

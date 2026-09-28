/// Severity levels used across both the app logger and the performance
/// logger. The order is significant: [LogLevel.compareTo] is used to filter.
enum LogLevel {
  debug,
  info,
  warn,
  error,
  perf;

  /// Short tag rendered in the log prefix, e.g. `[PERF]`.
  String get tag => name.toUpperCase();

  /// Whether this level is emitted at all in a release build.
  ///
  /// Release builds keep warnings, errors and slow-operation performance
  /// warnings; debug and info are suppressed so production logs stay
  /// actionable instead of noisy.
  bool get enabledInRelease => switch (this) {
        LogLevel.debug => false,
        LogLevel.info => false,
        LogLevel.warn => true,
        LogLevel.error => true,
        LogLevel.perf => false,
      };
}

/// A single recorded log line, retained for the in-app diagnostics view.
class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    this.context = const {},
    this.errorType,
    this.hasStackTrace = false,
  });

  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final Map<String, Object?> context;
  final String? errorType;
  final bool hasStackTrace;

  /// `[WARN] Sync failed` style single-line rendering.
  String format() {
    final buffer = StringBuffer('[${level.tag}] $message');
    if (errorType != null) buffer.write(' ($errorType)');
    if (context.isNotEmpty) {
      buffer.write(' ');
      buffer.write(context.entries
          .map((e) => '${e.key}=${e.value}')
          .join(' '));
    }
    return buffer.toString();
  }
}

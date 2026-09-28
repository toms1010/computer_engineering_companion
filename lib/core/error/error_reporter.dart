import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../../services/performance/app_logger.dart';
import '../../services/performance/log_level.dart';
import 'app_exception.dart';
import 'error_boundary.dart';

/// Single place every error is reported to.
///
/// Responsibilities:
///  * normalise unknown errors into [AppException];
///  * log once, with redaction, in a consistent format;
///  * hand back a message that is safe and useful to show a user;
///  * keep the last errors in memory for the diagnostics screen.
class ErrorReporter {
  ErrorReporter._();

  static final ErrorReporter instance = ErrorReporter._();

  static const int _maxRecent = 50;
  final List<ReportedError> _recent = <ReportedError>[];

  List<ReportedError> get recent => List.unmodifiable(_recent);

  /// Reports [error] and returns the normalised exception, so callers can
  /// `throw` or `return` the same object.
  AppException report(
    Object error, {
    StackTrace? stackTrace,
    String? operation,
    String? screen,
    Map<String, Object?> context = const {},
  }) {
    final normalised = normaliseError(error, operation: operation);
    _recent.add(ReportedError(
      error: normalised,
      screen: screen,
      operation: operation,
      timestamp: DateTime.now(),
    ));
    if (_recent.length > _maxRecent) {
      _recent.removeRange(0, _recent.length - _maxRecent);
    }
    AppLogger.instance.log(
      LogLevel.error,
      normalised.message,
      context: {
        ...normalised.context,
        ...context,
        if (screen != null) 'screen': screen,
        if (operation != null) 'operation': operation,
      },
      error: error,
      stackTrace: stackTrace,
    );
    return normalised;
  }

  void clear() => _recent.clear();
}

/// An error the app has already handled, retained for diagnostics.
class ReportedError {
  const ReportedError({
    required this.error,
    required this.timestamp,
    this.screen,
    this.operation,
  });

  final AppException error;
  final DateTime timestamp;
  final String? screen;
  final String? operation;

  String format() {
    final buffer = StringBuffer('[ERROR] ${error.message}');
    if (operation != null) buffer.write(' op=$operation');
    if (screen != null) buffer.write(' screen=$screen');
    return buffer.toString();
  }
}

/// Runs [action], converting any thrown error into a normalised
/// [AppException] and logging it exactly once.
///
/// Used at repository and service boundaries so callers can rely on a single
/// error type and so no error is ever reported twice.
Future<T> guard<T>(
  Future<T> Function() action, {
  String? operation,
  String? screen,
  Map<String, Object?> context = const {},
}) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    throw ErrorReporter.instance.report(
      error,
      stackTrace: stackTrace,
      operation: operation,
      screen: screen,
      context: context,
    );
  }
}

/// Synchronous counterpart to [guard].
T guardSync<T>(
  T Function() action, {
  String? operation,
  String? screen,
  Map<String, Object?> context = const {},
}) {
  try {
    return action();
  } catch (error, stackTrace) {
    throw ErrorReporter.instance.report(
      error,
      stackTrace: stackTrace,
      operation: operation,
      screen: screen,
      context: context,
    );
  }
}

/// Runs [action] and swallows failures, reporting them instead. Use for
/// fire-and-forget work such as analytics or a best-effort cache warm-up.
Future<void> guardSilently(
  Future<void> Function() action, {
  String? operation,
}) async {
  try {
    await action();
  } catch (error, stackTrace) {
    ErrorReporter.instance.report(error,
        stackTrace: stackTrace, operation: operation);
  }
}

/// Debug-only helper that asserts a non-null value with a readable message.
T requireValue<T>(T? value, String name) {
  assert(value != null, 'Expected $name to be provided but was null');
  if (value == null) {
    throw UnknownException('Missing required value: $name');
  }
  return value;
}

/// Prints a Flutter framework error exactly once through the reporter.
///
/// Registered at startup so framework-level errors (layout overflows, build
/// exceptions) still reach the log, and so the red debug box is replaced by
/// an in-place placeholder that the surrounding list can flow around.
void installGlobalErrorHandlers() {
  ErrorWidget.builder = (details) => ErrorFallback(
        message: normaliseError(details.exception).message,
      );

  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    ErrorReporter.instance.report(
      details.exception,
      stackTrace: details.stack,
      operation: 'flutter_framework',
      context: {
        'library': details.library ?? 'flutter',
        'silent': details.silent,
      },
    );
    // Preserve the default red-screen/console behaviour in development.
    if (AppLogger.instance.isDebugBuild && previous != null) {
      previous(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorReporter.instance.report(
      error,
      stackTrace: stack,
      operation: 'platform_dispatcher',
    );
    return true;
  };
}

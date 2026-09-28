/// Typed application failures.
///
/// Every layer below the UI throws one of these instead of a bare
/// `Exception`, which gives the UI something specific to render. A user
/// should never be shown a raw `DatabaseException` or the string "null".
abstract class AppException implements Exception {
  const AppException(this.message, {this.cause, this.context = const {}});

  /// Safe, user-facing description. Never contains a stack trace, a file
  /// path or a query fragment.
  final String message;

  /// Original error, kept for logs only.
  final Object? cause;

  /// Non-sensitive diagnostic context, redacted before logging.
  final Map<String, Object?> context;

  /// Whether retrying the same request could plausibly succeed. Only
  /// transport failures are retryable; a validation or auth failure will fail
  /// identically no matter how often it is resent.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType: $message';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.cause, super.context});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.cause, super.context});
}

class NetworkException extends AppException {
  const NetworkException(
    super.message, {
    super.cause,
    super.context,
    this.statusCode,
    this.isTimeout = false,
    this.isOffline = false,
  });

  final int? statusCode;
  final bool isTimeout;
  final bool isOffline;

  @override
  bool get isRetryable =>
      isTimeout || isOffline || (statusCode != null && statusCode! >= 500);
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.field, super.cause, super.context});

  final String? field;
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.cause, super.context});
}

class CancelledException extends AppException {
  const CancelledException([super.message = 'Operation cancelled']);
}

class AiException extends AppException {
  const AiException(super.message, {super.cause, super.context, this.isLocal = true});

  /// True when the failure came from the on-device engine rather than an
  /// optional remote provider, so the UI can say so.
  final bool isLocal;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.cause, super.context});
}

/// Catch-all for anything we could not classify. Preferred over surfacing a
/// raw driver message to the user.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause, super.context});
}

/// Normalises anything thrown into an [AppException].
///
/// Called at layer boundaries so the UI only ever deals with one type.
AppException normaliseError(Object error, {String? operation}) {
  if (error is AppException) return error;

  final text = error.toString();
  final context = <String, Object?>{
    if (operation != null) 'operation': operation,
    'type': error.runtimeType.toString(),
  };

  if (error is NoSuchMethodError) {
    return ValidationException('That feature is not available in this build.',
        cause: error, context: context);
  }
  if (error is ArgumentError || error is FormatException) {
    return ValidationException('The value entered could not be read.',
        cause: error, context: context);
  }
  if (text.contains('DatabaseException') ||
      text.contains('SQLite') ||
      text.contains('no such table')) {
    return DatabaseException(
        'The local database could not complete that request.',
        cause: error,
        context: context);
  }
  if (text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('Network is unreachable') ||
      text.contains('HandshakeException')) {
    return const NetworkException(
      'No internet connection. Your work is saved on this device.',
      isOffline: true,
    );
  }
  if (text.contains('TimeoutException')) {
    return const NetworkException(
      'The request took too long and was stopped.',
      isTimeout: true,
    );
  }
  return UnknownException(
    'Something went wrong and the app could not finish that action.',
    cause: error,
    context: context,
  );
}

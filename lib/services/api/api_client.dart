import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/error/app_exception.dart';
import '../performance/performance_monitor.dart';

/// Where a request stands relative to connectivity.
///
/// Derived from real request outcomes rather than a connectivity plugin, so
/// it can never claim to be online when the backend is unreachable, and it
/// needs no extra platform permissions.
enum NetworkStatus { online, offline, unknown }

/// Snapshot of backend reachability, exposed to the UI as an offline banner.
class NetworkStatusSnapshot {
  const NetworkStatusSnapshot({
    required this.status,
    required this.checkedAt,
    this.consecutiveFailures = 0,
  });

  final NetworkStatus status;
  final DateTime checkedAt;
  final int consecutiveFailures;

  bool get isOffline => status == NetworkStatus.offline;

  static NetworkStatusSnapshot unknown() => NetworkStatusSnapshot(
        status: NetworkStatus.unknown,
        checkedAt: _epoch,
      );
}

/// Tracks reachability and short-circuits requests while offline.
///
/// Requirement: "do not repeatedly attempt remote requests when the device
/// has no connection." Every failure below the threshold trips an offline
/// state, after which requests fail instantly with a local
/// [NetworkException] instead of waiting out a socket timeout.
class NetworkMonitor {
  NetworkMonitor({this.failureThreshold = 2});

  /// Consecutive failures before the app is declared offline.
  final int failureThreshold;

  final ValueNotifier<NetworkStatusSnapshot> _status =
      ValueNotifier(NetworkStatusSnapshot.unknown());

  ValueListenable<NetworkStatusSnapshot> get status => _status;

  NetworkStatus get current => _status.value.status;

  bool get isOffline => _status.value.isOffline;

  void recordSuccess() {
    if (_status.value.status == NetworkStatus.online &&
        _status.value.consecutiveFailures == 0) {
      return;
    }
    _status.value = NetworkStatusSnapshot(
      status: NetworkStatus.online,
      checkedAt: DateTime.now(),
    );
  }

  void recordFailure() {
    final failures = _status.value.consecutiveFailures + 1;
    _status.value = NetworkStatusSnapshot(
      status:
          failures >= failureThreshold ? NetworkStatus.offline : NetworkStatus.unknown,
      checkedAt: DateTime.now(),
      consecutiveFailures: failures,
    );
  }

  /// Releases the notifier. Called when the provider is disposed.
  void dispose() => _status.dispose();

  /// Called when the user explicitly says they are online again, or after a
  /// connectivity change the platform reports.
  void reset() {
    _status.value = NetworkStatusSnapshot.unknown();
  }
}

final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

/// A decoded API response, or a typed failure.
sealed class ApiResult<T> {
  const ApiResult();

  bool get isSuccess => this is ApiSuccess<T>;

  T? get valueOrNull => this is ApiSuccess<T> ? (this as ApiSuccess<T>).data : null;

  Object? get errorOrNull =>
      this is ApiFailure<T> ? (this as ApiFailure<T>).error : null;
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);
  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);
  final AppException error;
}

/// Thin, well-behaved HTTP client.
///
/// Deliberately the *only* place in the app that performs network I/O.
/// It owns timeouts, retries, cancellation and status-code mapping so no
/// screen has to reimplement them.
///
/// The app is fully functional with this client never used: there is no
/// hardcoded endpoint, and [baseUrl] is empty unless the user configures
/// one.
class ApiClient {
  ApiClient({
    required this.networkMonitor,
    http.Client? httpClient,
    this.baseUrl = '',
    this.timeout = const Duration(seconds: 12),
    this.maxRetries = 2,
  }) : _http = httpClient ?? http.Client();

  final NetworkMonitor networkMonitor;
  final String baseUrl;
  final Duration timeout;
  final int maxRetries;
  final http.Client _http;

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  void close() => _http.close();

  Uri _uri(String path, [Map<String, Object?>? query]) {
    final base = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/');
    final relative = path.startsWith('/') ? path.substring(1) : path;
    return base.replace(
      path: '${base.path}$relative',
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  /// Performs a request and returns a decoded body, or a typed failure.
  ///
  /// Never throws for network conditions: the UI layer decides what to show,
  /// and it needs a [AppException] with a usable message either way.
  Future<ApiResult<T>> send<T>(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    Map<String, String> headers = const {},
    T Function(dynamic decoded)? decode,
    CancellationToken? cancellation,
  }) async {
    if (!isConfigured) {
      return ApiFailure(NetworkException(
        'No cloud service is configured. Your data stays on this device.',
      ));
    }
    if (networkMonitor.isOffline) {
      // Fail fast instead of waiting out a socket timeout we know will
      // fail. This is the "do not retry when offline" rule.
      return const ApiFailure(NetworkException(
        'You are offline. Changes are saved and will sync later.',
        isOffline: true,
      ));
    }

    final label = '$method $path';
    var attempt = 0;
    AppException? lastError;

    while (attempt <= maxRetries) {
      if (cancellation?.isCancelled ?? false) {
        return const ApiFailure(CancelledException());
      }
      final trace = PerformanceMonitor.instance.trackApi(label,
          context: {'attempt': attempt, ...(query == null ? {} : {'query': query.keys.join(',')})});
      try {
        final request = http.Request(method, _uri(path, query));
        request.headers.addAll({
          'accept': 'application/json',
          if (body != null) 'content-type': 'application/json',
          ...headers,
        });
        if (body != null) request.body = jsonEncode(body);

        final streamed = await _http.send(request).timeout(timeout);
        final response = await http.Response.fromStream(streamed).timeout(timeout);
        trace.stop();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          networkMonitor.recordSuccess();
          return ApiSuccess(_decodeBody<T>(response, decode));
        }

        final failure = _mapStatus(response.statusCode, response.body);
        if (failure.isRetryable && attempt < maxRetries) {
          lastError = failure;
          attempt++;
          if (await _backoff(attempt, cancellation) == false) {
            return const ApiFailure(CancelledException());
          }
          continue;
        }
        networkMonitor.recordFailure();
        trace.stop(extra: {'status': response.statusCode});
        return ApiFailure(failure);
      } on TimeoutException {
        trace.stop(succeeded: false);
        lastError = const NetworkException(
          'The request took too long and was stopped.',
          isTimeout: true,
        );
      } on SocketException catch (error) {
        trace.stop(succeeded: false);
        networkMonitor.recordFailure();
        return ApiFailure(NetworkException(
          'No internet connection. Your work is saved on this device.',
          cause: error,
          isOffline: true,
        ));
      } on http.ClientException catch (error) {
        trace.stop(succeeded: false);
        lastError = NetworkException('The connection failed.', cause: error);
      } on CancelledException {
        trace.stop(succeeded: false);
        return const ApiFailure(CancelledException());
      } on AppException catch (error) {
        // A typed failure from decoding must reach the caller intact, not be
        // rewrapped as a generic network problem: "the server sent something
        // unreadable" and "the network failed" are different user messages.
        trace.stop(succeeded: false);
        return ApiFailure<T>(error);
      } catch (error) {
        trace.stop(succeeded: false);
        return ApiFailure(
          NetworkException('The request could not be completed.', cause: error),
        );
      }

      networkMonitor.recordFailure();
      if (attempt >= maxRetries) {
        return ApiFailure<T>(_lastError(lastError));
      }
      attempt++;
      if (await _backoff(attempt, cancellation) == false) {
        return const ApiFailure(CancelledException());
      }
    }

    return ApiFailure<T>(_lastError(lastError));
  }

  T _decodeBody<T>(http.Response response, T Function(dynamic)? decode) {
    if (response.bodyBytes.isEmpty) {
      return decode != null ? decode(null) : null as T;
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ValidationException(
          'The server sent a response the app could not read.');
    }
    return decode != null ? decode(decoded) : decoded as T;
  }

  /// Maps an HTTP status to a typed failure.
  ///
  /// [status] is passed as `statusCode` so `NetworkException.isRetryable` —
  /// which decides whether the retry loop runs at all — sees it. Recording it
  /// only in `context` would silently make every 5xx non-retryable.
  AppException _mapStatus(int status, String body) {
    if (status == 401 || status == 403) {
      return AuthException('This action needs a signed-in account.',
          context: {'status': status});
    }
    if (status == 404) {
      return NotFoundException('That item no longer exists on the server.',
          context: {'status': status});
    }
    if (status == 409) {
      // Conflict is an expected, recoverable outcome in a last-write-wins
      // sync, not an error to shout about.
      return NetworkException('This item was changed on another device.',
          statusCode: status);
    }
    if (status >= 500) {
      return NetworkException('The service is having trouble. Try again shortly.',
          statusCode: status);
    }
    if (status == 429) {
      return NetworkException('Too many requests. Wait a moment and try again.',
          statusCode: status);
    }
    return NetworkException('The request was rejected.', statusCode: status);
  }

  /// Exponential backoff with jitter, so a fleet of clients retrying after
  /// an outage does not synchronise into a second outage.
  ///
  /// Returns false if the request was cancelled while waiting.
  /// Final fallback error, used when the retry budget is exhausted without a
  /// more specific cause being recorded.
  static AppException _lastError(AppException? recorded) =>
      recorded ??
      const NetworkException('The request could not be completed.');

  Future<bool> _backoff(int attempt, CancellationToken? cancellation) async {
    final baseMs = 200 * (1 << (attempt - 1));
    final jitterMs = (baseMs * 0.3 * _random()).round();
    final delay = Duration(milliseconds: baseMs + jitterMs);
    if (cancellation == null) {
      await Future<void>.delayed(delay);
      return true;
    }
    if (cancellation.isCancelled) return false;
    return Future.any<bool>([
      Future<bool>.delayed(delay, () => true),
      cancellation.future.then((_) => false),
    ]);
  }

  static double _random() => DateTime.now().microsecondsSinceEpoch % 100 / 100;
}

/// Cooperative cancellation for in-flight work.
///
/// This is how a screen stops caring about a request it no longer needs: the
/// token is cancelled in `dispose`, so a late response can never call
/// `setState` on an unmounted widget.
class CancellationToken {
  final Completer<void> _completer = Completer<void>();
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  /// Completes when the token is cancelled. Used to race against a delay.
  Future<void> get future => _completer.future;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    if (!_completer.isCompleted) _completer.complete();
  }
}

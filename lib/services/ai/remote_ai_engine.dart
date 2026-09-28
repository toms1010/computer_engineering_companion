import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/error/app_exception.dart';
import '../api/api_client.dart';
import '../performance/performance_monitor.dart';
import '../storage/secure_key_store.dart';
import 'ai_models.dart';

/// Optional remote assistant provider.
///
/// Three rules, enforced here rather than left to the UI:
///
///  1. It is **off by default**. Nothing is sent anywhere until the user
///     supplies their own endpoint and key and turns it on.
///  2. It only ever receives the text the user typed. Notes, bookmarks,
///     progress and the local database are never attached — the API surface
///     takes a single `prompt` string and has no other parameter.
///  3. If it is disabled, unconfigured, offline or fails, the caller falls
///     back to the on-device engine. There is no state where the assistant
///     is simply unavailable.
class RemoteAiEngine {
  RemoteAiEngine({
    required SecureKeyStore keyStore,
    required NetworkMonitor networkMonitor,
    http.Client? httpClient,
  })  : _keyStore = keyStore,
        _networkMonitor = networkMonitor,
        _http = httpClient ?? http.Client();

  final SecureKeyStore _keyStore;
  final NetworkMonitor _networkMonitor;
  final http.Client _http;

  static const Duration _timeout = Duration(seconds: 25);

  /// User-controlled switch. Mirrored in settings and persisted.
  bool _enabled = false;

  bool get isEnabled => _enabled;

  /// True when the user has both switched it on *and* provided credentials.
  Future<bool> get isUsable async =>
      _enabled && await _keyStore.hasKey() && await _endpoint() != null;

  void setEnabled(bool value) => _enabled = value;

  Future<String?> _endpoint() async {
    final value = await _keyStore.readEndpoint();
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  /// Asks the configured provider. Returns null when the remote path is not
  /// available, which tells the caller to use the local engine instead.
  Future<AiAnswer?> ask(AiRequest request) async {
    if (!await isUsable) return null;
    if (_networkMonitor.isOffline) return null;

    final endpoint = await _endpoint();
    final apiKey = await _keyStore.readApiKey();
    if (endpoint == null || apiKey == null) return null;

    final trace = PerformanceMonitor.instance.trackAi('remote.ask',
        context: {'length': request.prompt.length});
    try {
      final response = await _http
          .post(
            Uri.parse(endpoint),
            headers: {
              'content-type': 'application/json',
              // The key travels in a header, never in the body, and is never
              // logged: the trace carries only the prompt length.
              'authorization': 'Bearer $apiKey',
            },
            // Only the user's own words are sent. No notes, no progress, no
            // identifiers.
            body: jsonEncode({
              'model': 'configured-by-user',
              'messages': [
                {
                  'role': 'system',
                  'content': 'You are a computer engineering tutor. Answer '
                      'concisely and accurately.',
                },
                {'role': 'user', 'content': request.prompt},
              ],
              'stream': false,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        trace.stop(succeeded: false, extra: {'status': response.statusCode});
        _networkMonitor.recordFailure();
        return null;
      }

      _networkMonitor.recordSuccess();
      final text = _extractText(response.body);
      if (text == null || text.isEmpty) {
        trace.stop(succeeded: false);
        return null;
      }
      return AiAnswer(
        text: '$text\n\n_Sent to your configured provider._',
        source: AiSource.remote,
        citations: const [],
        elapsed: trace.stop(),
        suggestions: const [],
      );
    } on Object {
      // Any failure degrades to the local engine. The assistant must never
      // stop working because a remote provider is unreachable.
      trace.stop(succeeded: false);
      return null;
    }
  }

  /// Pulls the assistant text out of an OpenAI-shaped response, tolerating
  /// providers that return a bare string.
  static String? _extractText(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is String) return decoded;
      if (decoded is Map<String, Object?>) {
        final choices = decoded['choices'];
        if (choices is List && choices.isNotEmpty) {
          final first = choices.first;
          if (first is Map<String, Object?>) {
            final message = first['message'];
            if (message is Map<String, Object?>) {
              final content = message['content'];
              if (content is String) return content;
            }
            final text = first['text'];
            if (text is String) return text;
          }
        }
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  void close() => _http.close();
}

/// Thrown only if a caller explicitly demands the remote path and it is
/// unavailable, instead of falling back.
class RemoteUnavailableException extends AiException {
  const RemoteUnavailableException()
      : super('The remote assistant is not configured or is unreachable.');
}

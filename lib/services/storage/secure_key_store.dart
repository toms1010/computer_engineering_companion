import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../performance/app_logger.dart';

/// Encrypted storage for the optional remote-provider credential.
///
/// The key is never compiled into the app, never written to
/// `SharedPreferences`, and never logged: the user supplies it, and it lives
/// in the platform keystore (Android Keystore / iOS Keychain) until they
/// clear it.
///
/// Nothing here is required for the app to work. With no key stored, the
/// assistant runs entirely on-device.
class SecureKeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                  accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _apiKeyName = 'remote_ai_api_key';
  static const _endpointName = 'remote_ai_endpoint';

  /// Reads a key. Returns null rather than throwing so a keystore failure
  /// degrades to "no remote provider" instead of breaking the assistant.
  Future<String?> readApiKey() => _read(_apiKeyName);

  Future<String?> readEndpoint() => _read(_endpointName);

  Future<void> writeApiKey(String value) => _write(_apiKeyName, value);

  Future<void> writeEndpoint(String value) => _write(_endpointName, value);

  Future<void> clear() async {
    try {
      await _storage.delete(key: _apiKeyName);
      await _storage.delete(key: _endpointName);
    } catch (error) {
      AppLogger.instance.warn('Could not clear stored credentials',
          context: {'type': error.runtimeType.toString()});
    }
  }

  /// True when a key is present. Deliberately does not return the value so
  /// callers cannot accidentally log it.
  Future<bool> hasKey() async => (await readApiKey())?.isNotEmpty ?? false;

  Future<String?> _read(String name) async {
    try {
      return await _storage.read(key: name);
    } catch (error) {
      AppLogger.instance.warn('Credential read failed',
          context: {'type': error.runtimeType.toString()});
      return null;
    }
  }

  Future<void> _write(String name, String value) async {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('The value cannot be empty.');
    }
    await _storage.write(key: name, value: trimmed);
  }
}

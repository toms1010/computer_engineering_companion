import 'dart:async';

/// Debounces a callback so work runs once the user stops acting.
///
/// Every search field in the app uses this: running a query on each
/// keystroke re-renders the whole result list and, if the query touches the
/// database, opens a transaction per character.
///
/// The timer is owned by the instance, so [dispose] guarantees no callback
/// fires after the widget is gone.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 250)});

  final Duration delay;
  Timer? _timer;

  bool get isPending => _timer?.isActive ?? false;

  /// Schedules [action], cancelling any previously scheduled call.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Runs [action] immediately and cancels anything pending.
  void flush(void Function() action) {
    _timer?.cancel();
    _timer = null;
    action();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}

/// Debounces an async result, cancelling the previous in-flight call when a
/// newer input arrives.
///
/// This is the pattern that stops a slow request from overwriting a newer
/// one's results ("the old screen updates state after the user left").
class DebouncedRunner<T> {
  DebouncedRunner({this.delay = const Duration(milliseconds: 250)});

  final Duration delay;
  Timer? _timer;
  int _generation = 0;
  bool _disposed = false;

  /// Runs [action] after the debounce window. The result is delivered to
  /// [onResult] only if no newer call has started.
  void run(
    Future<T> Function() action, {
    required void Function(T value) onResult,
    void Function(Object error)? onError,
  }) {
    _timer?.cancel();
    final generation = ++_generation;
    _timer = Timer(delay, () async {
      if (_disposed || generation != _generation) return;
      try {
        final result = await action();
        if (_disposed || generation != _generation) return;
        onResult(result);
      } catch (error) {
        if (_disposed || generation != _generation) return;
        onError?.call(error);
      }
    });
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }
}

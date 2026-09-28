import 'dart:async';
import 'dart:io';

import 'package:computer_engineering_companion/core/error/app_exception.dart';
import 'package:computer_engineering_companion/core/error/error_reporter.dart';
import 'package:computer_engineering_companion/core/utils/app_time.dart';
import 'package:computer_engineering_companion/core/utils/debouncer.dart';
import 'package:computer_engineering_companion/services/api/api_client.dart';
import 'package:computer_engineering_companion/services/performance/app_logger.dart';
import 'package:computer_engineering_companion/services/performance/log_level.dart';
import 'package:computer_engineering_companion/services/performance/performance_logger.dart';
import 'package:computer_engineering_companion/services/performance/performance_metrics.dart';
import 'package:computer_engineering_companion/services/performance/performance_monitor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('AppLogger', () {
    setUp(() {
      AppLogger.instance.clearBuffer();
      AppLogger.instance.minimumLevel = LogLevel.debug;
    });

    test('uses a consistent, greppable format', () {
      AppLogger.instance.warn('Sync failed', context: {'status': 503});
      final record = AppLogger.instance.records.last;
      expect(record.format(), '[WARN] Sync failed status=503');
    });

    test('redacts sensitive values before they reach a sink', () {
      AppLogger.instance.info('auth', context: {
        'api_key': 'sk-live-secret',
        'password': 'hunter2',
        'authorization': 'Bearer abc',
        'lessonId': 42,
      });
      final record = AppLogger.instance.records.last;
      final formatted = record.format();
      expect(formatted, isNot(contains('sk-live-secret')));
      expect(formatted, isNot(contains('hunter2')));
      expect(formatted, isNot(contains('Bearer abc')));
      // Non-sensitive context survives.
      expect(formatted, contains('lessonId=42'));
    });

    test('suppresses records below the minimum level', () {
      AppLogger.instance.minimumLevel = LogLevel.warn;
      AppLogger.instance.debug('noise');
      AppLogger.instance.info('more noise');
      expect(AppLogger.instance.records, isEmpty);
      AppLogger.instance.warn('important');
      expect(AppLogger.instance.records, hasLength(1));
    });

    test('buffers are bounded so a long session cannot grow the heap', () {
      for (var i = 0; i < 600; i++) {
        AppLogger.instance.info('line $i');
      }
      expect(AppLogger.instance.records.length, lessThanOrEqualTo(400));
    });

    test('a level is enabled in release only when it matters', () {
      expect(LogLevel.warn.enabledInRelease, isTrue);
      expect(LogLevel.error.enabledInRelease, isTrue);
      expect(LogLevel.debug.enabledInRelease, isFalse);
      expect(LogLevel.perf.enabledInRelease, isFalse);
    });
  });

  group('PerformanceLogger', () {
    setUp(() {
      PerformanceLogger.instance.registry.clear();
    });

    test('records a sample and aggregates it into a series', () {
      final logger = PerformanceLogger.instance;
      logger.record('DB loadSubjects', PerfCategory.database,
          const Duration(milliseconds: 12));
      logger.record('DB loadSubjects', PerfCategory.database,
          const Duration(milliseconds: 28));

      final events = logger.registry.events;
      expect(events, hasLength(2));
      // The `[PERF]` prefix is added by the logger, not baked into the
      // format, so console output and the diagnostics list cannot disagree.
      expect(events.first.format(), 'DB loadSubjects 12ms');

      final series = logger.registry.series
          .firstWhere((s) => s.name == 'DB loadSubjects');
      expect(series.count, 2);
      expect(series.averageMs, 20);
      expect(series.maxMs, 28);
    });

    test('flags a slow operation against its budget', () {
      final logger = PerformanceLogger.instance;
      logger.thresholds = PerfThresholds(database: const Duration(milliseconds: 300));
      logger.record('DB slow', PerfCategory.database,
          const Duration(milliseconds: 742));
      final series = logger.registry.series.firstWhere((s) => s.name == 'DB slow');
      expect(series.slowCount, 1);
      expect(series.slowRate, 1);
    });

    test('does not flag an operation inside its budget', () {
      PerformanceLogger.instance.record('DB fast', PerfCategory.database,
          const Duration(milliseconds: 10));
      final series = PerformanceLogger.instance.registry.series
          .firstWhere((s) => s.name == 'DB fast');
      expect(series.slowCount, 0);
    });

    test('budgets are configurable per category', () {
      final thresholds = PerfThresholds();
      expect(thresholds.budgetFor(PerfCategory.screen),
          const Duration(milliseconds: 500));
      expect(thresholds.budgetFor(PerfCategory.database),
          const Duration(milliseconds: 300));
      expect(thresholds.budgetFor(PerfCategory.api),
          const Duration(milliseconds: 2000));
      expect(thresholds.budgetFor(PerfCategory.image),
          const Duration(milliseconds: 1000));

      final relaxed = thresholds.copyWith(database: const Duration(seconds: 1));
      expect(relaxed.budgetFor(PerfCategory.database),
          const Duration(seconds: 1));
      // copyWith must not lose the frame budget.
      expect(relaxed.frameBudget, thresholds.frameBudget);
    });

    test('a trace reports its duration and is idempotent', () {
      final trace =
          PerformanceLogger.instance.start('X', PerfCategory.render);
      final first = trace.stop();
      final second = trace.stop();
      expect(first.inMicroseconds, greaterThanOrEqualTo(0));
      // Stopping twice must not double-count.
      expect(second, Duration.zero);
      expect(PerformanceLogger.instance.registry.events, hasLength(1));
    });

    test('formats sub-second, second and millisecond values readably', () {
      String format(Duration d) => PerfSample(
            name: 'X',
            category: PerfCategory.render,
            duration: d,
            timestamp: DateTime.now(),
          ).format();

      expect(format(const Duration(milliseconds: 5)), 'X 5.0ms');
      expect(format(const Duration(milliseconds: 112)), 'X 112ms');
      expect(format(const Duration(milliseconds: 2400)), 'X 2.40s');
    });
  });

  group('FrameStats', () {
    test('counts a frame over budget as janky', () {
      final frames = FrameStats()
        ..record(
          build: const Duration(milliseconds: 8),
          raster: const Duration(milliseconds: 7),
          budget: const Duration(milliseconds: 16),
        )
        ..record(
          build: const Duration(milliseconds: 30),
          raster: const Duration(milliseconds: 20),
          budget: const Duration(milliseconds: 16),
        );

      expect(frames.totalFrames, 2);
      expect(frames.jankyFrames, 1);
      expect(frames.jankRate, 0.5);
      expect(frames.worstFrameMs, 50);
      expect(frames.averageBuildMs, 19);
    });
  });

  group('ErrorReporter', () {
    setUp(() => ErrorReporter.instance.clear());

    test('normalises a socket failure into an offline message', () {
      final error = ErrorReporter.instance.report(
          const SocketException('Failed host lookup: example.com'));
      expect(error, isA<NetworkException>());
      expect((error as NetworkException).isOffline, isTrue);
      expect(error.message, contains('saved on this device'));
    });

    test('normalises a timeout', () {
      final error = ErrorReporter.instance.report(TimeoutException('slow'));
      expect((error as NetworkException).isTimeout, isTrue);
    });

    test('normalises a SQLite failure', () {
      final error = ErrorReporter.instance
          .report(Exception('SQLite: no such table: lessons'));
      expect(error, isA<DatabaseException>());
    });

    test('never leaks a raw message to the user for an unknown error', () {
      final error = ErrorReporter.instance.report(StateError('secret internals'));
      expect(error.message, isNot(contains('secret internals')));
      // The cause is retained for logs.
      expect(error.cause, isA<StateError>());
    });

    test('passes an AppException through unchanged', () {
      const original = ValidationException('bad input', field: 'email');
      expect(ErrorReporter.instance.report(original), same(original));
    });

    test('guard converts and rethrows as a typed failure', () async {
      await expectLater(
        guard<void>(() async => throw const SocketException('down'),
            operation: 'test'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('guardSync converts and rethrows as a typed failure', () {
      expect(
        () => guardSync<void>(() => throw const FormatException('x'),
            operation: 'test'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('guard swallows nothing when the action succeeds', () async {
      expect(await guard(() async => 42, operation: 'test'), 42);
    });

    test('recent errors are retained and bounded', () {
      for (var i = 0; i < 80; i++) {
        ErrorReporter.instance.report(StateError('e$i'), operation: 'op');
      }
      expect(ErrorReporter.instance.recent.length, lessThanOrEqualTo(50));
    });
  });

  group('Debouncer', () {
    test('collapses a burst into a single call', () {
      var calls = 0;
      final debouncer = Debouncer(delay: const Duration(milliseconds: 30));
      for (var i = 0; i < 10; i++) {
        debouncer.run(() => calls++);
      }
      expect(calls, 0);
      debouncer.dispose();
    });

    test('flush runs immediately and cancels anything pending', () {
      var calls = 0;
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      debouncer.run(() => calls++);
      debouncer.flush(() => calls++);
      expect(calls, 1);
      expect(debouncer.isPending, isFalse);
      debouncer.dispose();
    });

    test('dispose prevents a pending callback from firing', () async {
      var fired = false;
      final debouncer = Debouncer(delay: const Duration(milliseconds: 20));
      debouncer.run(() => fired = true);
      debouncer.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(fired, isFalse);
    });

    test('the debounced runner delivers only the newest result', () async {
      final results = <int>[];
      final runner = DebouncedRunner<int>(delay: const Duration(milliseconds: 20));
      for (var i = 1; i <= 3; i++) {
        final value = i;
        runner.run(() async => value, onResult: results.add);
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(results, [3]);
      runner.dispose();
    });
  });

  group('AppTime', () {
    final now = DateTime(2026, 3, 15, 12, 5);

    test('relative labels cover the useful ranges', () {
      expect(AppTime.relative(now, now: now), 'just now');
      expect(
          AppTime.relative(now.subtract(const Duration(minutes: 12)),
              now: now),
          '12m ago');
      expect(
          AppTime.relative(now.subtract(const Duration(hours: 3)), now: now),
          '3h ago');
      expect(
          AppTime.relative(now.subtract(const Duration(days: 5)), now: now),
          '5d ago');
    });

    test('stopwatch is zero-padded', () {
      expect(AppTime.stopwatch(0), '0:00');
      expect(AppTime.stopwatch(65), '1:05');
      expect(AppTime.stopwatch(605), '10:05');
    });

    test('duration reads naturally', () {
      expect(AppTime.duration(0), '0m');
      expect(AppTime.duration(45), '45m');
      expect(AppTime.duration(60), '1h');
      expect(AppTime.duration(65), '1h 05m');
    });

    test('greeting follows the clock', () {
      expect(AppTime.greeting(DateTime(2026, 1, 1, 8)), 'morning');
      expect(AppTime.greeting(DateTime(2026, 1, 1, 14)), 'afternoon');
      expect(AppTime.greeting(DateTime(2026, 1, 1, 19)), 'evening');
      expect(AppTime.greeting(DateTime(2026, 1, 1, 23)), 'night');
    });

    test('malformed stored timestamps return null rather than throwing', () {
      expect(AppTime.tryParseIso('not a date'), isNull);
      expect(AppTime.tryParseIso(null), isNull);
      expect(AppTime.tryParseIso(''), isNull);
      expect(AppTime.tryParseIso('2026-01-01T00:00:00Z'), isNotNull);
    });
  });

  group('ApiClient', () {
    late NetworkMonitor monitor;

    setUp(() => monitor = NetworkMonitor());

    test('reports an unconfigured client without attempting a request', () async {
      final client = ApiClient(networkMonitor: monitor);
      final result = await client.send<Map<String, Object?>>('GET', '/anything');
      expect(result.isSuccess, isFalse);
      expect((result.errorOrNull! as NetworkException).message,
          contains('No cloud service is configured'));
    });

    test('short-circuits while offline instead of timing out', () async {
      var called = false;
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );
      for (var i = 0; i < 3; i++) {
        monitor.recordFailure();
      }
      expect(monitor.isOffline, isTrue);

      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect(called, isFalse);
      expect((result.errorOrNull! as NetworkException).isOffline, isTrue);
    });

    test('decodes a successful body', () async {
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async => http.Response('{"ok":true}', 200,
            headers: {'content-type': 'application/json'})),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x',
          decode: (decoded) => (decoded as Map).cast<String, Object?>());
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!['ok'], isTrue);
      expect(monitor.current, NetworkStatus.online);
    });

    test('maps 401 to an auth failure and does not retry', () async {
      var calls = 0;
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('', 401);
        }),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect(result.errorOrNull, isA<AuthException>());
      expect(calls, 1);
    });

    test('maps 404 to not-found', () async {
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async => http.Response('', 404)),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect(result.errorOrNull, isA<NotFoundException>());
    });

    test('maps 409 to a conflict so sync can resolve it', () async {
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async => http.Response('', 409)),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect((result.errorOrNull! as NetworkException).statusCode, 409);
    });

    test('retries a 500 then succeeds', () async {
      var calls = 0;
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async {
          calls++;
          return calls < 2 ? http.Response('', 500) : http.Response('{}', 200);
        }),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect(result.isSuccess, isTrue);
      expect(calls, 2);
    });

    test('gives up after the retry budget', () async {
      var calls = 0;
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('', 503);
        }),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect(result.isSuccess, isFalse);
      expect(calls, 3); // initial + 2 retries
    });

    test('a malformed body surfaces as a validation failure', () async {
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async => http.Response('not json', 200)),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x');
      expect(result.errorOrNull, isA<ValidationException>());
    });

    test('a cancelled request never reaches the network twice', () async {
      final token = CancellationToken()..cancel();
      var called = false;
      final client = ApiClient(
        networkMonitor: monitor,
        baseUrl: 'https://example.test',
        httpClient: MockClient((_) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );
      final result = await client.send<Map<String, Object?>>('GET', '/x',
          cancellation: token);
      expect(called, isFalse);
      expect(result.errorOrNull, isA<CancelledException>());
    });
  });

  group('NetworkMonitor', () {
    test('needs repeated failures before declaring the app offline', () {
      final monitor = NetworkMonitor(failureThreshold: 3);
      expect(monitor.isOffline, isFalse);
      monitor.recordFailure();
      monitor.recordFailure();
      expect(monitor.isOffline, isFalse);
      monitor.recordFailure();
      expect(monitor.isOffline, isTrue);
    });

    test('a success clears the offline state', () {
      final monitor = NetworkMonitor(failureThreshold: 1);
      monitor.recordFailure();
      expect(monitor.isOffline, isTrue);
      monitor.recordSuccess();
      expect(monitor.isOffline, isFalse);
    });

    test('a reset returns to unknown so the next request is attempted', () {
      final monitor = NetworkMonitor(failureThreshold: 1);
      monitor.recordFailure();
      monitor.reset();
      expect(monitor.current, NetworkStatus.unknown);
      expect(monitor.isOffline, isFalse);
    });
  });

  group('PerformanceMonitor', () {
    test('exposes named helpers per operation category', () {
      final monitor = PerformanceMonitor.instance;
      monitor.registry.clear();
      monitor.trackQuery('loadSubjects').stop();
      monitor.trackApi('sync').stop();
      monitor.trackImage('thumbnail').stop();
      monitor.trackAi('local.ask').stop();
      monitor.trackSync('drain').stop();
      monitor.trackNavigation('tab Home -> Learn').stop();

      final names = monitor.registry.events.map((e) => e.name).toList();
      expect(names, contains('DB loadSubjects'));
      expect(names, contains('API sync'));
      expect(names, contains('IMAGE thumbnail'));
      expect(names, contains('AI local.ask'));
      expect(names, contains('SYNC drain'));
      expect(names, contains('NAV tab Home -> Learn'));
    });

    test('a snapshot reports the current screen and frame stats', () {
      final monitor = PerformanceMonitor.instance;
      monitor.reset();
      monitor.trackScreen('Home');
      monitor.trackScreenReady('Home', const Duration(milliseconds: 112));
      final snapshot = monitor.snapshot();
      expect(snapshot.currentScreen, 'Home');
      expect(snapshot.screensVisited, 1);
      expect(
        snapshot.events.any((e) => e.name == 'SCREEN_READY'),
        isTrue,
      );
    });

    test('screen timing is attributed to the right screen', () {
      final monitor = PerformanceMonitor.instance;
      monitor.reset();
      monitor.trackScreen('Lesson');
      monitor.trackScreenReady('Lesson', const Duration(milliseconds: 340));
      final ready = monitor.registry.events
          .firstWhere((e) => e.name == 'SCREEN_READY');
      expect(ready.attributes['screen'], 'Lesson');
    });
  });
}

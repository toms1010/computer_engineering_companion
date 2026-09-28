import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/error/error_reporter.dart';
import 'services/performance/performance_monitor.dart';

/// Cold start, in order, and nothing else:
///
///  1. bind the framework
///  2. install error handlers so nothing is swallowed
///  3. start the performance clock — this must be the first thing that
///     touches [PerformanceMonitor], so `APP_READY` measures the real start
///  4. `runApp`
///
/// The database is deliberately *not* awaited here. Opening and seeding
/// 3 758 curriculum rows before the first frame is what produces a blank
/// white screen on first launch. Instead the boot screen renders immediately
/// with the real seed progress, and the rest of the app queries the database
/// through the same lazy, guarded open.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before anything else, so `APP_READY` covers the whole cold start.
  PerformanceMonitor.startProcessClock();
  installGlobalErrorHandlers();
  PerformanceMonitor.instance.start();

  // Orientation is deliberately NOT locked.
  //
  // `setPreferredOrientations` is a blocking platform call that forces a
  // surface rotation, and it measured ~7 s of blocked main thread on a
  // software-rendered emulator — enough to trip the ANR watchdog before the
  // first frame. Every layout in the app is responsive and already handles
  // landscape and tablets, so locking bought nothing but a frozen launch.

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const ProviderScope(child: CompanionApp()));
}

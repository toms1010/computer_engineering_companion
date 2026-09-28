import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/app_theme.dart';
import '../core/error/error_boundary.dart';
import '../widgets/performance_watcher.dart';
import '../features/boot/boot_screen.dart';
import '../features/navigation/navigation_shell.dart';
import 'providers.dart';
import 'router.dart';
import '../features/learning/lesson_detail_screen.dart';
import '../features/learning/subject_detail_screen.dart';
import '../features/practice/quiz_screen.dart';
import '../features/assistant/assistant_screen.dart';
import '../features/bookmarks/bookmarks_screen.dart';
import '../features/notes/notes_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/formulas/formulas_screen.dart';
import '../features/references/references_screen.dart';
import '../features/diagnostics/diagnostics_screen.dart';
import '../features/calculators/binary_calculator_screen.dart';
import '../features/calculators/bitwise_calculator_screen.dart';
import '../features/calculators/calculus_calculator_screen.dart';
import '../features/calculators/electronics_calculator_screen.dart';
import '../features/calculators/networking_calculator_screen.dart';
import '../features/calculators/number_system_calculator_screen.dart';
import '../features/calculators/physics_calculator_screen.dart';
import '../features/simulators/cpu_scheduling_screen.dart';
import '../domain/entities/entities.dart';

/// Application root.
///
/// Keeps three concerns out of the widget tree: theme resolution, route
/// generation, and the top-level error/performance reporters.
class CompanionApp extends ConsumerWidget {
  const CompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return MaterialApp(
      title: 'Computer Engineering Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.of(Brightness.light),
      darkTheme: AppTheme.of(Brightness.dark),
      themeMode: themeMode,
      // Both are resolved once and cached, so switching theme does not
      // rebuild two `ThemeData` graphs from scratch.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      // A blocked or broken route shows a readable message rather than a
      // black screen.
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: AppErrorView(
            error: StateError('No route matches ${settings.name}'),
          ),
        ),
      ),
      onGenerateRoute: onGenerateRoute,
      home: const AppReadyReporter(child: BootScreen()),
    );
  }
}

/// Builds a route from the central table.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case AppRoutes.shell:
      return _fade(const NavigationShell(), settings);

    case AppRoutes.subject:
      final subject = args is Map ? args[RouteArgs.subject] as Subject? : args as Subject?;
      if (subject == null) return null;
      return _fade(SubjectDetailScreen(subject: subject), settings);

    case AppRoutes.lesson:
      final lesson = args is Map
          ? args[RouteArgs.lesson] as Lesson?
          : args is Lesson
              ? args
              : null;
      if (lesson == null) return null;
      return _fade(LessonDetailScreen(lesson: lesson), settings);

    case AppRoutes.quiz:
      final mode = args is Map
          ? QuizMode.fromLabel(args[RouteArgs.quizMode] as String? ?? '')
          : args is QuizMode
              ? args
              : QuizMode.quick;
      final subjectId = args is Map ? args[RouteArgs.subjectId] as int? : null;
      final lessonId = args is Map ? args[RouteArgs.lessonId] as int? : null;
      return _fade(
        QuizScreen(
          mode: mode,
          subjectId: subjectId,
          lessonId: lessonId,
        ),
        settings,
      );

    case AppRoutes.assistant:
      return _fade(const AssistantScreen(), settings);
    case AppRoutes.bookmarks:
      return _fade(const BookmarksScreen(), settings);
    case AppRoutes.notes:
      return _fade(const NotesScreen(), settings);
    case AppRoutes.progress:
      return _fade(const ProgressScreen(), settings);
    case AppRoutes.formulas:
      return _fade(const FormulasScreen(), settings);
    case AppRoutes.references:
      return _fade(const ReferencesScreen(), settings);
    case AppRoutes.diagnostics:
      return _fade(const DiagnosticsScreen(), settings);
    case AppRoutes.numberSystem:
      return _fade(const NumberSystemCalculatorScreen(), settings);
    case AppRoutes.binary:
      return _fade(const BinaryCalculatorScreen(), settings);
    case AppRoutes.bitwise:
      return _fade(const BitwiseCalculatorScreen(), settings);
    case AppRoutes.electronics:
      final tool = args is Map ? args[RouteArgs.toolId] as String? : null;
      return _fade(ElectronicsCalculatorScreen(initial: tool), settings);
    case AppRoutes.physics:
      return _fade(const PhysicsCalculatorScreen(), settings);
    case AppRoutes.networking:
      return _fade(const NetworkingCalculatorScreen(), settings);
    case AppRoutes.calculus:
      return _fade(const CalculusCalculatorScreen(), settings);
    case AppRoutes.cpuScheduling:
      return _fade(const CpuSchedulingScreen(), settings);
  }
  return null;
}

Route<T> _fade<T>(Widget page, RouteSettings settings) =>
    MaterialPageRoute<T>(builder: (_) => page, settings: settings);

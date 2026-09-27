import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/themes/app_theme.dart';
import '../features/navigation/navigation_shell.dart';
import '../features/splash/splash_screen.dart';
import 'app_providers.dart';

class CompanionApp extends ConsumerWidget {
  const CompanionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: themeMode,
      home: const SplashScreen(),
      routes: {
        '/shell': (_) => const NavigationShell(),
      },
    );
  }
}

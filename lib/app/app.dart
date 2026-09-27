import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/themes/app_theme.dart';
import 'app_providers.dart';
import '../features/navigation/navigation_shell.dart';

class CompanionApp extends ConsumerWidget {
  const CompanionApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      home: const NavigationShell());
}

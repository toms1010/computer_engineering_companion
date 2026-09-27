import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
        seedColor: const Color(0xff2456a6), brightness: brightness);
    final text =
        ThemeData(brightness: brightness).textTheme.apply(fontFamily: 'Roboto');
    return ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        textTheme: text,
        appBarTheme: AppBarTheme(
            centerTitle: false,
            backgroundColor: scheme.surface,
            scrolledUnderElevation: 0),
        cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: scheme.outlineVariant))),
        navigationBarTheme: NavigationBarThemeData(
            height: 72, indicatorColor: scheme.secondaryContainer),
        navigationRailTheme: NavigationRailThemeData(
            indicatorColor: scheme.secondaryContainer,
            labelType: NavigationRailLabelType.all),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.primary))),
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14))));
  }
}

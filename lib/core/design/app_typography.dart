import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Typography scale.
///
/// Built on the Material 3 type ramp with a single shared family so text
/// metrics are stable, plus semantic styles the feature layer can rely on.
/// Nothing in the app should construct a raw [TextStyle] for body copy.
abstract final class AppTypography {
  static const String monoFamily = 'monospace';

  static TextTheme textTheme(Brightness brightness) {
    final base = ThemeData(brightness: brightness).textTheme;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppThemeSeed.color,
      brightness: brightness,
    );

    TextStyle? style(TextStyle? s, {double? size, FontWeight? weight,
        double? height, double? spacing, Color? color}) {
      return s?.copyWith(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color,
      );
    }

    return base.copyWith(
      displaySmall: style(base.displaySmall,
          size: 34, weight: FontWeight.w800, height: 1.1, spacing: -0.5),
      headlineMedium: style(base.headlineMedium,
          size: 26, weight: FontWeight.w800, height: 1.2, spacing: -0.3),
      headlineSmall: style(base.headlineSmall,
          size: 22, weight: FontWeight.w700, height: 1.25),
      titleLarge: style(base.titleLarge, size: 19, weight: FontWeight.w700),
      titleMedium:
          style(base.titleMedium, size: 16, weight: FontWeight.w700, height: 1.3),
      titleSmall:
          style(base.titleSmall, size: 14, weight: FontWeight.w600, height: 1.3),
      bodyLarge: style(base.bodyLarge, size: 16, height: 1.5),
      bodyMedium: style(base.bodyMedium, size: 14.5, height: 1.45),
      bodySmall: style(base.bodySmall, size: 13, height: 1.4),
      labelLarge: style(base.labelLarge, size: 14, weight: FontWeight.w600),
      labelMedium: style(
          base.labelMedium, size: 12, weight: FontWeight.w700, spacing: 0.6),
      labelSmall: style(
          base.labelSmall, size: 11, weight: FontWeight.w600, spacing: 0.4),
    ).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  /// Monospaced style for code and formulas. Uses a smaller height so dense
  /// snippets do not dominate the screen.
  static TextStyle mono(BuildContext context, {double size = 13}) => TextStyle(
        fontFamily: monoFamily,
        fontSize: size,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Long-form reading style for lesson content.
  static TextStyle reading(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.65);

  /// All-caps micro heading used above sections.
  static TextStyle overline(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
}

/// Seed colour for the generated Material 3 scheme.
abstract final class AppThemeSeed {
  static const Color color = Color(0xFF2563EB);
}

/// Shared content padding so every screen has the same rhythm.
abstract final class AppLayout {
  static EdgeInsets get pageGutter =>
      const EdgeInsets.symmetric(horizontal: AppSpacing.gutter);

  static EdgeInsets get pagePadding => const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.sm,
        AppSpacing.gutter,
        AppSpacing.xxxl,
      );
}

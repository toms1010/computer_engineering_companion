import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'app_motion.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// The application theme.
///
/// Built once per [Brightness] and cached: rebuilding a [ThemeData] is
/// expensive, and `CompanionApp` rebuilds whenever the theme mode changes.
abstract final class AppTheme {
  static ThemeData? _light;
  static ThemeData? _dark;

  static ThemeData of(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return _dark ??= _build(Brightness.dark);
    }
    return _light ??= _build(Brightness.light);
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppThemeSeed.color,
      brightness: brightness,
    );
    final text = AppTypography.textTheme(brightness);
    final outline = scheme.outlineVariant.withValues(alpha: 0.6);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      // A single global page transition built on a transform/opacity
      // controller. Reusing one controller keeps transitions interruptible
      // and avoids allocating a new route animation per push.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeThroughTransitionBuilder(),
          TargetPlatform.iOS: _FadeThroughTransitionBuilder(),
        },
      ),
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
        side: BorderSide(color: outline),
        labelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      inputDecorationTheme: _inputTheme(scheme, text),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: text.labelLarge,
        )),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          textStyle: text.labelLarge,
        )),
      ),
      textButtonTheme: TextButtonThemeData(
        style: _buttonStyle(TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: text.labelLarge,
        )),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(text.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.large),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: scheme.surfaceContainerHighest,
        circularTrackColor: scheme.surfaceContainerHighest,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: AppRadius.small,
        ),
        textStyle: text.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Icon(Icons.check, size: 16, color: scheme.onPrimary)
              : null,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputTheme(ColorScheme scheme, TextTheme text) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: border(scheme.outlineVariant),
      enabledBorder: border(scheme.outlineVariant),
      focusedBorder: border(scheme.primary, 2),
      errorBorder: border(scheme.error),
      focusedErrorBorder: border(scheme.error, 2),
      labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
      helperStyle: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      errorStyle: text.bodySmall?.copyWith(color: scheme.error),
    );
  }

  static ButtonStyle _buttonStyle(ButtonStyle base) => base.copyWith(
        // Touch targets below 48dp fail accessibility guidance and are hard
        // to hit on a phone.
        minimumSize: const WidgetStatePropertyAll(
          Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 15)),
      );
}

/// Shared, cheap cross-fade route transition.
///
/// Deliberately transform + opacity only: no layout work, and it reuses a
/// single controller per push so a rapid back-and-forth does not queue up
/// animations.
class _FadeThroughTransitionBuilder extends PageTransitionsBuilder {
  const _FadeThroughTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: AppMotion.enter,
        reverseCurve: AppMotion.exit,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: AppMotion.enter)),
        child: child,
      ),
    );
  }
}

/// Convenience extensions used by feature code to read the current size
/// class without importing the design internals directly.
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => Responsive.of(this);
  bool get isCompact => Responsive.isCompact(this);
}

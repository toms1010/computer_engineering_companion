import 'package:flutter/widgets.dart';

import 'app_spacing.dart';

/// Layout size classes used across the application.
///
/// The app targets small phones first, then scales up to tablets. Widgets
/// branch on [ScreenSize] rather than on raw pixel numbers so a single
/// change here re-flows the whole application.
enum ScreenSize {
  /// Compact phones (roughly < 600dp wide).
  small,

  /// Standard / large phones and small foldables.
  medium,

  /// Large phones in landscape, small tablets.
  large,

  /// Tablets and desktop-sized windows.
  tablet;

  bool get isCompact => this == ScreenSize.small;
  bool get isExpanded => index >= ScreenSize.large.index;
  bool get isTablet => this == ScreenSize.tablet;

  /// True when content should be constrained to a readable measure and
  /// centred rather than stretched edge to edge.
  bool get constrainsContent => index >= ScreenSize.large.index;
}

/// Single source of truth for responsive breakpoints.
abstract final class Breakpoints {
  static const double medium = 600;
  static const double large = 900;
  static const double tablet = 1200;

  /// Classifies a raw width in logical pixels.
  static ScreenSize classify(double width) {
    if (width < medium) return ScreenSize.small;
    if (width < large) return ScreenSize.medium;
    if (width < tablet) return ScreenSize.large;
    return ScreenSize.tablet;
  }
}

/// Helpers for reading layout information with the narrowest possible
/// dependency, so a widget only rebuilds for the values it actually uses.
abstract final class Responsive {
  static ScreenSize of(BuildContext context) =>
      Breakpoints.classify(MediaQuery.sizeOf(context).width);

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) => of(context).isCompact;

  static bool isExpanded(BuildContext context) => of(context).isExpanded;

  static bool isTablet(BuildContext context) => of(context).isTablet;

  /// Number of columns for responsive grids. One source of truth so grids
  /// do not disagree between screens.
  static int columnsFor(BuildContext context, {int max = 4}) {
    return switch (of(context)) {
      ScreenSize.small => 2,
      ScreenSize.medium => max <= 2 ? max : 3,
      ScreenSize.large => max,
      ScreenSize.tablet => max + 1,
    };
  }

  /// Constrains [child] to a readable width and centres it, which prevents
  /// uncomfortably long line lengths on tablets and landscape phones.
  static Widget constrainReadable(
    BuildContext context,
    Widget child, {
    double maxWidth = AppSpacing.maxContentWidth,
  }) {
    final size = of(context);
    if (!size.constrainsContent) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Centralised spacing scale built on a 4pt grid.
///
/// Every padding, margin and gap in the application must come from this
/// scale. Hardcoded dimensions in feature code are a design-system
/// violation and drift the moment the density changes.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Horizontal page gutter used by every screen.
  static const double gutter = lg;

  /// Maximum readable measure. Beyond this, lines are too long to scan.
  static const double maxContentWidth = 840;

  /// Material accessibility guidance for interactive targets.
  static const double minTouchTarget = 48;
}

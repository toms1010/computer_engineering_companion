import 'package:flutter/widgets.dart';

/// Corner radius scale. Use the named `BorderRadius` constants rather than
/// constructing radii inline so shapes stay consistent across the app.
abstract final class AppRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double extraLarge = 26;
  static const double pill = 999;

  static const BorderRadius small = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius large = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xl =
      BorderRadius.all(Radius.circular(extraLarge));
  static const BorderRadius pillShape = BorderRadius.all(Radius.circular(pill));
}

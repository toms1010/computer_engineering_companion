import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_spacing.dart';

/// The app's single source of truth for system insets — the Flutter
/// equivalent of a `useSafeAreaInsets()` hook.
///
/// The app ships with `targetSdk 36`, so Android forces edge-to-edge on every
/// supported device: the window draws behind the status and navigation bars
/// and the platform will not inset the Flutter view for us. Every screen
/// therefore has to read its own insets, and every one of those reads must
/// agree. That is what this class is for.
///
/// Three different numbers matter, and mixing them up is the source of most
/// safe-area bugs:
///
/// | Value | Source | Keyboard-aware | Use for |
/// |---|---|---|---|
/// | Safe area | `padding` | yes | content that scrolls under the IME |
/// | Physical inset | `viewPadding` | no | bars that must stay pinned |
/// | Keyboard | `viewInsets` | — | keeping an input above the IME |
///
/// On a gesture-navigation phone the bottom inset is a short gesture handle
/// (~24dp). With 3-button navigation it is a full bar (~48dp). With a
/// cutout it is non-zero on the top and sometimes the side. Reading the real
/// value is the only way to get all of them right; a fixed `paddingBottom`
/// is either too small (content under the buttons) or too large (dead space).
abstract final class AppInsets {
  // ---------------------------------------------------------------------
  // Safe area — shrinks while the keyboard covers part of the window.
  // ---------------------------------------------------------------------

  /// Inset below content that is laid out above the system navigation bar.
  ///
  /// This is the value to reach for in the overwhelming majority of cases,
  /// because it is the one that stops meaning anything once the keyboard is
  /// open and overlapping the navigation bar.
  static double bottom(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom;

  /// Inset above content that sits below the status bar or a display cutout.
  static double top(BuildContext context) => MediaQuery.paddingOf(context).top;

  /// Horizontal safe area, non-zero only in landscape on a cutout display.
  static double horizontal(BuildContext context) =>
      MediaQuery.paddingOf(context).left + MediaQuery.paddingOf(context).right;

  /// The whole safe area, for the rare widget that wants it in one object.
  static EdgeInsets all(BuildContext context) => MediaQuery.paddingOf(context);

  // ---------------------------------------------------------------------
  // Physical insets — unaffected by the keyboard.
  // ---------------------------------------------------------------------

  /// Height of the system navigation area regardless of the keyboard.
  ///
  /// Use this for UI that must not move when the IME opens, such as a bottom
  /// navigation bar. This is what `SafeArea.maintainBottomViewPadding` and
  /// `NavigationBar.maintainBottomViewPadding` use internally.
  static double bottomStable(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).bottom;

  // ---------------------------------------------------------------------
  // Keyboard.
  // ---------------------------------------------------------------------

  /// Height the soft keyboard currently occupies.
  static double keyboard(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  /// How much of the window a cutout or notch steals, ignoring the keyboard.
  static double cutout(BuildContext context) =>
      MediaQuery.displayFeaturesOf(context)
          .fold<double>(0, (double max, f) => f.bounds.bottom > max ? f.bounds.bottom : max);

  // ---------------------------------------------------------------------
  // Composed paddings.
  // ---------------------------------------------------------------------

  /// Trailing space to append to a scrolling surface so its last row clears
  /// the system navigation area with the usual design rhythm on top.
  ///
  /// This is the direct replacement for a hard-coded bottom padding: on a
  /// gesture phone it is 24 + 24 = 48, with 3-button navigation 48 + 24 = 72,
  /// and with the keyboard open it collapses to just the design rhythm,
  /// because the safe area is then the keyboard and nothing else.
  static double scrollEnd(BuildContext context) =>
      bottom(context) + AppSpacing.xxl;

  /// Padding for a scrollable surface: the horizontal gutter on the sides and
  /// [scrollEnd] at the bottom.
  static EdgeInsets scrollPadding(BuildContext context, {double horizontal = AppSpacing.gutter}) =>
      EdgeInsets.fromLTRB(horizontal, 0, horizontal, scrollEnd(context));

  // ---------------------------------------------------------------------
  // System bar appearance.
  // ---------------------------------------------------------------------

  /// Icon brightness for the status and navigation bars, derived from the
  /// active theme.
  ///
  /// Without this the icons keep whatever colour the platform last used, so a
  /// light theme renders a white clock on a near-white app bar. Each is
  /// derived independently, because a translucent scrim over the navigation
  /// bar can be lighter than the surface behind the status bar.
  static Brightness barBrightness(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark;

  /// Fully transparent system bars with readable icons.
  ///
  /// Contrast enforcement is switched off for both bars: Android's automatic
  /// scrim is what produces the grey band behind a transparent navigation bar
  /// in 3-button mode, and it does not match the app's surface colour.
  static SystemUiOverlayStyle barStyle(BuildContext context) {
    final brightness = barBrightness(context);
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: brightness,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    );
  }

  /// Applies [barStyle] to everything below this point in the tree.
  static Widget applyBarStyle(BuildContext context, Widget child) =>
      AnnotatedRegion<SystemUiOverlayStyle>(value: barStyle(context), child: child);
}

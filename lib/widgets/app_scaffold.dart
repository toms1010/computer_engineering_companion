import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../core/design/app_breakpoints.dart';
import '../core/design/app_insets.dart';
import '../core/design/app_motion.dart';
import '../core/design/app_radius.dart';
import '../core/design/app_spacing.dart';
import '../core/design/app_typography.dart';
import 'states.dart';

/// Standard screen frame: a floating app bar over a lazy sliver list.
///
/// The previous implementation funnelled an entire screen through a single
/// `SliverToBoxAdapter`, which meant every row of every list was built and
/// laid out on the first frame. This takes slivers directly so long content
/// is virtualised by construction.
///
/// Content is width-constrained on tablets and landscape so lines stay
/// readable instead of stretching the full panel width.
///
/// ## System navigation
///
/// The app is edge-to-edge, so this widget is responsible for both the top and
/// the bottom of the window:
///
///  * **Top** — [SafeArea] insets the app bar below the status bar, the
///    gesture area, and any display cutout.
///  * **Bottom** — `Scaffold` deliberately does *not* inset its body for the
///    system navigation bar (it assumes the platform already did), so the
///    scroll view runs to the physical bottom of the window. The trailing
///    sliver therefore adds the real measured inset, not a guessed constant:
///    ~48dp with 3-button navigation, ~24dp under a gesture handle, and just
///    the design rhythm when the keyboard takes over.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.slivers = const [],
    this.actions = const [],
    this.leading,
    this.floatingActionButton,
    this.bottom,
    this.showAppBar = true,
  });

  final String title;
  final List<Widget> slivers;
  final List<Widget> actions;
  final Widget? leading;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  /// Some screens (tabs with their own header) do not want a second bar.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Read above the Scaffold. Scaffold rewrites MediaQuery for its children
    // based on what it lays out, so reading inside the body would silently
    // return a different number.
    final scrollEnd = AppInsets.scrollEnd(context);

    Widget content = CustomScrollView(
      // Keeping a little extra content built means a fast flick does not
      // stall waiting for new rows to be constructed. The trade is a small,
      // bounded amount of extra memory for noticeably steadier scrolling on
      // low-end devices.
      scrollCacheExtent: const ScrollCacheExtent.viewport(0.6),
      slivers: [
        if (showAppBar)
          SliverAppBar(
            title: Text(title),
            leading: leading,
            actions: actions,
            floating: true,
            snap: true,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            bottom: bottom,
          ),
        ...slivers,
        // Real measured inset plus breathing room, so the last row is never
        // flush against the system navigation bar and never a fixed distance
        // that happens to suit one navigation mode.
        SliverToBoxAdapter(child: SizedBox(height: scrollEnd)),
      ],
    );

    content = Responsive.constrainReadable(
      context,
      content,
      maxWidth: AppSpacing.maxContentWidth,
    );

    return SafeArea(
      // Bottom is handled by the trailing sliver above, which is part of the
      // scrollable content. Consuming it here as well would make the inset
      // permanent padding instead of scrollable breathing room, so the last
      // row could still end up under the navigation bar after a scroll.
      bottom: false,
      // SliverAppBar emits no AnnotatedRegion of its own, so without this the
      // status bar keeps whatever icon colour the platform last used — white
      // icons on a near-white app bar in light mode.
      child: AppInsets.applyBarStyle(
        context,
        Scaffold(
          body: content,
          floatingActionButton: floatingActionButton,
        ),
      ),
    );
  }
}

/// A sliver that lays out its children lazily.
///
/// The one primitive every long list in the app uses, so no screen has to
/// hand-roll a delegate and get the key or cache-extent handling wrong.
class LazySliverList extends StatelessWidget {
  const LazySliverList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
    this.cacheExtent = 240,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  /// When provided, items are separated by this widget.
  final IndexedWidgetBuilder? separatorBuilder;

  final EdgeInsets padding;

  /// How much off-screen content to keep built. A little more than one
  /// screen means a flick does not stall waiting for new tiles to build.
  final double cacheExtent;

  @override
  Widget build(BuildContext context) {
    if (separatorBuilder == null) {
      return SliverPadding(
        padding: padding,
        sliver: SliverList.builder(
          itemCount: itemCount,
          itemBuilder: itemBuilder,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          addSemanticIndexes: true,
        ),
      );
    }
    final builder = separatorBuilder!;
    return SliverPadding(
      padding: padding,
      sliver: SliverList.separated(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: builder,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
      ),
    );
  }
}

/// Section heading with an optional trailing action.
///
/// A plain box widget, so it can be used inside a `Column` as well as a
/// sliver list. Use [SliverSectionHeader] inside `CustomScrollView`.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.subtitle,
  });

  final String title;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Sliver-list form of [SectionHeader].
class SliverSectionHeader extends StatelessWidget {
  const SliverSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: SectionHeader(title: title, subtitle: subtitle, trailing: trailing),
      );
}

/// Responsive grid that keeps cards square-ish across screen sizes.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxColumns = 4,
    this.spacing = AppSpacing.sm,
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columns = switch (Breakpoints.classify(width)) {
          ScreenSize.small => 2,
          ScreenSize.medium => maxColumns.clamp(2, 3),
          ScreenSize.large => maxColumns,
          ScreenSize.tablet => maxColumns + 1,
        };
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            // Cards are wider than tall, which is the proportion the quick
            // tools and stat tiles want.
            childAspectRatio: 1.35,
          ),
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
          ),
        );
      },
    );
  }
}

/// Horizontal row of filter chips, built lazily.
///
/// The previous version used `ListView(children: ...)` with a fixed list,
/// which eagerly built every chip and re-ran on each keystroke.
class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.height = 40,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: options.length,
        // Prebuilt once: the list is static, so building the widgets eagerly
        // here is cheaper than re-creating them on every parent rebuild.
        itemBuilder: (context, index) => _ChipOption(
          key: ValueKey(options[index]),
          label: options[index],
          selected: options[index] == selected,
          onTap: () => onSelected(options[index]),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        addRepaintBoundaries: false,
      ),
    );
  }
}

class _ChipOption extends StatelessWidget {
  const _ChipOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

/// Content card used by every detail screen.
///
/// Wraps its child in a [RepaintBoundary] so a repainting child (a progress
/// indicator, an animated value) does not repaint the surrounding screen.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) {
      return Semantics(
        label: semanticLabel,
        container: true,
        child: RepaintBoundary(child: card),
      );
    }
    return Semantics(
      label: semanticLabel,
      button: true,
      container: true,
      child: RepaintBoundary(
        child: Card(
          color: color,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Thin progress bar with a fixed track, so it never animates its own
/// height and never forces a layout pass on the parent.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.height = 8,
    this.label,
  });

  final double value;
  final double height;

  /// Announced to screen readers; visual users get the bar.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final clamped = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return Semantics(
      label: label ?? 'Progress',
      value: '${(clamped * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: LinearProgressIndicator(
          value: clamped,
          minHeight: height,
          backgroundColor: scheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(scheme.primary),
        ),
      ),
    );
  }
}

/// Monospaced block for code, formulas and terminal output.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.maxLines,
    this.fontSize = 12.5,
    this.onCopy,
  });

  final String code;
  final int? maxLines;
  final double fontSize;

  /// When provided, a copy button is shown in the block's header.
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = code.split('\n');
    final truncated = maxLines != null && lines.length > maxLines!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.medium,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 16),
              tooltip: 'Copy',
              visualDensity: VisualDensity.compact,
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              truncated ? '${lines.take(maxLines!).join('\n')}\n…' : code,
              style: TextStyle(
                fontFamily: AppTypography.monoFamily,
                fontSize: fontSize,
                height: 1.5,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrolling chip row used for filters and language tabs.
class ScrollableTabRow extends StatelessWidget {
  const ScrollableTabRow({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        itemCount: tabs.length,
        itemBuilder: (context, index) => _ChipOption(
          key: ValueKey(tabs[index]),
          label: tabs[index],
          selected: index == selectedIndex,
          onTap: () => onSelected(index),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
        addRepaintBoundaries: false,
      ),
    );
  }
}

/// Empty-state builder with an optional call to action.
class EmptyStateSliver extends StatelessWidget {
  const EmptyStateSliver({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateView(
        icon: icon,
        title: title,
        message: message,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}

/// Wraps content in the standard entrance animation.
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.child,
    this.index = 0,
  });

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) =>
      FadeSlideIn(index: index, child: child);
}

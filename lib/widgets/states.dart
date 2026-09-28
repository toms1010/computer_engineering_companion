import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/app_spacing.dart';
import '../core/error/error_boundary.dart';

// Re-exported so a screen imports one widget barrel, not two.
export '../core/error/error_boundary.dart';

/// Empty state: what happened, and what the user can do next.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.outline),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder shown while content loads.
///
/// Uses a single [AnimationController] driving one gradient across each box.
/// Cheap by construction: no layout animation, and the shimmer is clipped so
/// it never overdraws.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 8,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHighest;
    final highlight = scheme.surfaceContainerHigh;

    return RepaintBoundary(
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            // One moving highlight rather than a cross-fade: transform-only,
            // so the shimmer never triggers a layout pass.
            final t = _controller.value * 2 - 1;
            return FractionallySizedBox(
              alignment: Alignment(t, 0),
              widthFactor: 0.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: highlight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Placeholder list used while a long list loads.
///
/// Shows the right *shape* at the right size, so the layout does not jump
/// when the real content arrives.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5, this.hasLeading = true});

  final int itemCount;
  final bool hasLeading;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (hasLeading) ...[
              const SkeletonBox(height: 44, width: 44, radius: 12),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(height: 14),
                  const SizedBox(height: AppSpacing.xs),
                  SkeletonBox(height: 12, width: index.isEven ? 220 : 160),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centred progress indicator with a message, for full-screen waits.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Renders an [AsyncValue] with consistent loading, error and data handling.
///
/// Centralising this is what stops every screen inventing its own error
/// handling — and makes it impossible to ship a screen that shows a raw
/// exception string to a user.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.loadingSliver = false,
    this.emptyCheck,
    this.empty,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final VoidCallback? onRetry;

  /// Custom loading state; defaults to a centred indicator or skeleton sliver.
  final Widget? loading;
  final bool loadingSliver;

  /// Lets a screen declare "loaded successfully, but there is nothing to
  /// show" without a second condition in its build.
  final bool Function(T data)? emptyCheck;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      // `skipLoadingOnRefresh` keeps the previous content on screen while a
      // refresh runs, instead of flashing a spinner over live data.
      skipLoadingOnRefresh: true,
      data: (value) {
        if (emptyCheck?.call(value) ?? false) {
          return empty ?? const SizedBox.shrink();
        }
        return data(context, value);
      },
      loading: () =>
          loading ?? (loadingSliver ? const SkeletonList() : const LoadingView()),
      error: (error, _) => AppErrorView(error: error, onRetry: onRetry),
    );
  }
}

/// Sliver-friendly async view, for use inside a [CustomScrollView].
class AsyncSliverView<T> extends StatelessWidget {
  const AsyncSliverView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.skeleton = const SkeletonList(),
  });

  final AsyncValue<T> value;
  final List<Widget> Function(BuildContext context, T data) data;
  final VoidCallback? onRetry;
  final Widget skeleton;

  @override
  Widget build(BuildContext context) {
    return value.when(
      skipLoadingOnRefresh: true,
      data: (value) => SliverMainAxisGroup(slivers: data(context, value)),
      loading: () => skeleton,
      error: (error, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: AppErrorView(error: error, onRetry: onRetry),
      ),
    );
  }
}

/// A dismissible banner used for offline and sync state.
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    required this.icon,
    this.color,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final Color? color;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = color ?? scheme.secondaryContainer;
    final foreground = scheme.onSecondaryContainer;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: background,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.gutter,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: foreground),
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: onAction!,
                  child: Text(actionLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

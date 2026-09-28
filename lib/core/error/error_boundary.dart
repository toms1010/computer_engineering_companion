import 'package:flutter/material.dart';

import '../design/app_spacing.dart';
import 'app_exception.dart';

/// Renders a readable, actionable error panel.
///
/// [onRetry] is what separates a dead end from a recoverable state, so pass it
/// wherever a retry is actually possible — an offline banner without a retry
/// is just a dead end.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  /// Accepts a normalised or a raw error. Raw errors are converted, so the
  /// user never sees a stack trace or a raw driver message.
  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalised = normaliseError(error);
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final canRetry = onRetry != null;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? AppSpacing.lg : AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              normalised is NetworkException
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              size: compact ? 36 : 52,
              color: scheme.error,
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
            Text(
              _headlineFor(normalised),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              normalised.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (canRetry) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _headlineFor(AppException error) => switch (error) {
        NetworkException(isOffline: true) => 'You are offline',
        NetworkException(isTimeout: true) => 'That took too long',
        DatabaseException() => 'Local data unavailable',
        ValidationException() => 'Check your input',
        NotFoundException() => 'Not found',
        AiException() => 'Assistant unavailable',
        CancelledException() => 'Stopped',
        _ => 'Something went wrong',
      };
}

/// Placeholder substituted for a widget that failed to build.
///
/// Sized to a stable height so one broken tile does not cause the list around
/// it to reflow as it streams in.
class ErrorFallback extends StatelessWidget {
  const ErrorFallback({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Card(
        color: scheme.errorContainer.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: scheme.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onErrorContainer),
                ),
              ),
              if (onRetry != null)
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 18),
                  tooltip: 'Retry',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

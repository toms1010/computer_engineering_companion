import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/design/app_motion.dart';
import '../../core/design/app_spacing.dart';
import '../../core/error/error_boundary.dart';
import '../../widgets/states.dart';

/// Gate between process start and the usable app.
///
/// The previous splash slept for a fixed 800 ms regardless of how long
/// startup actually took, which made a warm launch feel slow and a cold
/// launch look frozen. This screen shows real work:
///
///  * while the database opens it reports the first-run seed progress;
///  * it navigates as soon as the database is ready, with no fixed delay;
///  * if the database cannot open it offers a retry instead of a dead end.
class BootScreen extends ConsumerWidget {
  const BootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(databaseBootstrapProvider);

    return Scaffold(
      body: bootstrap.when(
        data: (state) {
          if (state.isReady) {
            // Deferred to the next frame so the first shell frame is not
            // pushed out by a navigation during the same build.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
            });
            return const _BootBody();
          }
          return _BootBody(
            message: 'Preparing your curriculum…',
            progress: state.progress,
          );
        },
        loading: () => const _BootBody(
          message: 'Opening local database…',
        ),
        error: (error, _) => Scaffold(
          body: AppErrorView(
            error: error,
            onRetry: () => ref.invalidate(databaseBootstrapProvider),
          ),
        ),
      ),
    );
  }
}

class _BootBody extends StatelessWidget {
  const _BootBody({this.message, this.progress});

  final String? message;
  final double? progress;

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
            ScaleFadeIn(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.xxl),
                ),
                child: Icon(
                  Icons.memory,
                  size: 46,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Computer Engineering',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              'Companion',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            // A determinate bar during the one-time seed, indeterminate
            // otherwise. Both live in a fixed-height box so the layout does
            // not shift when progress becomes known.
            SizedBox(
              height: 28,
              child: Center(
                child: progress == null
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Semantics(
                        label: message ?? 'Loading',
                        value: '${(progress! * 100).round()}%',
                        child: SizedBox(
                          width: 180,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: AppMotion.fast,
                            builder: (context, value, _) => LinearProgressIndicator(
                              value: value,
                              minHeight: 6,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

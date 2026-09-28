import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../data/repositories/companion_repository.dart';
import '../../core/design/app_spacing.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/inputs.dart';
import '../../widgets/performance_watcher.dart';

/// Preferences, data management and diagnostics entry points.
///
/// Note the counts below: they are read through `select`, so saving a note no
/// longer rebuilds this entire screen. The previous version watched the full
/// note and bookmark lists purely to print a number.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final name = ref.watch(profileNameProvider).valueOrNull ??
        ProfileNameNotifier.fallback;
    final noteCount = ref.watch(
        notesProvider.select((async) => async.valueOrNull?.length ?? 0));
    final bookmarkCount = ref.watch(
        bookmarksProvider.select((async) => async.valueOrNull?.length ?? 0));
    final syncStatus = ref.watch(syncStatusProvider).valueOrNull;
    final remoteAiEnabled = ref.watch(remoteAiEnabledProvider);
    final diagnostics = ref.watch(diagnosticsEnabledProvider);
    final repository = ref.read(repositoryProvider);

    return ScreenPerformanceWatcher(
      name: 'Settings',
      child: AppScaffold(
        title: 'Settings',
        slivers: [
          const SliverSectionHeader(title: 'Profile'),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  AppListRow(
                    leading: const Icon(Icons.person_outline),
                    title: name,
                    subtitle: const Text('Tap to rename'),
                    onTap: () => _editName(context, ref),
                  ),
                ],
              ),
            ),
          ),

          const SliverSectionHeader(title: 'Appearance'),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  // RadioGroup manages a single value for all three options,
                  // replacing the deprecated per-tile groupValue/onChanged.
                  child: RadioGroup<ThemeMode>(
                    groupValue: themeMode,
                    onChanged: (mode) {
                      if (mode != null) {
                        ref.read(themeModeProvider.notifier).set(mode);
                      }
                    },
                    child: const Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.system,
                          title: Text('Match system'),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.light,
                          title: Text('Light'),
                        ),
                        RadioListTile<ThemeMode>(
                          value: ThemeMode.dark,
                          title: Text('Dark'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SliverSectionHeader(
              title: 'Data',
              subtitle: 'Everything is stored on this device',
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  AppListRow(
                    leading: const Icon(Icons.sticky_note_2_outlined),
                    title: 'Notes',
                    subtitle: Text('$noteCount saved locally'),
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.notes),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListRow(
                    leading: const Icon(Icons.bookmark_outline),
                    title: 'Bookmarks',
                    subtitle: Text('$bookmarkCount saved locally'),
                    onTap: () => Navigator.of(context)
                        .pushNamed(AppRoutes.bookmarks),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListRow(
                    leading: const Icon(Icons.sync),
                    title: 'Sync',
                    subtitle: Text(syncStatus?.label ?? 'Checking…'),
                    trailing: syncStatus?.isBackendConfigured ?? false
                        ? IconButton(
                            onPressed: () => _syncNow(context, ref),
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Sync now',
                          )
                        : null,
                    onTap: null,
                  ),
                ],
              ),
            ),
          ),

          const SliverSectionHeader(
              title: 'Assistant',
              subtitle: 'On-device by default',
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Card(
                child: SwitchListTile(
                  value: remoteAiEnabled,
                  onChanged: (value) => _toggleRemote(context, ref, value),
                  title: const Text('Allow a cloud assistant'),
                  subtitle: const Text(
                    'Off by default. Your questions, notes and progress are '
                    'never uploaded unless you turn this on and supply your '
                    'own provider key.',
                  ),
                  secondary: const Icon(Icons.cloud_outlined),
                ),
              ),
            ),
          ),

          const SliverSectionHeader(title: 'About'),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              child: Column(
                children: [
                  AppListRow(
                    leading: const Icon(Icons.speed_outlined),
                    title: 'Performance & diagnostics',
                    subtitle: Text(diagnostics
                        ? 'Enabled — startup, frame and query timings'
                        : 'Tap to enable'),
                    onTap: () => _toggleDiagnostics(context, ref, diagnostics),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const AppListRow(
                    leading: Icon(Icons.info_outline),
                    title: 'Offline-first',
                    subtitle: Text(
                      'The app never needs a network. Nothing is uploaded '
                      'unless you explicitly enable the cloud assistant.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.tonalIcon(
                    onPressed: () => _reset(context, ref, repository),
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset all data'),
                    style: FilledButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final current = ref.read(profileNameProvider).valueOrNull ??
        ProfileNameNotifier.fallback;
    final result = await showTextInputDialog(
      context,
      title: 'Your name',
      label: 'Name',
      initialValue: current,
      maxLength: 40,
    );
    if (result == null) return;
    await ref.read(profileNameProvider.notifier).set(result);
    if (context.mounted) {
      showAppSnackBar(context, 'Name updated', icon: Icons.check);
    }
  }

  Future<void> _toggleRemote(
      BuildContext context, WidgetRef ref, bool value) async {
    if (value) {
      final confirmed = await confirmDialog(
        context,
        title: 'Use a cloud assistant?',
        message:
            'Questions you type will be sent to the provider you configure. '
            'Notes, progress and the local database are never sent. '
            'You can turn this off at any time.',
        confirmLabel: 'Continue',
      );
      if (!confirmed) return;
    }
    ref.read(remoteAiEnabledProvider.notifier).state = value;
    if (context.mounted) {
      showAppSnackBar(
        context,
        value ? 'Cloud assistant enabled' : 'Using on-device assistant only',
        icon: value ? Icons.cloud_done : Icons.phonelink_lock,
      );
    }
  }

  void _toggleDiagnostics(BuildContext context, WidgetRef ref, bool current) {
    ref.read(diagnosticsEnabledProvider.notifier).state = !current;
    showAppSnackBar(
      context,
      !current ? 'Diagnostics enabled' : 'Diagnostics hidden',
      icon: Icons.speed,
    );
  }

  Future<void> _syncNow(BuildContext context, WidgetRef ref) async {
    final outcome = await ref.read(syncServiceProvider).syncNow();
    if (!context.mounted) return;
    if (outcome.skippedBecauseOffline) {
      showAppSnackBar(context, 'Offline — your changes are still saved here',
          icon: Icons.wifi_off);
    } else if (outcome.skippedBecauseUnconfigured) {
      showAppSnackBar(context, 'No cloud service is configured',
          icon: Icons.cloud_off);
    } else if (outcome.failed > 0) {
      showAppSnackBar(context, '${outcome.failed} change(s) could not be sent',
          icon: Icons.error_outline);
    } else {
      showAppSnackBar(context, 'Synced ${outcome.pushed} change(s)',
          icon: Icons.cloud_done);
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref,
      CompanionRepository repository) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Reset all data?',
      message:
          'This deletes your notes, bookmarks, quiz history, lesson progress '
          'and any pending sync queue, then restores the bundled curriculum. '
          'It cannot be undone.',
      confirmLabel: 'Reset everything',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    // Confirmation is an explicit user action, so a spinner here is correct.
    showAppSnackBar(context, 'Resetting…');
    await repository.resetAll();
    ref.read(aiServiceProvider).invalidate();
    ref
      ..invalidate(subjectsProvider)
      ..invalidate(activitiesProvider)
      ..invalidate(quizAttemptsProvider)
      ..invalidate(progressStatsProvider)
      ..invalidate(notesProvider)
      ..invalidate(bookmarksProvider)
      ..invalidate(formulasProvider(null))
      ..invalidate(referencesProvider(null))
      ..invalidate(aiIndexReadyProvider);
    if (context.mounted) {
      showAppSnackBar(context, 'Data reset', icon: Icons.check_circle);
    }
  }
}

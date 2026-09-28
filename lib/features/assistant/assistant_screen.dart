import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/design/app_motion.dart';
import '../../core/design/app_spacing.dart';
import '../../services/ai/ai_models.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/cards.dart';
import '../../widgets/performance_watcher.dart';

/// On-device study assistant.
///
/// Everything here runs on the phone. The screen states this explicitly, so
/// the user is never unsure whether a question left the device — the privacy
/// requirement is a visible property of the UI, not a footnote in settings.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Message> _messages = [];
  bool _asking = false;
  bool _indexReady = false;

  @override
  void initState() {
    super.initState();
    // Built lazily on first use, off the UI thread, so opening the tab is
    // instant and the user can type while the index is still compiling.
    ref.listen(aiIndexReadyProvider, (_, next) {
      next.whenData((ready) {
        if (mounted) setState(() => _indexReady = ready);
      });
    });
    _startIndexing();
  }

  Future<void> _startIndexing() async {
    try {
      await ref.read(aiIndexReadyProvider.future);
      if (mounted) {
        setState(() => _indexReady = true);
        _addGreeting();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(_Message.system(
              'The local index could not be built. Restart the app and try again.'));
        });
      }
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _addGreeting() {
    if (_messages.isNotEmpty) return;
    _messages.add(_Message.assistant(
      'I answer from the curriculum installed on this device — '
      '340 lessons, 39 formulas and a code reference. Nothing you type '
      'is sent anywhere.\n\nTry "what is deadlock", '
      '"how do I subnet a class C network" or "why does context switching cost time".',
    ));
  }

  Future<void> _ask(String prompt) async {
    final question = prompt.trim();
    if (question.isEmpty || _asking) return;

    setState(() {
      _messages.add(_Message.user(question));
      _asking = true;
    });
    _input.clear();
    _scrollToEnd();

    try {
      final answer =
          await ref.read(aiServiceProvider).ask(AiRequest(prompt: question));
      if (!mounted) return;
      setState(() {
        _messages.add(_Message.answer(answer));
        _asking = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Message.system(
            'The assistant could not answer that. $error'.replaceAll(
                'Exception: ', '')));
        _asking = false;
      });
    }
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: AppMotion.normal,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final recommendations = ref.watch(recommendationsProvider);

    return ScreenPerformanceWatcher(
      name: 'Assistant',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assistant'),
          actions: [
            // Privacy state is always visible, not buried in settings.
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Center(
                child: Pill(
                  label: ref.watch(remoteAiEnabledProvider)
                      ? 'On-device + optional cloud'
                      : 'On-device only',
                  icon: Icons.phonelink_lock_outlined,
                  dense: true,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (!_indexReady)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: _messages.isEmpty
                  ? _AssistantIntro(onAsk: _ask)
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: _messages.length + (recommendations.valueOrNull?.isNotEmpty == true ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _MessageBubble(message: _messages[index]);
                        }
                        return _Recommendations(
                          items: recommendations.valueOrNull ?? const [],
                        );
                      },
                    ),
            ),
            if (_asking) const LinearProgressIndicator(minHeight: 2),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _ask,
                        decoration: const InputDecoration(
                          hintText: 'Ask about a topic…',
                          prefixIcon: Icon(Icons.search, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: _asking ? null : () => _ask(_input.text),
                      icon: const Icon(Icons.send),
                      tooltip: 'Ask',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantIntro extends StatelessWidget {
  const _AssistantIntro({required this.onAsk});

  final ValueChanged<String> onAsk;

  static const _samples = [
    'What is deadlock?',
    'How do I subnet a class C network?',
    'Why does context switching cost time?',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xl),
        Icon(Icons.auto_awesome,
            size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: AppSpacing.lg),
        Text('Ask anything from the syllabus',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Answers are generated on this device from the bundled '
          'curriculum. No internet, no account, nothing uploaded.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final sample in _samples)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ActionChip(
              avatar: const Icon(Icons.north_east, size: 15),
              label: Text(sample),
              onPressed: () => onAsk(sample),
            ),
          ),
      ],
    );
  }
}

class _Recommendations extends StatelessWidget {
  const _Recommendations({required this.items});

  final List<StudyRecommendation> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recommended next'),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppListRow(
              title: item.title,
              subtitle: Text(item.reason),
              leading: const Icon(Icons.arrow_forward),
            ),
          ),
      ],
    );
  }
}

/// A single entry in the conversation.
class _Message {
  const _Message._(this.text, this.kind, {this.answer});

  factory _Message.user(String text) => _Message._(text, _Kind.user);
  factory _Message.assistant(String text) => _Message._(text, _Kind.assistant);
  factory _Message.system(String text) => _Message._(text, _Kind.system);
  factory _Message.answer(AiAnswer answer) =>
      _Message._(answer.text, _Kind.answer, answer: answer);

  final String text;
  final _Kind kind;
  final AiAnswer? answer;
}

enum _Kind { user, assistant, answer, system }

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (alignment, background, foreground) = switch (message.kind) {
      _Kind.user => (
          Alignment.centerRight,
          scheme.primary,
          scheme.onPrimary,
        ),
      _Kind.assistant => (
          Alignment.centerLeft,
          scheme.surfaceContainerHigh,
          scheme.onSurface,
        ),
      _Kind.answer => (
          Alignment.centerLeft,
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
        ),
      _Kind.system => (
          Alignment.centerLeft,
          scheme.errorContainer,
          scheme.onErrorContainer,
        ),
    };

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lightweight markdown: **bold** headings and a trailing source
            // line. A full markdown renderer would be a large dependency for
            // two features the local engine can emit.
            SelectableText.rich(
              _renderInline(message.text),
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
            if (message.answer != null &&
                message.answer!.citations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Divider(color: foreground.withValues(alpha: 0.2)),
              const SizedBox(height: AppSpacing.xs),
              Text('Sources', style: theme.textTheme.labelMedium?.copyWith(color: foreground)),
              for (final citation in message.answer!.citations)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    '• ${citation.title} — ${citation.snippet}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foreground.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
            if (message.answer != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${message.answer!.source == AiSource.local ? 'Answered on this device' : 'Answered by your cloud provider'}'
                ' in ${(message.answer!.elapsed.inMicroseconds / 1000).round()} ms',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Converts `**bold**` runs into bold spans.
  static TextSpan _renderInline(String text) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var index = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      index = match.end;
    }
    if (index < text.length) spans.add(TextSpan(text: text.substring(index)));
    return TextSpan(children: spans);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design/app_spacing.dart';
import '../core/design/app_typography.dart';

/// Debounced search field.
///
/// The previous implementation called `setState` on every keystroke, which
/// re-filtered the entire list and re-created every row. This holds a
/// [TextEditingController] (disposed with the widget), debounces the query
/// and clears cleanly.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Search',
    this.debounce = const Duration(milliseconds: 250),
    this.autofocus = false,
    this.onSubmitted,
  });

  /// Called with the debounced, trimmed query.
  final ValueChanged<String> onChanged;

  final String hint;
  final Duration debounce;
  final bool autofocus;

  /// Called immediately on keyboard submit, bypassing the debounce.
  final ValueChanged<String>? onSubmitted;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    // A pending debounce would otherwise call `onChanged` after unmount.
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      if (mounted) widget.onChanged(value.trim());
    });
    setState(() {}); // only to toggle the clear button
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onChanged('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: _onChanged,
        onSubmitted: (value) {
          _debounceTimer?.cancel();
          final query = value.trim();
          widget.onChanged(query);
          widget.onSubmitted?.call(query);
        },
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: _clear,
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Clear search',
                ),
        ),
      ),
    );
  }
}

/// Shows a snack bar using the app's shared styling, replacing the previous
/// screen and clearing any queued one so messages do not stack up.
void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: duration,
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.onInverseSurface),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(child: Text(message)),
        ],
      ),
      action: action,
    ));
}

/// Copies [text] and confirms it, with an optional label in the message.
Future<void> copyToClipboard(
  BuildContext context,
  String text, {
  String? label,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    showAppSnackBar(context, 'Copied${label == null ? '' : ' $label'}',
        icon: Icons.check_circle_outline);
  }
}

/// Confirmation dialog. Returns true only on explicit confirmation.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Single-field text dialog with validation and proper controller disposal.
///
/// The previous profile dialog created a [TextEditingController] and never
/// disposed it, leaking on every edit. This is a self-contained stateful
/// widget, so the controller's lifetime matches the dialog's.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  String? label,
  String? initialValue,
  String confirmLabel = 'Save',
  int? maxLength,
  TextInputType? keyboardType,
  String? helperText,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      label: label,
      initialValue: initialValue,
      confirmLabel: confirmLabel,
      maxLength: maxLength,
      keyboardType: keyboardType,
      helperText: helperText,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.confirmLabel,
    this.label,
    this.initialValue,
    this.maxLength,
    this.keyboardType,
    this.helperText,
  });

  final String title, confirmLabel;
  final String? label, helperText;
  final String? initialValue;
  final int? maxLength;
  final TextInputType? keyboardType;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: widget.label,
            helperText: widget.helperText,
          ),
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'This cannot be empty.'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Label + monospaced value row used across calculator and detail screens.
class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
    this.selectable = false,
  });

  final String label, value;
  final bool mono, selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = mono
        ? AppTypography.mono(context, size: 13)
        : theme.textTheme.bodyMedium;
    final text = Text(
      value,
      style: valueStyle,
      maxLines: mono ? 3 : 4,
      overflow: TextOverflow.ellipsis,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xxs),
        if (selectable) SelectableText(value, style: valueStyle) else text,
      ],
    );
  }
}

/// Labelled form field wrapper, so screens do not repeat the spacing.
class FormSection extends StatelessWidget {
  const FormSection({
    super.key,
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        if (hint != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            hint!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

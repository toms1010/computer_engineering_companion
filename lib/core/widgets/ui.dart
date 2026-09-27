import 'package:flutter/material.dart';

class PageFrame extends StatelessWidget {
  const PageFrame(
      {super.key,
      required this.title,
      required this.child,
      this.actions = const []});
  final String title;
  final Widget child;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: CustomScrollView(slivers: [
                SliverAppBar(
                    title: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    actions: actions),
                SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    sliver: SliverToBoxAdapter(child: child))
              ]))));
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800)));
}

class ProgressLine extends StatelessWidget {
  const ProgressLine(this.value, {super.key});
  final double value;
  @override
  Widget build(BuildContext context) => ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 8));
}

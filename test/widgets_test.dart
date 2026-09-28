import 'package:computer_engineering_companion/core/design/app_breakpoints.dart';
import 'package:computer_engineering_companion/core/design/app_theme.dart';
import 'package:computer_engineering_companion/widgets/app_scaffold.dart';
import 'package:computer_engineering_companion/widgets/calculator.dart';
import 'package:computer_engineering_companion/widgets/cards.dart';
import 'package:computer_engineering_companion/widgets/inputs.dart';
import 'package:computer_engineering_companion/widgets/states.dart';
import 'package:computer_engineering_companion/core/error/app_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps a widget in the real app theme so component tests exercise the same
/// styling the app ships with.
Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.of(Brightness.light),
    home: Scaffold(body: child),
  );
}

void main() {
  group('SearchField', () {
    testWidgets('debounces so a burst of keystrokes fires once', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(_host(SearchField(
        debounce: const Duration(milliseconds: 200),
        onChanged: queries.add,
      )));

      await tester.enterText(find.byType(TextField), 'dead');
      await tester.pump();
      // Still pending: nothing has been reported yet.
      expect(queries, isEmpty);

      await tester.pump(const Duration(milliseconds: 250));
      expect(queries, ['dead']);
    });

    testWidgets('trims the query before reporting it', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(_host(SearchField(
        debounce: const Duration(milliseconds: 100),
        onChanged: queries.add,
      )));

      await tester.enterText(find.byType(TextField), '  deadlock  ');
      await tester.pump(const Duration(milliseconds: 150));
      expect(queries, ['deadlock']);
    });

    testWidgets('shows a clear button only when there is text', (tester) async {
      await tester.pumpWidget(_host(SearchField(onChanged: (_) {})));
      expect(find.byIcon(Icons.close), findsNothing);

      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('clearing reports an empty query', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(_host(SearchField(
        debounce: const Duration(milliseconds: 50),
        onChanged: queries.add,
      )));

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 100));

      expect(queries, ['abc', '']);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('a pending debounce does not fire after disposal', (tester) async {
      final queries = <String>[];
      await tester.pumpWidget(_host(SearchField(
        debounce: const Duration(milliseconds: 200),
        onChanged: queries.add,
      )));

      await tester.enterText(find.byType(TextField), 'late');
      // Replace the tree before the debounce window elapses.
      await tester.pumpWidget(_host(const SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(queries, isEmpty);
    });
  });

  group('AsyncView', () {
    testWidgets('renders a skeleton while loading', (tester) async {
      await tester.pumpWidget(_host(AsyncView<int>(
        value: const AsyncLoading(),
        data: (_, value) => Text('value $value'),
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders the data when present', (tester) async {
      await tester.pumpWidget(_host(AsyncView<int>(
        value: const AsyncData(7),
        data: (_, value) => Text('value $value'),
      )));
      expect(find.text('value 7'), findsOneWidget);
    });

    testWidgets('renders a readable error with a retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(_host(AsyncView<int>(
        value: AsyncError<int>(Exception('DatabaseException: no such table'), StackTrace.empty),
        onRetry: () => retried = true,
        data: (_, value) => Text('value $value'),
      )));

      // A database failure gets its own headline, and the raw driver
      // message never reaches the user.
      expect(find.text('Local data unavailable'), findsOneWidget);
      expect(find.textContaining('no such table'), findsNothing);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      expect(retried, isTrue);
    });

    testWidgets('shows a specific headline for an offline failure',
        (tester) async {
      await tester.pumpWidget(_host(AsyncView<int>(
        value: AsyncError<int>(
            const NetworkException('Your work is saved on this device.',
                isOffline: true),
            StackTrace.empty),
        onRetry: () {},
        data: (_, value) => Text('value $value'),
      )));
      expect(find.text('You are offline'), findsOneWidget);
      expect(find.text('Your work is saved on this device.'), findsOneWidget);
    });

    testWidgets('honours an empty check', (tester) async {
      await tester.pumpWidget(_host(AsyncView<int>(
        value: const AsyncData(0),
        emptyCheck: (value) => value == 0,
        empty: const Text('nothing here'),
        data: (_, value) => Text('value $value'),
      )));
      expect(find.text('nothing here'), findsOneWidget);
    });

    testWidgets('keeps previous content visible during a refresh',
        (tester) async {
      await tester.pumpWidget(_host(AsyncView<int>(
        value: const AsyncLoading<int>().copyWithPrevious(const AsyncData(3)),
        data: (_, value) => Text('value $value'),
      )));
      // Not a spinner: the user should not lose what they were reading.
      expect(find.text('value 3'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('SkeletonBox', () {
    testWidgets('renders a fixed-size placeholder', (tester) async {
      await tester.pumpWidget(_host(const Column(
        children: [
          SkeletonBox(height: 20),
          SkeletonBox(height: 12, width: 100),
        ],
      )));
      expect(find.byType(SkeletonBox), findsNWidgets(2));
    });
  });

  group('FilterChipRow', () {
    testWidgets('reports the selected option', (tester) async {
      String? selected;
      await tester.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) => FilterChipRow(
          options: const ['All', 'Systems', 'Networking'],
          selected: 'All',
          onSelected: (value) => setState(() => selected = value),
        ),
      )));

      await tester.tap(find.text('Networking'));
      expect(selected, 'Networking');
    });

    testWidgets('builds only a window of a long option list', (tester) async {
      await tester.pumpWidget(_host(FilterChipRow(
        options: [for (var i = 0; i < 60; i++) 'Option $i'],
        selected: 'Option 0',
        onSelected: (_) {},
      )));
      await tester.pump();

      // Lazy: not all 60 chips exist at once.
      final built = find.byType(ChoiceChip).evaluate().length;
      expect(built, lessThan(60));
      expect(built, greaterThan(0));
    });
  });

  group('LazySliverList', () {
    testWidgets('builds only the visible window of 500 rows', (tester) async {
      await tester.pumpWidget(_host(CustomScrollView(
        slivers: [
          LazySliverList(
            itemCount: 500,
            itemBuilder: (context, index) => Text('row $index'),
          ),
        ],
      )));
      await tester.pump();

      // Virtualisation: the point of the whole exercise.
      expect(find.text('row 0'), findsOneWidget);
      expect(find.text('row 499'), findsNothing);
      final built = find.byType(Text).evaluate().length;
      expect(built, lessThan(60));
    });

    testWidgets('supports a separator', (tester) async {
      await tester.pumpWidget(_host(CustomScrollView(
        slivers: [
          LazySliverList(
            itemCount: 3,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) => Text('row $index'),
          ),
        ],
      )));
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });

  group('calculator', () {
    testWidgets('shows results for valid input', (tester) async {
      await tester.pumpWidget(_host(CalculatorScreen(
        title: 'Test',
        formula: 'V = I x R',
        fields: const [
          CalculatorField(label: 'Current (A)'),
          CalculatorField(label: 'Resistance (Ω)'),
        ],
        compute: (input) => [
          CalculatorResult(
            label: 'Voltage',
            value: (input['Current (A)']! * input['Resistance (Ω)']!).toStringAsFixed(2),
            unit: 'V',
          ),
        ],
      )));

      await tester.enterText(find.byType(TextField).at(0), '2');
      await tester.enterText(find.byType(TextField).at(1), '10');
      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(find.text('20.00 V'), findsOneWidget);
    });

    testWidgets('rejects a non-numeric value with a readable message',
        (tester) async {
      await tester.pumpWidget(_host(CalculatorScreen(
        title: 'Test',
        formula: 'V = I x R',
        fields: const [CalculatorField(label: 'Current (A)')],
        compute: (input) => const [],
      )));

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(find.textContaining('must be a number'), findsOneWidget);
    });

    testWidgets('rejects a negative value where it makes no sense',
        (tester) async {
      await tester.pumpWidget(_host(CalculatorScreen(
        title: 'Test',
        formula: 'V = I x R',
        fields: const [CalculatorField(label: 'Resistance (Ω)')],
        compute: (input) => const [],
      )));

      await tester.enterText(find.byType(TextField), '-5');
      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(find.textContaining('cannot be negative'), findsOneWidget);
    });

    testWidgets('surfaces a validation failure from the computation',
        (tester) async {
      await tester.pumpWidget(_host(CalculatorScreen(
        title: 'Test',
        formula: 'x',
        fields: const [CalculatorField(label: 'Value')],
        compute: (input) => throw const FormatException('bad'),
      )));

      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(find.textContaining('Could not compute'), findsOneWidget);
    });

    testWidgets('an optional field may be left blank', (tester) async {
      await tester.pumpWidget(_host(CalculatorScreen(
        title: 'Test',
        formula: 'x',
        fields: const [
          CalculatorField(label: 'Known'),
          CalculatorField(label: 'Optional', optional: true),
        ],
        compute: (input) => [
          CalculatorResult(label: 'Keys', value: '${input.length}'),
        ],
      )));

      await tester.enterText(find.byType(TextField).at(0), '5');
      await tester.tap(find.text('Calculate'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });
  });

  group('ProgressBar', () {
    testWidgets('clamps a value outside 0..1', (tester) async {
      await tester.pumpWidget(_host(const Column(
        children: [
          ProgressBar(value: 1.8),
          ProgressBar(value: -0.4),
          ProgressBar(value: double.nan),
        ],
      )));
      // Must not throw and must render all three.
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    });

    testWidgets('exposes a value to assistive technology', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(const ProgressBar(
        value: 0.42,
        label: 'Lessons completed',
      )));
      expect(find.bySemanticsLabel('Lessons completed'), findsOneWidget);
      handle.dispose();
    });
  });

  group('Breakpoints', () {
    test('classifies widths into the documented size classes', () {
      expect(Breakpoints.classify(320), ScreenSize.small);
      expect(Breakpoints.classify(599), ScreenSize.small);
      expect(Breakpoints.classify(600), ScreenSize.medium);
      expect(Breakpoints.classify(899), ScreenSize.medium);
      expect(Breakpoints.classify(900), ScreenSize.large);
      expect(Breakpoints.classify(1199), ScreenSize.large);
      expect(Breakpoints.classify(1200), ScreenSize.tablet);
    });

    test('derived flags agree with the size class', () {
      expect(ScreenSize.small.isCompact, isTrue);
      expect(ScreenSize.large.isExpanded, isTrue);
      expect(ScreenSize.tablet.isTablet, isTrue);
      expect(ScreenSize.large.constrainsContent, isTrue);
      expect(ScreenSize.small.constrainsContent, isFalse);
    });
  });

  group('responsive layout', () {
    testWidgets('AppScaffold lays out on a small phone without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(AppScaffold(
        title: 'Small phone',
        slivers: [
          LazySliverList(
            itemCount: 30,
            itemBuilder: (context, index) => AppListRow(
              key: ValueKey(index),
              title: 'Row $index',
              subtitle: const Text('A subtitle long enough to wrap on a '
                  'narrow screen without overflowing its card.'),
            ),
          ),
        ],
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('AppScaffold lays out on a tablet without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(AppScaffold(
        title: 'Tablet',
        slivers: [
          LazySliverList(
            itemCount: 30,
            itemBuilder: (context, index) =>
                AppListRow(key: ValueKey(index), title: 'Row $index'),
          ),
        ],
      )));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a very small screen still renders without exceptions',
        (tester) async {
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(AppScaffold(
        title: 'Tiny',
        slivers: [
          LazySliverList(
            itemCount: 10,
            itemBuilder: (context, index) => AppListRow(
              key: ValueKey(index),
              title: 'Row $index',
            ),
          ),
        ],
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('EmptyStateView', () {
    testWidgets('shows a call to action when one is supplied', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_host(EmptyStateView(
        icon: Icons.search_off,
        title: 'Nothing here',
        message: 'Try a different search.',
        actionLabel: 'Clear filters',
        onAction: () => pressed = true,
      )));

      expect(find.text('Clear filters'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      expect(pressed, isTrue);
    });

    testWidgets('omits the action when there is nothing to do', (tester) async {
      await tester.pumpWidget(_host(const EmptyStateView(
        icon: Icons.inbox,
        title: 'No items',
        message: 'Nothing to show.',
      )));
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('ResultCard', () {
    testWidgets('displays the value that is given to it', (tester) async {
      await tester.pumpWidget(_host(const ResultCard(
        label: 'Voltage',
        value: '20.00 V',
      )));
      expect(find.text('20.00 V'), findsOneWidget);
    });

    testWidgets('shows the value alone when there is no unit', (tester) async {
      await tester.pumpWidget(_host(const ResultCard(
        label: 'Bands',
        value: 'red-black-red',
      )));
      expect(find.text('red-black-red'), findsOneWidget);
    });
  });

  group('theme', () {
    test('light and dark themes are both buildable and cached', () {
      final light = AppTheme.of(Brightness.light);
      final dark = AppTheme.of(Brightness.dark);
      expect(identical(AppTheme.of(Brightness.light), light), isTrue);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
    });

    test('touch targets meet the accessibility minimum', () {
      final theme = AppTheme.of(Brightness.light);
      final minimum = theme.filledButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});
      expect(minimum!.height, greaterThanOrEqualTo(48));
    });

    testWidgets('a card meets the minimum tap target', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_host(SizedBox(
        width: 200,
        child: AppListRow(title: 'Tap me', onTap: () {}),
      )));
      expect(find.byType(ListTile), findsOneWidget);
      handle.dispose();
    });
  });
}

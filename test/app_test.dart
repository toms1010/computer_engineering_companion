import 'package:computer_engineering_companion/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the redesigned companion home', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CompanionApp()));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
    expect(find.textContaining('Good morning'), findsOneWidget);
  });
}

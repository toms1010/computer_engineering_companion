import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'app/app_providers.dart';
import 'data/repositories/companion_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = CompanionRepository();
  await repository.initialize();
  runApp(ProviderScope(
    overrides: [repositoryProvider.overrideWithValue(repository)],
    child: const CompanionApp(),
  ));
}

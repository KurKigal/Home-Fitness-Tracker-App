import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/repositories/workout_repository.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.initialize();

  final repository = WorkoutRepository();

  await repository.seedInitialDataIfNeeded();

  runApp(const ProviderScope(child: FitnessApp()));
}

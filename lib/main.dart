import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/workout_repository.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.initialize();

  final repository = WorkoutRepository();

  await repository.seedInitialDataIfNeeded();

  await repository.ensureContinuousScheduleThrough(
    DateTime.now().add(const Duration(days: AppConstants.scheduleHorizonDays)),
  );

  runApp(const ProviderScope(child: FitnessApp()));
}

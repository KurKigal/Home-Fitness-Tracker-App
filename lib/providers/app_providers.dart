import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/schedule_entry.dart';
import '../data/models/workout.dart';
import '../data/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(),
);

final calendarEntriesProvider = Provider<List<ScheduleEntry>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getAllScheduleEntries();
});

final workoutByIdProvider = Provider.family<Workout?, String>((ref, workoutId) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkout(workoutId);
});

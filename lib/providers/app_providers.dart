import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';
import '../data/models/app_settings.dart';
import '../data/models/schedule_entry.dart';
import '../data/models/workout.dart';
import '../data/repositories/workout_repository.dart';
import '../services/schedule_service.dart';

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

final todayEntryProvider = Provider<ScheduleEntry?>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);

  return repository.getEntryForDate(normalizeDate(DateTime.now()));
});

final todayWorkoutProvider = Provider<Workout?>((ref) {
  final entry = ref.watch(todayEntryProvider);

  if (entry == null) {
    return null;
  }

  return ref.watch(workoutByIdProvider(entry.workoutId));
});

final nextTrainingEntryProvider = Provider<ScheduleEntry?>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);

  return repository.getNextTrainingEntry(normalizeDate(DateTime.now()));
});

final nextTrainingWorkoutProvider = Provider<Workout?>((ref) {
  final entry = ref.watch(nextTrainingEntryProvider);

  if (entry == null) {
    return null;
  }

  return ref.watch(workoutByIdProvider(entry.workoutId));
});

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);

  return ScheduleService(repository);
});

final appSettingsProvider =
    StateNotifierProvider<SettingsController, AppSettings>((ref) {
      final repository = ref.watch(workoutRepositoryProvider);

      return SettingsController(repository);
    });

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repository) : super(_repository.getSettings());

  final WorkoutRepository _repository;

  Future<void> setThemeMode(String themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);

    state = updated;

    await _repository.saveSettings(updated);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final updated = state.copyWith(notificationsEnabled: enabled);

    state = updated;

    await _repository.saveSettings(updated);
  }

  Future<void> setReminderTime({required int hour, required int minute}) async {
    final updated = state.copyWith(reminderHour: hour, reminderMinute: minute);

    state = updated;

    await _repository.saveSettings(updated);
  }
}

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../services/database_service.dart';
import '../models/app_settings.dart';
import '../models/schedule_entry.dart';
import '../models/workout.dart';
import '../seed/initial_program.dart';

class WorkoutRepository {
  Future<void> seedInitialDataIfNeeded() async {
    final settingsBox = DatabaseService.settingsBox;

    final currentSeedVersion =
        settingsBox.get(AppConstants.seedVersionKey, defaultValue: 0) as int;

    if (currentSeedVersion >= AppConstants.seedVersion) {
      return;
    }

    for (final workout in InitialProgram.workouts) {
      await DatabaseService.workoutsBox.put(workout.id, workout.toMap());
    }

    for (final entry in InitialProgram.schedule) {
      await DatabaseService.scheduleBox.put(entry.id, entry.toMap());
    }

    if (!settingsBox.containsKey(AppConstants.appSettingsKey)) {
      final settings = AppSettings(
        programStartDate: AppConstants.initialProgramStart,
      );

      await settingsBox.put(AppConstants.appSettingsKey, settings.toMap());
    }

    await settingsBox.put(
      AppConstants.seedVersionKey,
      AppConstants.seedVersion,
    );
  }

  Workout? getWorkout(String workoutId) {
    final raw = DatabaseService.workoutsBox.get(workoutId);

    if (raw == null) {
      return null;
    }

    return Workout.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  ScheduleEntry? getEntryForDate(DateTime date) {
    final raw = DatabaseService.scheduleBox.get(dateKey(date));

    if (raw == null) {
      return null;
    }

    return ScheduleEntry.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  ScheduleEntry? getNextTrainingEntry(DateTime from) {
    final normalizedFrom = normalizeDate(from);

    for (final entry in getAllScheduleEntries()) {
      final entryDate = normalizeDate(entry.date);

      if (entryDate.isBefore(normalizedFrom)) {
        continue;
      }

      if (entry.status != ScheduleStatus.planned) {
        continue;
      }

      final workout = getWorkout(entry.workoutId);

      if (workout == null || workout.isRest) {
        continue;
      }

      return entry;
    }

    return null;
  }

  List<ScheduleEntry> getAllScheduleEntries() {
    final entries = DatabaseService.scheduleBox.values
        .map(
          (raw) =>
              ScheduleEntry.fromMap(Map<dynamic, dynamic>.from(raw as Map)),
        )
        .toList();

    entries.sort((first, second) => first.date.compareTo(second.date));

    return entries;
  }

  List<ScheduleEntry> getEntriesBetween(DateTime start, DateTime end) {
    return getAllScheduleEntries().where((entry) {
      final date = normalizeDate(entry.date);
      final normalizedStart = normalizeDate(start);
      final normalizedEnd = normalizeDate(end);

      return !date.isBefore(normalizedStart) && !date.isAfter(normalizedEnd);
    }).toList();
  }

  Future<void> saveEntry(ScheduleEntry entry) async {
    await DatabaseService.scheduleBox.put(entry.id, entry.toMap());
  }

  Future<void> deleteEntry(DateTime date) async {
    await DatabaseService.scheduleBox.delete(dateKey(date));
  }

  AppSettings getSettings() {
    final raw = DatabaseService.settingsBox.get(AppConstants.appSettingsKey);

    if (raw == null) {
      return AppSettings(programStartDate: AppConstants.initialProgramStart);
    }

    return AppSettings.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  Future<void> saveSettings(AppSettings settings) async {
    await DatabaseService.settingsBox.put(
      AppConstants.appSettingsKey,
      settings.toMap(),
    );
  }
}

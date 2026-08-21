import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../services/database_service.dart';
import '../models/app_settings.dart';
import '../models/schedule_entry.dart';
import '../models/workout.dart';
import '../seed/continuous_program.dart';
import '../seed/initial_program.dart';
import '../models/workout_progress.dart';

class WorkoutRepository {
  Future<void> seedInitialDataIfNeeded() async {
    final settingsBox = DatabaseService.settingsBox;

    final currentSeedVersion =
        settingsBox.get(AppConstants.seedVersionKey, defaultValue: 0) as int;

    if (currentSeedVersion >= AppConstants.seedVersion) {
      return;
    }

    // Workout tanımları statik olduğu için güvenle güncellenebilir.
    for (final workout in [
      ...InitialProgram.workouts,
      ...ContinuousProgram.workouts,
    ]) {
      await DatabaseService.workoutsBox.put(workout.id, workout.toMap());
    }

    // Takvim kayıtları kullanıcı geçmişidir.
    // Var olan kayıtların üstüne ASLA yazmıyoruz.
    for (final entry in InitialProgram.schedule) {
      if (DatabaseService.scheduleBox.containsKey(entry.id)) {
        continue;
      }

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

  Future<void> ensureContinuousScheduleThrough(DateTime endDate) async {
    final normalizedEnd = normalizeDate(endDate);

    if (normalizedEnd.isBefore(AppConstants.continuousProgramStart)) {
      return;
    }

    final entries = getAllScheduleEntries();

    if (entries.isEmpty) {
      throw StateError(
        'Sürekli program oluşturulmadan önce başlangıç programı hazırlanmalıdır.',
      );
    }

    final latestEntry = entries.last;

    var actualDate = normalizeDate(
      latestEntry.date,
    ).add(const Duration(days: 1));

    var logicalDate = normalizeDate(
      latestEntry.originalDate,
    ).add(const Duration(days: 1));

    if (actualDate.isAfter(normalizedEnd)) {
      return;
    }

    while (!actualDate.isAfter(normalizedEnd)) {
      if (logicalDate.isBefore(AppConstants.continuousProgramStart)) {
        actualDate = actualDate.add(const Duration(days: 1));

        logicalDate = logicalDate.add(const Duration(days: 1));

        continue;
      }

      final entry = ContinuousProgram.buildEntry(
        actualDate: actualDate,
        logicalDate: logicalDate,
      );

      if (!DatabaseService.scheduleBox.containsKey(entry.id)) {
        await saveEntry(entry);
      }

      actualDate = actualDate.add(const Duration(days: 1));

      logicalDate = logicalDate.add(const Duration(days: 1));
    }
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
    final normalizedStart = normalizeDate(start);
    final normalizedEnd = normalizeDate(end);

    return getAllScheduleEntries().where((entry) {
      final date = normalizeDate(entry.date);

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

  WorkoutProgress? getWorkoutProgress(String scheduleEntryId) {
    final raw = DatabaseService.workoutProgressBox.get(scheduleEntryId);

    if (raw == null) {
      return null;
    }

    return WorkoutProgress.fromMap(Map<dynamic, dynamic>.from(raw as Map));
  }

  Future<void> saveWorkoutProgress(WorkoutProgress progress) async {
    await DatabaseService.workoutProgressBox.put(
      progress.scheduleEntryId,
      progress.toMap(),
    );
  }

  Future<void> deleteWorkoutProgress(String scheduleEntryId) async {
    await DatabaseService.workoutProgressBox.delete(scheduleEntryId);
  }
}

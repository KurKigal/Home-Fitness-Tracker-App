abstract final class AppConstants {
  static const workoutsBox = 'workouts';
  static const scheduleBox = 'schedule';
  static const settingsBox = 'settings';
  static const workoutProgressBox = 'workout_progress';

  static const seedVersionKey = 'seed_version';
  static const appSettingsKey = 'app_settings';

  static const seedVersion = 2;

  static final initialProgramStart = DateTime(2026, 9, 1);
  static final initialProgramEnd = DateTime(2027, 1, 31);

  static final continuousProgramStart = DateTime(2027, 2, 1);

  static const scheduleHorizonDays = 730;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_utils.dart';
import '../data/models/app_settings.dart';
import '../data/models/schedule_entry.dart';
import '../data/models/workout.dart';
import '../data/repositories/workout_repository.dart';
import '../services/schedule_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

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

      final notificationService = ref.watch(notificationServiceProvider);

      return SettingsController(repository, notificationService);
    });

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._repository, this._notificationService)
    : super(_repository.getSettings());

  final WorkoutRepository _repository;

  final NotificationService _notificationService;

  Future<void> setThemeMode(String themeMode) async {
    final updated = state.copyWith(themeMode: themeMode);

    state = updated;

    await _repository.saveSettings(updated);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermission();

      if (!granted) {
        final updated = state.copyWith(notificationsEnabled: false);

        state = updated;

        await _repository.saveSettings(updated);

        await _notificationService.cancelAll();

        return;
      }
    }

    final updated = state.copyWith(notificationsEnabled: enabled);

    state = updated;

    await _repository.saveSettings(updated);

    if (enabled) {
      await _notificationService.syncSchedule(
        repository: _repository,
        settings: updated,
      );
    } else {
      await _notificationService.cancelAll();
    }
  }

  Future<void> setReminderTime({required int hour, required int minute}) async {
    final updated = state.copyWith(reminderHour: hour, reminderMinute: minute);

    state = updated;

    await _repository.saveSettings(updated);

    if (updated.notificationsEnabled) {
      await _notificationService.syncSchedule(
        repository: _repository,
        settings: updated,
      );
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService.instance,
);

Future<void> syncWorkoutNotifications(WidgetRef ref) async {
  final settings = ref.read(appSettingsProvider);

  if (!settings.notificationsEnabled) {
    return;
  }

  final repository = ref.read(workoutRepositoryProvider);

  final notificationService = ref.read(notificationServiceProvider);

  await notificationService.syncSchedule(
    repository: repository,
    settings: settings,
  );
}

final widgetServiceProvider = Provider<WidgetService>(
  (ref) => WidgetService.instance,
);

Future<void> syncHomeWidget(WidgetRef ref) async {
  final repository = ref.read(workoutRepositoryProvider);

  final widgetService = ref.read(widgetServiceProvider);

  await widgetService.sync(repository);
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/date_utils.dart';
import '../data/models/app_settings.dart';
import '../data/models/schedule_entry.dart';
import '../data/repositories/workout_repository.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'workout_reminders';
  static const _channelName = 'Antrenman Hatırlatıcıları';
  static const _channelDescription =
      'Planlanan antrenmanlar için günlük hatırlatıcılar';

  static const _scheduleDaysAhead = 60;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings: initializationSettings);

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (android == null) {
      return true;
    }

    final granted = await android.requestNotificationsPermission();

    return granted ?? true;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> syncSchedule({
    required WorkoutRepository repository,
    required AppSettings settings,
  }) async {
    if (!_initialized) {
      return;
    }

    await cancelAll();

    if (!settings.notificationsEnabled) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    final today = DateTime(now.year, now.month, now.day);

    final endDate = today.add(const Duration(days: _scheduleDaysAhead));

    await repository.ensureContinuousScheduleThrough(endDate);

    var date = today;

    while (!date.isAfter(endDate)) {
      final entry = repository.getEntryForDate(date);

      if (entry != null && entry.status == ScheduleStatus.planned) {
        final workout = repository.getWorkout(entry.workoutId);

        if (workout != null && !workout.isRest) {
          final scheduledDate = tz.TZDateTime(
            tz.local,
            date.year,
            date.month,
            date.day,
            settings.reminderHour,
            settings.reminderMinute,
          );

          if (scheduledDate.isAfter(now)) {
            await _plugin.zonedSchedule(
              id: _notificationId(date),
              title: 'Bugün: ${workout.title}',
              body:
                  '~${workout.estimatedDurationMinutes} dk • ${workout.phase}',
              scheduledDate: scheduledDate,
              notificationDetails: const NotificationDetails(
                android: AndroidNotificationDetails(
                  _channelId,
                  _channelName,
                  channelDescription: _channelDescription,
                  importance: Importance.high,
                  priority: Priority.high,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              payload: dateKey(date),
            );
          }
        }
      }

      date = date.add(const Duration(days: 1));
    }
  }

  int _notificationId(DateTime date) {
    return (date.year * 10000) + (date.month * 100) + date.day;
  }
}

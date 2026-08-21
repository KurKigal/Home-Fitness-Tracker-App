import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';
import '../data/repositories/workout_repository.dart';

class WidgetService {
  WidgetService._();

  static final WidgetService instance = WidgetService._();

  static const _qualifiedAndroidName =
      'com.emirhankeser.fitnesstracker.FitnessWidgetProvider';

  static const _scheduleKey = 'widget_schedule';
  static const _programStartKey = 'widget_program_start';
  static const _firstWorkoutKey = 'widget_first_workout';

  static const _daysAhead = 370;

  Future<void> sync(WorkoutRepository repository) async {
    final today = normalizeDate(DateTime.now());

    final endDate = today.add(const Duration(days: _daysAhead));

    await repository.ensureContinuousScheduleThrough(endDate);

    final entries = repository.getEntriesBetween(today, endDate);

    final schedule = <String, dynamic>{};

    for (final entry in entries) {
      final workout = repository.getWorkout(entry.workoutId);

      if (workout == null) {
        continue;
      }

      final itemCount = workout.isStrength
          ? workout.exercises.length
          : workout.isRun
          ? workout.steps.length
          : 0;

      final itemType = workout.isStrength
          ? 'hareket'
          : workout.isRun
          ? 'adım'
          : '';

      schedule[dateKey(entry.date)] = {
        'title': workout.title,
        'phase': workout.phase,
        'duration': workout.estimatedDurationMinutes,
        'itemCount': itemCount,
        'itemType': itemType,
        'status': entry.status.name,
        'rest': workout.isRest,
      };
    }

    final firstWorkout = repository.getWorkout('sep_strength_a');

    await HomeWidget.saveWidgetData<String>(_scheduleKey, jsonEncode(schedule));

    await HomeWidget.saveWidgetData<String>(
      _programStartKey,
      dateKey(AppConstants.initialProgramStart),
    );

    await HomeWidget.saveWidgetData<String>(
      _firstWorkoutKey,
      firstWorkout?.title ?? 'Kuvvet A',
    );

    await HomeWidget.updateWidget(qualifiedAndroidName: _qualifiedAndroidName);
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fitnesstracker/core/utils/date_utils.dart';
import 'package:fitnesstracker/data/models/schedule_entry.dart';
import 'package:fitnesstracker/data/models/workout.dart';
import 'package:fitnesstracker/data/models/workout_progress.dart';
import 'package:fitnesstracker/data/repositories/workout_repository.dart';
import 'package:fitnesstracker/services/schedule_service.dart';

void main() {
  group('ScheduleService', () {
    late FakeWorkoutRepository repository;
    late ScheduleService service;

    setUp(() {
      repository = FakeWorkoutRepository(
        workouts: {
          'strength_a': const Workout(
            id: 'strength_a',
            title: 'Kuvvet A',
            phase: 'Test',
            category: WorkoutCategory.strength,
            estimatedDurationMinutes: 30,
            description: 'Test workout.',
          ),
          'easy_run': const Workout(
            id: 'easy_run',
            title: 'Easy Run',
            phase: 'Test',
            category: WorkoutCategory.easyRun,
            estimatedDurationMinutes: 30,
            description: 'Test run.',
          ),
          'rest': const Workout(
            id: 'rest',
            title: 'Dinlenme',
            phase: 'Test',
            category: WorkoutCategory.rest,
            estimatedDurationMinutes: 0,
            description: 'Rest.',
          ),
        },
        entries: [
          _entry(date: DateTime(2026, 9, 1), workoutId: 'strength_a'),
          _entry(date: DateTime(2026, 9, 2), workoutId: 'easy_run'),
          _entry(date: DateTime(2026, 9, 3), workoutId: 'rest'),
        ],
      );

      service = ScheduleService(repository);
    });

    test('completeWorkout marks entry completed', () async {
      final completionTime = DateTime(2026, 9, 1, 20, 30);

      await service.completeWorkout(
        DateTime(2026, 9, 1),
        completedAt: completionTime,
      );

      final entry = repository.getEntryForDate(DateTime(2026, 9, 1));

      expect(entry?.status, ScheduleStatus.completed);

      expect(entry?.completedAt, completionTime);
    });

    test('skipWorkout skips without moving following days', () async {
      await service.skipWorkout(DateTime(2026, 9, 1));

      expect(
        repository.getEntryForDate(DateTime(2026, 9, 1))?.status,
        ScheduleStatus.skipped,
      );

      expect(
        repository.getEntryForDate(DateTime(2026, 9, 2))?.workoutId,
        'easy_run',
      );

      expect(
        repository.getEntryForDate(DateTime(2026, 9, 3))?.workoutId,
        'rest',
      );
    });

    test('postponeWorkout moves entire future schedule one day', () async {
      await service.postponeWorkout(DateTime(2026, 9, 1));

      final september1 = repository.getEntryForDate(DateTime(2026, 9, 1));

      final september2 = repository.getEntryForDate(DateTime(2026, 9, 2));

      final september3 = repository.getEntryForDate(DateTime(2026, 9, 3));

      final september4 = repository.getEntryForDate(DateTime(2026, 9, 4));

      expect(september1?.status, ScheduleStatus.postponed);

      expect(september1?.workoutId, 'strength_a');

      expect(september2?.workoutId, 'strength_a');

      expect(september2?.status, ScheduleStatus.planned);

      expect(september3?.workoutId, 'easy_run');

      expect(september4?.workoutId, 'rest');
    });

    test('postponed workout preserves original date', () async {
      await service.postponeWorkout(DateTime(2026, 9, 1));

      final shiftedEntry = repository.getEntryForDate(DateTime(2026, 9, 2));

      expect(shiftedEntry?.originalDate, DateTime(2026, 9, 1));
    });

    test('postponed workout moves saved progress to shifted entry', () async {
      final startedAt = DateTime(2026, 9, 1, 18);

      await repository.saveWorkoutProgress(
        WorkoutProgress(
          scheduleEntryId: '2026-09-01',
          workoutId: 'strength_a',
          completedItemIds: const {'squat'},
          startedAt: startedAt,
          updatedAt: startedAt,
        ),
      );

      await service.postponeWorkout(DateTime(2026, 9, 1));

      expect(repository.getWorkoutProgress('2026-09-01'), isNull);

      final shiftedProgress = repository.getWorkoutProgress('2026-09-02');

      expect(shiftedProgress?.scheduleEntryId, '2026-09-02');
      expect(shiftedProgress?.workoutId, 'strength_a');
      expect(shiftedProgress?.completedItemIds, {'squat'});
      expect(shiftedProgress?.startedAt, startedAt);
    });

    test('rest day cannot be postponed', () async {
      expect(
        () => service.postponeWorkout(DateTime(2026, 9, 3)),
        throwsStateError,
      );
    });
  });
}

ScheduleEntry _entry({required DateTime date, required String workoutId}) {
  final normalized = normalizeDate(date);

  return ScheduleEntry(
    id: dateKey(normalized),
    date: normalized,
    workoutId: workoutId,
    phase: 'Test',
    status: ScheduleStatus.planned,
    originalDate: normalized,
  );
}

class FakeWorkoutRepository extends WorkoutRepository {
  FakeWorkoutRepository({
    required Map<String, Workout> workouts,
    required List<ScheduleEntry> entries,
  }) : _workouts = workouts,
       _entries = {for (final entry in entries) entry.id: entry};

  final Map<String, Workout> _workouts;

  final Map<String, ScheduleEntry> _entries;

  final Map<String, WorkoutProgress> _progress = {};

  @override
  Workout? getWorkout(String workoutId) {
    return _workouts[workoutId];
  }

  @override
  ScheduleEntry? getEntryForDate(DateTime date) {
    return _entries[dateKey(date)];
  }

  @override
  List<ScheduleEntry> getAllScheduleEntries() {
    final entries = _entries.values.toList()
      ..sort((first, second) => first.date.compareTo(second.date));

    return entries;
  }

  @override
  Future<void> saveEntry(ScheduleEntry entry) async {
    _entries[entry.id] = entry;
  }

  @override
  Future<void> deleteEntry(DateTime date) async {
    _entries.remove(dateKey(date));
  }

  @override
  WorkoutProgress? getWorkoutProgress(String scheduleEntryId) {
    return _progress[scheduleEntryId];
  }

  @override
  Future<void> saveWorkoutProgress(WorkoutProgress progress) async {
    _progress[progress.scheduleEntryId] = progress;
  }

  @override
  Future<void> deleteWorkoutProgress(String scheduleEntryId) async {
    _progress.remove(scheduleEntryId);
  }
}

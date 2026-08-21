import 'package:fitnesstracker/data/models/workout_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutProgress', () {
    test('serializes and restores progress', () {
      final startedAt = DateTime(2026, 9, 1, 19);

      final updatedAt = DateTime(2026, 9, 1, 19, 30);

      final progress = WorkoutProgress(
        scheduleEntryId: '2026-09-01',
        workoutId: 'sep_strength_a',
        completedItemIds: {'squat', 'pushup'},
        startedAt: startedAt,
        updatedAt: updatedAt,
      );

      final restored = WorkoutProgress.fromMap(progress.toMap());

      expect(restored.scheduleEntryId, '2026-09-01');

      expect(restored.workoutId, 'sep_strength_a');

      expect(restored.completedItemIds, {'squat', 'pushup'});

      expect(restored.startedAt, startedAt);
      expect(restored.updatedAt, updatedAt);
    });

    test('calculates progress correctly', () {
      final progress = WorkoutProgress(
        scheduleEntryId: 'test',
        workoutId: 'test',
        completedItemIds: {'a', 'b'},
        startedAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(progress.progressFor(4), 0.5);

      expect(progress.isComplete(4), false);
    });
  });
}

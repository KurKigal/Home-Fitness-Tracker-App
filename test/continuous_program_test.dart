import 'package:fitnesstracker/data/seed/continuous_program.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContinuousProgram', () {
    test('continues January schedule with long run on February 1', () {
      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 1)),
        'continuous_long',
      );
    });

    test('starts regular cycle with strength A on February 2', () {
      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 2)),
        'continuous_strength_a',
      );
    });

    test('uses expected weekly workout order', () {
      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 3)),
        'continuous_easy',
      );

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 4)),
        'continuous_strength_b',
      );

      expect(ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 5)), 'rest');

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 7)),
        'continuous_strength_c',
      );

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 8)),
        'continuous_long',
      );
    });

    test('rotates quality run over four weeks', () {
      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 6)),
        'continuous_interval',
      );

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 13)),
        'continuous_tempo',
      );

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 20)),
        'continuous_interval',
      );

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 2, 27)),
        'continuous_recovery_tempo',
      );

      expect(
        ContinuousProgram.workoutIdForDate(DateTime(2027, 3, 6)),
        'continuous_interval',
      );
    });

    test('shifted actual date keeps logical workout date', () {
      final entry = ContinuousProgram.buildEntry(
        actualDate: DateTime(2027, 2, 9),
        logicalDate: DateTime(2027, 2, 6),
      );

      expect(entry.date, DateTime(2027, 2, 9));

      expect(entry.originalDate, DateTime(2027, 2, 6));

      expect(entry.workoutId, 'continuous_interval');
    });
  });
}

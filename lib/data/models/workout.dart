import 'exercise.dart';

enum WorkoutCategory { strength, easyRun, intervalRun, tempoRun, longRun, rest }

class Workout {
  const Workout({
    required this.id,
    required this.title,
    required this.phase,
    required this.category,
    required this.estimatedDurationMinutes,
    required this.description,
    this.exercises = const [],
    this.steps = const [],
  });

  final String id;
  final String title;
  final String phase;

  final WorkoutCategory category;

  final int estimatedDurationMinutes;

  final String description;

  final List<Exercise> exercises;

  /// Özellikle koşularda kullanılacak.
  ///
  /// Örn:
  /// - 10 dk easy
  /// - 6 × 2 dk hızlı / 2 dk easy
  /// - 5 dk soğuma
  final List<String> steps;

  bool get isRest => category == WorkoutCategory.rest;

  bool get isStrength => category == WorkoutCategory.strength;

  bool get isRun => switch (category) {
    WorkoutCategory.easyRun ||
    WorkoutCategory.intervalRun ||
    WorkoutCategory.tempoRun ||
    WorkoutCategory.longRun => true,
    _ => false,
  };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'phase': phase,
      'category': category.name,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'description': description,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      'steps': steps,
    };
  }

  factory Workout.fromMap(Map<dynamic, dynamic> map) {
    final rawExercises = map['exercises'] as List<dynamic>? ?? [];
    final rawSteps = map['steps'] as List<dynamic>? ?? [];

    return Workout(
      id: map['id'] as String,
      title: map['title'] as String,
      phase: map['phase'] as String,
      category: WorkoutCategory.values.byName(map['category'] as String),
      estimatedDurationMinutes: map['estimatedDurationMinutes'] as int,
      description: map['description'] as String,
      exercises: rawExercises
          .map(
            (exercise) =>
                Exercise.fromMap(Map<dynamic, dynamic>.from(exercise as Map)),
          )
          .toList(),
      steps: rawSteps.cast<String>(),
    );
  }
}

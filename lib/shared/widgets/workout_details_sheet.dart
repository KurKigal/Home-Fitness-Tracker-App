import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/workout.dart';

Future<void> showWorkoutDetailsSheet({
  required BuildContext context,
  required DateTime date,
  required Workout workout,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return _WorkoutDetailsSheet(date: date, workout: workout);
    },
  );
}

class _WorkoutDetailsSheet extends StatelessWidget {
  const _WorkoutDetailsSheet({required this.date, required this.workout});

  final DateTime date;
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDate(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                workout.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                workout.phase,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.primary),
              ),
              if (!workout.isRest) ...[
                const SizedBox(height: 8),
                Text('~${workout.estimatedDurationMinutes} dakika'),
              ],
              const SizedBox(height: 20),
              Text(
                workout.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (workout.exercises.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Hareketler',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...workout.exercises.map(
                  (exercise) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 7,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(exercise.prescription),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (workout.steps.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Koşu Planı',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...workout.steps.indexed.map((step) {
                  final index = step.$1;
                  final value = step.$2;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(value)),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/workout.dart';
import '../../../shared/widgets/neu_card.dart';

class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({
    required this.workout,
    required this.onTap,
    super.key,
  });

  final Workout workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      onTap: onTap,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_iconForWorkout(workout), color: AppColors.primary),
              ),
              const Spacer(),
              if (!workout.isRest)
                Text(
                  '~${workout.estimatedDurationMinutes} dk',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            workout.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            workout.phase,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            workout.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          if (workout.exercises.isNotEmpty) ...[
            const SizedBox(height: 22),
            _InfoRow(
              icon: Icons.fitness_center_rounded,
              text: '${workout.exercises.length} hareket',
            ),
          ],
          if (workout.steps.isNotEmpty) ...[
            const SizedBox(height: 22),
            _InfoRow(
              icon: Icons.directions_run_rounded,
              text: '${workout.steps.length} aşamalı koşu planı',
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForWorkout(Workout workout) {
    return switch (workout.category) {
      WorkoutCategory.strength => Icons.fitness_center_rounded,
      WorkoutCategory.easyRun => Icons.directions_run_rounded,
      WorkoutCategory.intervalRun => Icons.speed_rounded,
      WorkoutCategory.tempoRun => Icons.timer_rounded,
      WorkoutCategory.longRun => Icons.route_rounded,
      WorkoutCategory.rest => Icons.self_improvement_rounded,
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

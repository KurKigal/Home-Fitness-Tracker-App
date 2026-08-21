import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/schedule_entry.dart';
import '../../data/models/workout.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/neu_card.dart';
import 'widgets/today_workout_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = normalizeDate(DateTime.now());

    final entry = ref.watch(todayEntryProvider);
    final workout = ref.watch(todayWorkoutProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text('Bugün', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          _formatDate(today),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 28),

        if (today.isBefore(AppConstants.initialProgramStart))
          _PreStartContent(today: today)
        else if (entry == null || workout == null)
          const _NoWorkoutContent()
        else
          _TodayContent(entry: entry, workout: workout),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const days = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

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

    return '${days[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _PreStartContent extends ConsumerWidget {
  const _PreStartContent({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextEntry = ref.watch(nextTrainingEntryProvider);
    final nextWorkout = ref.watch(nextTrainingWorkoutProvider);

    final daysRemaining = AppConstants.initialProgramStart
        .difference(today)
        .inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeuCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 30,
              ),
              const SizedBox(height: 18),
              Text(
                'Program yakında başlıyor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'İlk antrenman 1 Eylül 2026.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '$daysRemaining gün kaldı.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (nextEntry != null && nextWorkout != null) ...[
          const SizedBox(height: 28),
          Text('İlk Antrenman', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          TodayWorkoutCard(workout: nextWorkout),
        ],
      ],
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.entry, required this.workout});

  final ScheduleEntry entry;
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    if (workout.isRest) {
      return NeuCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.self_improvement_rounded,
              size: 36,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Dinlenme Günü',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Bugün planlı bir antrenman yok. '
              'Program yarın kaldığı yerden devam edecek.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusLabel(status: entry.status),
        const SizedBox(height: 14),
        TodayWorkoutCard(workout: workout),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final ScheduleStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ScheduleStatus.planned => ('Bugünkü Antrenman', AppColors.primary),
      ScheduleStatus.completed => ('Tamamlandı', AppColors.success),
      ScheduleStatus.skipped => ('Atlandı', AppColors.danger),
      ScheduleStatus.postponed => ('Ertelendi', AppColors.warning),
    };

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17),
        ),
      ],
    );
  }
}

class _NoWorkoutContent extends StatelessWidget {
  const _NoWorkoutContent();

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 42,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 18),
          Text(
            'Bugün için kayıt bulunamadı.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

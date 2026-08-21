import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/schedule_entry.dart';
import '../../data/models/workout.dart';
import '../../data/models/workout_progress.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/neu_button.dart';
import 'widgets/exercise_tile.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({required this.entry, required this.workout, super.key});

  final ScheduleEntry entry;
  final Workout workout;

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  late final DateTime _startedAt;

  final Set<String> _completedItems = {};

  bool _finishing = false;

  @override
  void initState() {
    super.initState();

    final repository = ref.read(workoutRepositoryProvider);

    final saved = repository.getWorkoutProgress(widget.entry.id);

    _startedAt = saved?.startedAt ?? DateTime.now();

    if (saved != null) {
      _completedItems.addAll(saved.completedItemIds);
    }
  }

  List<String> get _itemIds {
    if (widget.workout.isStrength) {
      return widget.workout.exercises.map((exercise) => exercise.id).toList();
    }

    if (widget.workout.isRun) {
      return List.generate(
        widget.workout.steps.length,
        (index) => 'run_step_$index',
      );
    }

    return const [];
  }

  int get _totalItems => _itemIds.length;

  bool get _allCompleted {
    return _totalItems > 0 && _completedItems.length >= _totalItems;
  }

  double get _progress {
    if (_totalItems == 0) {
      return 0;
    }

    return _completedItems.length / _totalItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title), centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text(
                    widget.workout.phase,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '~${widget.workout.estimatedDurationMinutes} dakika',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _ProgressHeader(
                    completed: _completedItems.length,
                    total: _totalItems,
                    progress: _progress,
                  ),

                  const SizedBox(height: 28),

                  if (widget.workout.isStrength) ..._buildExercises(),

                  if (widget.workout.isRun) ..._buildRunSteps(),
                ],
              ),
            ),

            _BottomArea(
              enabled: _allCompleted && !_finishing,
              finishing: _finishing,
              onFinish: _finishWorkout,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExercises() {
    return [
      Text('Hareketler', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 14),
      ...widget.workout.exercises.map((exercise) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ExerciseTile(
            exercise: exercise,
            completed: _completedItems.contains(exercise.id),
            onTap: () {
              _toggleItem(exercise.id);
            },
          ),
        );
      }),
    ];
  }

  List<Widget> _buildRunSteps() {
    return [
      Text('Koşu Planı', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 14),
      ...widget.workout.steps.indexed.map((indexedStep) {
        final index = indexedStep.$1;
        final step = indexedStep.$2;
        final id = 'run_step_$index';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _RunStepTile(
            number: index + 1,
            text: step,
            completed: _completedItems.contains(id),
            onTap: () {
              _toggleItem(id);
            },
          ),
        );
      }),
    ];
  }

  Future<void> _toggleItem(String id) async {
    setState(() {
      if (_completedItems.contains(id)) {
        _completedItems.remove(id);
      } else {
        _completedItems.add(id);
      }
    });

    final progress = WorkoutProgress(
      scheduleEntryId: widget.entry.id,
      workoutId: widget.workout.id,
      completedItemIds: Set<String>.from(_completedItems),
      startedAt: _startedAt,
      updatedAt: DateTime.now(),
    );

    await ref.read(workoutRepositoryProvider).saveWorkoutProgress(progress);
  }

  Future<void> _finishWorkout() async {
    if (!_allCompleted || _finishing) {
      return;
    }

    setState(() {
      _finishing = true;
    });

    try {
      await ref
          .read(scheduleServiceProvider)
          .completeWorkout(widget.entry.date);

      await ref
          .read(workoutRepositoryProvider)
          .deleteWorkoutProgress(widget.entry.id);

      ref.invalidate(todayEntryProvider);
      ref.invalidate(todayWorkoutProvider);
      ref.invalidate(calendarEntriesProvider);
      ref.invalidate(nextTrainingEntryProvider);
      ref.invalidate(nextTrainingWorkoutProvider);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _finishing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('İlerleme', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              '$completed / $total',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: progress, minHeight: 9),
        ),
        const SizedBox(height: 8),
        Text(
          '%$percentage tamamlandı',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _RunStepTile extends StatelessWidget {
  const _RunStepTile({
    required this.number,
    required this.text,
    required this.completed,
    required this.onTap,
  });

  final int number;
  final String text;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed
                      ? AppColors.success
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: completed
                    ? const Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: Colors.white,
                      )
                    : Text(
                        '$number',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    decoration: completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomArea extends StatelessWidget {
  const _BottomArea({
    required this.enabled,
    required this.finishing,
    required this.onFinish,
  });

  final bool enabled;
  final bool finishing;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: NeuButton(
        label: finishing ? 'Kaydediliyor...' : 'Antrenmanı Tamamla',
        icon: Icons.check_rounded,
        style: NeuButtonStyle.primary,
        onPressed: enabled ? onFinish : null,
      ),
    );
  }
}

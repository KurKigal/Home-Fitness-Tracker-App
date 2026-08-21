import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/schedule_entry.dart';
import '../../data/models/workout.dart';
import '../../providers/app_providers.dart';
import '../../shared/widgets/neu_card.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();

    final now = normalizeDate(DateTime.now());
    final programStart = AppConstants.initialProgramStart;

    if (now.isBefore(programStart)) {
      _visibleMonth = DateTime(programStart.year, programStart.month);
    } else {
      _visibleMonth = DateTime(now.year, now.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(calendarEntriesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Text('Takvim', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          'Antrenman programını ve geçmişini takip et.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 28),

        NeuCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _MonthHeader(
                month: _visibleMonth,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              const SizedBox(height: 20),

              const _WeekdayHeader(),

              const SizedBox(height: 10),

              _CalendarGrid(
                month: _visibleMonth,
                entries: entries,
                onDayPressed: _openDay,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const _CalendarLegend(),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  Future<void> _nextMonth() async {
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);

    final endOfNextMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0);

    await ref
        .read(workoutRepositoryProvider)
        .ensureContinuousScheduleThrough(endOfNextMonth);

    ref.invalidate(calendarEntriesProvider);

    if (!mounted) {
      return;
    }

    setState(() {
      _visibleMonth = nextMonth;
    });
  }

  void _openDay(DateTime date) {
    final repository = ref.read(workoutRepositoryProvider);

    final entry = repository.getEntryForDate(date);

    if (entry == null) {
      _showEmptyDay(date);
      return;
    }

    final workout = repository.getWorkout(entry.workoutId);

    if (workout == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _DayDetailsSheet(date: date, entry: entry, workout: workout);
      },
    );
  }

  void _showEmptyDay(DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${date.day}.${date.month}.${date.year}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bu tarih için planlanmış bir antrenman bulunmuyor.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),

        Expanded(
          child: Text(
            _monthName(month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  String _monthName(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Row(
      children: days
          .map(
            (day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.entries,
    required this.onDayPressed,
  });

  final DateTime month;
  final List<ScheduleEntry> entries;
  final ValueChanged<DateTime> onDayPressed;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Monday = 1
    final leadingEmptyCells = firstDay.weekday - 1;

    final totalCells = leadingEmptyCells + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final cellCount = rowCount * 7;

    final entryMap = <String, ScheduleEntry>{
      for (final entry in entries) dateKey(entry.date): entry,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cellCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.83,
      ),
      itemBuilder: (context, index) {
        if (index < leadingEmptyCells) {
          return const SizedBox.shrink();
        }

        final day = index - leadingEmptyCells + 1;

        if (day > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date = DateTime(month.year, month.month, day);

        final entry = entryMap[dateKey(date)];

        return _CalendarDay(
          date: date,
          entry: entry,
          onPressed: () => onDayPressed(date),
        );
      },
    );
  }
}

class _CalendarDay extends ConsumerWidget {
  const _CalendarDay({
    required this.date,
    required this.entry,
    required this.onPressed,
  });

  final DateTime date;
  final ScheduleEntry? entry;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isToday = isSameDate(date, DateTime.now());

    final entry = this.entry;

    Workout? workout;

    if (entry != null) {
      workout = ref.watch(workoutByIdProvider(entry.workoutId));
    }

    final indicatorColor = _indicatorColor(entry, workout);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),

              if (indicatorColor != null)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _indicatorColor(ScheduleEntry? entry, Workout? workout) {
    if (entry == null || workout == null) {
      return null;
    }

    return switch (entry.status) {
      ScheduleStatus.completed => AppColors.success,
      ScheduleStatus.skipped => AppColors.danger,
      ScheduleStatus.postponed => AppColors.warning,

      ScheduleStatus.planned =>
        workout.isRest ? Colors.grey : AppColors.primary,
    };
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 18,
      runSpacing: 12,
      children: const [
        _LegendItem(color: AppColors.primary, label: 'Planlandı'),
        _LegendItem(color: AppColors.success, label: 'Tamamlandı'),
        _LegendItem(color: AppColors.warning, label: 'Ertelendi'),
        _LegendItem(color: AppColors.danger, label: 'Atlandı'),
        _LegendItem(color: Colors.grey, label: 'Dinlenme'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DayDetailsSheet extends StatelessWidget {
  const _DayDetailsSheet({
    required this.date,
    required this.entry,
    required this.workout,
  });

  final DateTime date;
  final ScheduleEntry entry;
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

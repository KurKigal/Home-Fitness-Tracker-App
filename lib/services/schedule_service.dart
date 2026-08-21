import '../core/utils/date_utils.dart';
import '../data/models/schedule_entry.dart';
import '../data/repositories/workout_repository.dart';

class ScheduleService {
  ScheduleService(this._repository);

  final WorkoutRepository _repository;

  Future<void> completeWorkout(DateTime date, {DateTime? completedAt}) async {
    final normalizedDate = normalizeDate(date);

    final entry = _repository.getEntryForDate(normalizedDate);

    if (entry == null) {
      throw StateError('Bu tarih için planlanmış bir kayıt bulunamadı.');
    }

    final workout = _repository.getWorkout(entry.workoutId);

    if (workout == null) {
      throw StateError('Antrenman verisi bulunamadı.');
    }

    if (workout.isRest) {
      throw StateError('Dinlenme günü tamamlandı olarak işaretlenemez.');
    }

    if (entry.status == ScheduleStatus.completed) {
      return;
    }

    if (entry.status != ScheduleStatus.planned) {
      throw StateError('Sadece planlanmış bir antrenman tamamlanabilir.');
    }

    final updatedEntry = entry.copyWith(
      status: ScheduleStatus.completed,
      completedAt: completedAt ?? DateTime.now(),
    );

    await _repository.saveEntry(updatedEntry);
  }

  Future<void> skipWorkout(DateTime date) async {
    final normalizedDate = normalizeDate(date);

    final entry = _repository.getEntryForDate(normalizedDate);

    if (entry == null) {
      throw StateError('Bu tarih için planlanmış bir kayıt bulunamadı.');
    }

    final workout = _repository.getWorkout(entry.workoutId);

    if (workout == null) {
      throw StateError('Antrenman verisi bulunamadı.');
    }

    if (workout.isRest) {
      throw StateError('Dinlenme günü atlanamaz.');
    }

    if (entry.status == ScheduleStatus.skipped) {
      return;
    }

    if (entry.status != ScheduleStatus.planned) {
      throw StateError('Sadece planlanmış bir antrenman atlanabilir.');
    }

    final updatedEntry = entry.copyWith(
      status: ScheduleStatus.skipped,
      clearCompletedAt: true,
    );

    await _repository.saveEntry(updatedEntry);
  }

  Future<void> postponeWorkout(DateTime date) async {
    final normalizedDate = normalizeDate(date);

    final entry = _repository.getEntryForDate(normalizedDate);

    if (entry == null) {
      throw StateError('Bu tarih için planlanmış bir kayıt bulunamadı.');
    }

    final workout = _repository.getWorkout(entry.workoutId);

    if (workout == null) {
      throw StateError('Antrenman verisi bulunamadı.');
    }

    if (workout.isRest) {
      throw StateError('Dinlenme günü ertelenemez.');
    }

    if (entry.status != ScheduleStatus.planned) {
      throw StateError('Sadece planlanmış bir antrenman ertelenebilir.');
    }

    final entriesToShift = _repository
        .getAllScheduleEntries()
        .where(
          (scheduleEntry) =>
              !normalizeDate(scheduleEntry.date).isBefore(normalizedDate),
        )
        .toList();

    // En önemli kısım:
    // sona doğru olan kayıtları önce taşıyoruz.
    //
    // Örneğin:
    // 1 Eylül -> 2 Eylül
    // 2 Eylül -> 3 Eylül
    //
    // şeklinde baştan gidersek 2 Eylül kaydını ezebiliriz.
    //
    // Bu yüzden ters sırada ilerliyoruz.
    entriesToShift.sort((first, second) => second.date.compareTo(first.date));

    for (final scheduleEntry in entriesToShift) {
      final oldDate = normalizeDate(scheduleEntry.date);

      final newDate = oldDate.add(const Duration(days: 1));

      await _repository.deleteEntry(oldDate);

      final shiftedEntry = scheduleEntry.copyWith(
        id: dateKey(newDate),
        date: newDate,
      );

      await _repository.saveEntry(shiftedEntry);
    }

    // Eski günü tarihçede "Ertelendi" olarak bırakıyoruz.
    final postponedEntry = entry.copyWith(
      id: dateKey(normalizedDate),
      date: normalizedDate,
      status: ScheduleStatus.postponed,
      clearCompletedAt: true,
    );

    await _repository.saveEntry(postponedEntry);
  }
}

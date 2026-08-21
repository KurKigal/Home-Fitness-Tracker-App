enum ScheduleStatus { planned, completed, skipped, postponed }

class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.date,
    required this.workoutId,
    required this.phase,
    required this.status,
    required this.originalDate,
    this.completedAt,
  });

  final String id;

  final DateTime date;

  final String workoutId;

  final String phase;

  final ScheduleStatus status;

  /// Erteleme yapıldığında ilk planlanan tarihi kaybetmeyelim.
  final DateTime originalDate;

  final DateTime? completedAt;

  ScheduleEntry copyWith({
    String? id,
    DateTime? date,
    String? workoutId,
    String? phase,
    ScheduleStatus? status,
    DateTime? originalDate,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      workoutId: workoutId ?? this.workoutId,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      originalDate: originalDate ?? this.originalDate,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'workoutId': workoutId,
      'phase': phase,
      'status': status.name,
      'originalDate': originalDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory ScheduleEntry.fromMap(Map<dynamic, dynamic> map) {
    final completedAtValue = map['completedAt'] as String?;

    return ScheduleEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      workoutId: map['workoutId'] as String,
      phase: map['phase'] as String,
      status: ScheduleStatus.values.byName(map['status'] as String),
      originalDate: DateTime.parse(map['originalDate'] as String),
      completedAt: completedAtValue == null
          ? null
          : DateTime.parse(completedAtValue),
    );
  }
}

class WorkoutProgress {
  const WorkoutProgress({
    required this.scheduleEntryId,
    required this.workoutId,
    required this.completedItemIds,
    required this.startedAt,
    required this.updatedAt,
  });

  final String scheduleEntryId;
  final String workoutId;

  final Set<String> completedItemIds;

  final DateTime startedAt;
  final DateTime updatedAt;

  double progressFor(int totalItems) {
    if (totalItems <= 0) {
      return 0;
    }

    return completedItemIds.length / totalItems;
  }

  bool isComplete(int totalItems) {
    return totalItems > 0 && completedItemIds.length >= totalItems;
  }

  WorkoutProgress copyWith({
    String? scheduleEntryId,
    Set<String>? completedItemIds,
    DateTime? updatedAt,
  }) {
    return WorkoutProgress(
      scheduleEntryId: scheduleEntryId ?? this.scheduleEntryId,
      workoutId: workoutId,
      completedItemIds: completedItemIds ?? this.completedItemIds,
      startedAt: startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduleEntryId': scheduleEntryId,
      'workoutId': workoutId,
      'completedItemIds': completedItemIds.toList(),
      'startedAt': startedAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkoutProgress.fromMap(Map<dynamic, dynamic> map) {
    final rawItems = map['completedItemIds'] as List<dynamic>? ?? [];

    return WorkoutProgress(
      scheduleEntryId: map['scheduleEntryId'] as String,
      workoutId: map['workoutId'] as String,
      completedItemIds: rawItems.map((item) => item as String).toSet(),
      startedAt: DateTime.parse(map['startedAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}

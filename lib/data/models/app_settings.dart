class AppSettings {
  const AppSettings({
    required this.programStartDate,
    this.notificationsEnabled = true,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.themeMode = 'system',
  });

  final DateTime programStartDate;

  final bool notificationsEnabled;

  final int reminderHour;
  final int reminderMinute;

  /// system / light / dark
  final String themeMode;

  AppSettings copyWith({
    DateTime? programStartDate,
    bool? notificationsEnabled,
    int? reminderHour,
    int? reminderMinute,
    String? themeMode,
  }) {
    return AppSettings(
      programStartDate: programStartDate ?? this.programStartDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'programStartDate': programStartDate.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'reminderHour': reminderHour,
      'reminderMinute': reminderMinute,
      'themeMode': themeMode,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      programStartDate: DateTime.parse(map['programStartDate'] as String),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      reminderHour: map['reminderHour'] as int? ?? 19,
      reminderMinute: map['reminderMinute'] as int? ?? 0,
      themeMode: map['themeMode'] as String? ?? 'system',
    );
  }
}

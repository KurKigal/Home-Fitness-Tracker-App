class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.prescription,
    this.notes,
    this.progression,
  });

  final String id;
  final String name;

  /// Örn:
  /// 3 set • 10–20 tekrar
  /// 3 set • 20–45 saniye
  final String prescription;

  final String? notes;
  final String? progression;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'prescription': prescription,
      'notes': notes,
      'progression': progression,
    };
  }

  factory Exercise.fromMap(Map<dynamic, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      prescription: map['prescription'] as String,
      notes: map['notes'] as String?,
      progression: map['progression'] as String?,
    );
  }
}

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/exercise.dart';
import '../models/schedule_entry.dart';
import '../models/workout.dart';

abstract final class ContinuousProgram {
  static const phase = 'Sürekli Program';

  /// Sürekli döngüde Kuvvet A'nın ilk referans günü.
  ///
  /// 1 Şubat 2027, Ocak programının devamı olarak Long Run'a denk gelir.
  /// 2 Şubat 2027 ile yeni haftalık döngü Kuvvet A'dan başlar.
  static final cycleAnchor = DateTime(2027, 2, 2);

  static List<Workout> get workouts => [
    _strengthA,
    _strengthB,
    _strengthC,
    _easyRun,
    _intervalRun,
    _tempoRun,
    _recoveryTempoRun,
    _longRun,
  ];

  static ScheduleEntry buildEntry({
    required DateTime actualDate,
    required DateTime logicalDate,
  }) {
    final normalizedActualDate = normalizeDate(actualDate);
    final normalizedLogicalDate = normalizeDate(logicalDate);

    return ScheduleEntry(
      id: dateKey(normalizedActualDate),
      date: normalizedActualDate,
      workoutId: workoutIdForDate(normalizedLogicalDate),
      phase: phase,
      status: ScheduleStatus.planned,
      originalDate: normalizedLogicalDate,
    );
  }

  static String workoutIdForDate(DateTime date) {
    final normalizedDate = normalizeDate(date);

    if (normalizedDate.isBefore(AppConstants.continuousProgramStart)) {
      throw ArgumentError(
        'Sürekli program 1 Şubat 2027 tarihinden önce kullanılamaz.',
      );
    }

    final daysFromAnchor = normalizedDate.difference(cycleAnchor).inDays;

    final cycleDay = _positiveModulo(daysFromAnchor, 7);

    return switch (cycleDay) {
      0 => 'continuous_strength_a',
      1 => 'continuous_easy',
      2 => 'continuous_strength_b',
      3 => 'rest',
      4 => _qualityWorkoutForWeek(daysFromAnchor),
      5 => 'continuous_strength_c',
      6 => 'continuous_long',
      _ => throw StateError('Geçersiz program günü.'),
    };
  }

  static String _qualityWorkoutForWeek(int daysFromAnchor) {
    final weekIndex = daysFromAnchor ~/ 7;

    final cycleWeek = _positiveModulo(weekIndex, 4);

    return switch (cycleWeek) {
      0 => 'continuous_interval',
      1 => 'continuous_tempo',
      2 => 'continuous_interval',
      3 => 'continuous_recovery_tempo',
      _ => throw StateError('Geçersiz döngü haftası.'),
    };
  }

  static int _positiveModulo(int value, int divisor) {
    return ((value % divisor) + divisor) % divisor;
  }

  static const _strengthA = Workout(
    id: 'continuous_strength_a',
    title: 'Kuvvet A',
    phase: phase,
    category: WorkoutCategory.strength,
    estimatedDurationMinutes: 45,
    description:
        'Full body kuvvet antrenmanı. Hareketleri temiz formda ve RIR 1–2 civarında uygula.',
    exercises: [
      Exercise(
        id: 'continuous_a_squat',
        name: 'Pause / Tempo Squat',
        prescription: '3–4 set • 8–15 tekrar',
        progression: 'Tempo → Pause → Split Squat → Bulgarian Split Squat',
      ),
      Exercise(
        id: 'continuous_a_pushup',
        name: 'Push-up Varyasyonu',
        prescription: '3–4 set • 8–15 tekrar',
        progression: 'Normal → Slow → Close-Grip → Diamond → Archer',
      ),
      Exercise(
        id: 'continuous_a_lunge',
        name: 'Reverse Lunge',
        prescription: '3–4 set • her bacak 8–15 tekrar',
      ),
      Exercise(
        id: 'continuous_a_row',
        name: 'Floor Elbow Row',
        prescription: '3–4 set • 8–15 tekrar',
        notes: 'Dirseklerini zemine bastır ve üst sırtını sık.',
      ),
      Exercise(
        id: 'continuous_a_bridge',
        name: 'Single-Leg Glute Bridge',
        prescription: '3 set • her bacak 10–20 tekrar',
      ),
      Exercise(
        id: 'continuous_a_dead_bug',
        name: 'Dead Bug',
        prescription: '3 set • her taraf 8–12 tekrar',
      ),
      Exercise(
        id: 'continuous_a_side_plank',
        name: 'Side Plank',
        prescription: '3 set • her taraf 25–45 saniye',
      ),
    ],
  );

  static const _strengthB = Workout(
    id: 'continuous_strength_b',
    title: 'Kuvvet B',
    phase: phase,
    category: WorkoutCategory.strength,
    estimatedDurationMinutes: 45,
    description: 'Tek bacak, omuz ve arka zincir ağırlıklı full body çalışma.',
    exercises: [
      Exercise(
        id: 'continuous_b_split_squat',
        name: 'Bulgarian / Split Squat',
        prescription: '3–4 set • her bacak 8–15 tekrar',
      ),
      Exercise(
        id: 'continuous_b_pike',
        name: 'Pike Push-up',
        prescription: '3–4 set • 6–12 tekrar',
      ),
      Exercise(
        id: 'continuous_b_rdl',
        name: 'Single-Leg Romanian Deadlift',
        prescription: '3–4 set • her bacak 8–15 tekrar',
      ),
      Exercise(
        id: 'continuous_b_lat',
        name: 'Prone Lat Pull-down',
        prescription: '3 set • 10–15 tekrar',
      ),
      Exercise(
        id: 'continuous_b_bridge',
        name: 'Single-Leg Glute Bridge',
        prescription: '3 set • her bacak 8–15 tekrar',
      ),
      Exercise(
        id: 'continuous_b_calf',
        name: 'Calf Raise',
        prescription: '3 set • 15–30 tekrar',
      ),
      Exercise(
        id: 'continuous_b_hollow',
        name: 'Hollow Body Hold',
        prescription: '3 set • 20–40 saniye',
      ),
    ],
  );

  static const _strengthC = Workout(
    id: 'continuous_strength_c',
    title: 'Kuvvet C',
    phase: phase,
    category: WorkoutCategory.strength,
    estimatedDurationMinutes: 35,
    description:
        'Uzun koşudan önce bacak yükünü kontrollü tutan üst gövde ve core ağırlıklı çalışma.',
    exercises: [
      Exercise(
        id: 'continuous_c_squat',
        name: 'Tempo Squat',
        prescription: '3 set • 8–12 tekrar',
        notes: '3 sn aşağı, 1 sn bekle, kontrollü kalk.',
      ),
      Exercise(
        id: 'continuous_c_pushup',
        name: 'Push-up Varyasyonu',
        prescription: '3 set • 8–15 tekrar',
      ),
      Exercise(
        id: 'continuous_c_snow_angel',
        name: 'Reverse Snow Angel',
        prescription: '3 set • 10–15 tekrar',
      ),
      Exercise(
        id: 'continuous_c_shoulder_tap',
        name: 'Plank Shoulder Tap',
        prescription: '3 set • her taraf 10–20 tekrar',
      ),
      Exercise(
        id: 'continuous_c_bridge',
        name: 'Single-Leg Glute Bridge',
        prescription: '3 set • her bacak 10–15 tekrar',
      ),
      Exercise(
        id: 'continuous_c_ytw',
        name: 'Prone Y-T-W',
        prescription: '3 set • her pozisyon 6–10 tekrar',
      ),
    ],
  );

  static const _easyRun = Workout(
    id: 'continuous_easy',
    title: 'Easy Run',
    phase: phase,
    category: WorkoutCategory.easyRun,
    estimatedDurationMinutes: 45,
    description:
        'Rahat aerobik koşu. Konuşabilecek kadar kontrollü tempoda kal.',
    steps: [
      '5–10 dk çok rahat başlangıç',
      '25–35 dk easy pace',
      '5 dk rahat soğuma',
      'Toplam 35–45 dk',
    ],
  );

  static const _intervalRun = Workout(
    id: 'continuous_interval',
    title: 'Interval Run',
    phase: phase,
    category: WorkoutCategory.intervalRun,
    estimatedDurationMinutes: 40,
    description:
        'Kondisyon ve hız dayanıklılığı için kontrollü interval çalışması.',
    steps: [
      '10 dk easy ısınma',
      '6 × 2 dk hızlı / 2 dk easy',
      'Hızlı bölümler yaklaşık RPE 7–8/10',
      '5–10 dk soğuma',
    ],
  );

  static const _tempoRun = Workout(
    id: 'continuous_tempo',
    title: 'Tempo Run',
    phase: phase,
    category: WorkoutCategory.tempoRun,
    estimatedDurationMinutes: 45,
    description:
        'Sürdürülebilir fakat belirgin şekilde zor kontrollü tempo koşusu.',
    steps: [
      '10 dk easy',
      '20 dk kontrollü tempo',
      'Tempo yaklaşık RPE 7/10',
      '5–10 dk soğuma',
    ],
  );

  static const _recoveryTempoRun = Workout(
    id: 'continuous_recovery_tempo',
    title: 'Hafif Tempo Run',
    phase: phase,
    category: WorkoutCategory.tempoRun,
    estimatedDurationMinutes: 35,
    description: 'Dört haftalık döngünün yük azaltılmış kalite koşusu.',
    steps: [
      '10 dk easy',
      '12–15 dk kontrollü hafif tempo',
      'RPE yaklaşık 6/10',
      '5–10 dk soğuma',
    ],
  );

  static const _longRun = Workout(
    id: 'continuous_long',
    title: 'Long Easy Run',
    phase: phase,
    category: WorkoutCategory.longRun,
    estimatedDurationMinutes: 60,
    description:
        'Dayanıklılık odaklı uzun ve rahat koşu. Hız yerine süreyi hedefle.',
    steps: [
      '45–60 dk rahat tempo',
      'Konuşma temposunu koru',
      'Gerekirse süreyi 45 dk civarında tut',
    ],
  );
}

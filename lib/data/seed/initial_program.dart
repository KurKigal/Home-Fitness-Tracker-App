import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../models/exercise.dart';
import '../models/schedule_entry.dart';
import '../models/workout.dart';

abstract final class InitialProgram {
  static const septemberPhase = 'Spora Dönüş';
  static const octoberPhase = 'Temel Kuvvet ve Kondisyon';
  static const novemberPhase = 'Performans';
  static const decemberPhase = 'Atletik Dönem';
  static const januaryPhase = 'Konsolidasyon';

  static List<Workout> get workouts => [
    _restWorkout,

    // Eylül
    _strengthA(
      id: 'sep_strength_a',
      phase: septemberPhase,
      sets: '2 set (ilk hafta), sonra 3 set',
      duration: 30,
    ),
    _strengthB(
      id: 'sep_strength_b',
      phase: septemberPhase,
      sets: '2 set (ilk hafta), sonra 3 set',
      duration: 30,
    ),
    _strengthC(
      id: 'sep_strength_c',
      phase: septemberPhase,
      sets: '2 set (ilk hafta), sonra 3 set',
      duration: 30,
    ),
    _run(
      id: 'sep_easy_short',
      title: 'Kolay Koşu',
      phase: septemberPhase,
      category: WorkoutCategory.easyRun,
      duration: 25,
      description: 'Rahat tempoda koşu.',
      steps: const [
        '5 dk çok rahat başlangıç',
        '15–20 dk rahat koşu',
        'Gerekirse kısa yürüyüş molası',
      ],
    ),
    _run(
      id: 'sep_easy_long',
      title: 'Kolay Koşu',
      phase: septemberPhase,
      category: WorkoutCategory.easyRun,
      duration: 30,
      description: 'Koşu adaptasyonu ve temel kondisyon.',
      steps: const [
        '5 dk çok rahat başlangıç',
        '20–25 dk rahat koşu',
        'Alternatif: 4 dk koş + 1 dk yürü × 5',
      ],
    ),

    // Ekim
    _strengthA(
      id: 'oct_strength_a',
      phase: octoberPhase,
      sets: '3 set',
      duration: 35,
    ),
    _strengthB(
      id: 'oct_strength_b',
      phase: octoberPhase,
      sets: '3 set',
      duration: 35,
    ),
    _strengthC(
      id: 'oct_strength_c',
      phase: octoberPhase,
      sets: '3 set',
      duration: 35,
    ),
    _run(
      id: 'oct_easy',
      title: 'Easy Run',
      phase: octoberPhase,
      category: WorkoutCategory.easyRun,
      duration: 35,
      description: 'Konuşabilecek kadar rahat koşu.',
      steps: const [
        '5–10 dk rahat başlangıç',
        '20–25 dk easy pace',
        '5 dk rahat soğuma',
      ],
    ),
    _run(
      id: 'oct_interval',
      title: 'Interval Koşu',
      phase: octoberPhase,
      category: WorkoutCategory.intervalRun,
      duration: 35,
      description: 'Kontrollü ilk interval çalışması.',
      steps: const [
        '8–10 dk easy koşu',
        '5 × 2 dk hızlı / 2 dk easy',
        '5–10 dk soğuma',
        'Hızlı bölümler yaklaşık RPE 7/10',
      ],
    ),

    // Kasım
    _strengthA(
      id: 'nov_strength_a',
      phase: novemberPhase,
      sets: '3–4 set',
      duration: 40,
      harder: true,
    ),
    _strengthB(
      id: 'nov_strength_b',
      phase: novemberPhase,
      sets: '3–4 set',
      duration: 40,
      harder: true,
    ),
    _strengthC(
      id: 'nov_strength_c',
      phase: novemberPhase,
      sets: '3 set',
      duration: 35,
      harder: true,
    ),
    _run(
      id: 'nov_easy',
      title: 'Easy Run',
      phase: novemberPhase,
      category: WorkoutCategory.easyRun,
      duration: 35,
      description: 'Rahat aerobik koşu.',
      steps: const ['30–35 dk rahat tempo', 'RPE yaklaşık 4–5/10'],
    ),
    _run(
      id: 'nov_interval',
      title: 'Interval Koşu',
      phase: novemberPhase,
      category: WorkoutCategory.intervalRun,
      duration: 40,
      description: 'Orta/yüksek yoğunluklu interval.',
      steps: const [
        '10 dk easy ısınma',
        '6 × 2 dk RPE 7–8 / 2 dk easy',
        '5–10 dk soğuma',
      ],
    ),
    _run(
      id: 'nov_long',
      title: 'Long Easy Run',
      phase: novemberPhase,
      category: WorkoutCategory.longRun,
      duration: 45,
      description: 'Süre odaklı uzun ve rahat koşu.',
      steps: const ['Rahat tempo', '35–45 dk arası', 'Hız değil süre hedefle'],
    ),

    // Aralık
    _strengthA(
      id: 'dec_strength_a',
      phase: decemberPhase,
      sets: '4 ana / 3 yardımcı set',
      duration: 45,
      harder: true,
    ),
    _strengthB(
      id: 'dec_strength_b',
      phase: decemberPhase,
      sets: '4 ana / 3 yardımcı set',
      duration: 45,
      harder: true,
    ),
    _strengthC(
      id: 'dec_strength_c',
      phase: decemberPhase,
      sets: '3 set',
      duration: 35,
      harder: true,
      lightLegs: true,
    ),
    _run(
      id: 'dec_easy',
      title: 'Easy Run',
      phase: decemberPhase,
      category: WorkoutCategory.easyRun,
      duration: 40,
      description: 'Rahat aerobik koşu.',
      steps: const ['35–40 dk rahat tempo'],
    ),
    _run(
      id: 'dec_tempo',
      title: 'Tempo Run',
      phase: decemberPhase,
      category: WorkoutCategory.tempoRun,
      duration: 45,
      description: 'Kontrollü tempolu koşu.',
      steps: const [
        '10 dk easy',
        '3 × 6 dk tempo / 2 dk easy',
        '5–10 dk soğuma',
        'Tempo bölümleri yaklaşık RPE 7/10',
      ],
    ),
    _run(
      id: 'dec_long',
      title: 'Long Easy Run',
      phase: decemberPhase,
      category: WorkoutCategory.longRun,
      duration: 55,
      description: 'Dayanıklılık geliştiren uzun koşu.',
      steps: const ['45–55 dk rahat tempo', 'Hız hedefleme'],
    ),

    // Ocak
    _strengthA(
      id: 'jan_strength_a',
      phase: januaryPhase,
      sets: '3–4 set',
      duration: 45,
      harder: true,
    ),
    _strengthB(
      id: 'jan_strength_b',
      phase: januaryPhase,
      sets: '3–4 set',
      duration: 45,
      harder: true,
    ),
    _strengthC(
      id: 'jan_strength_c',
      phase: januaryPhase,
      sets: '3 set',
      duration: 35,
      harder: true,
      lightLegs: true,
    ),
    _run(
      id: 'jan_easy',
      title: 'Easy Run',
      phase: januaryPhase,
      category: WorkoutCategory.easyRun,
      duration: 45,
      description: 'Rahat aerobik koşu.',
      steps: const ['35–45 dk rahat tempo'],
    ),
    _run(
      id: 'jan_interval',
      title: 'Interval Run',
      phase: januaryPhase,
      category: WorkoutCategory.intervalRun,
      duration: 40,
      description: 'Interval kalite koşusu.',
      steps: const [
        '10 dk easy',
        '6 × 2 dk hızlı / 2 dk easy',
        '5–10 dk soğuma',
      ],
    ),
    _run(
      id: 'jan_tempo',
      title: 'Tempo Run',
      phase: januaryPhase,
      category: WorkoutCategory.tempoRun,
      duration: 45,
      description: 'Kontrollü tempo koşusu.',
      steps: const ['10 dk easy', '20 dk kontrollü tempo', '5–10 dk soğuma'],
    ),
    _run(
      id: 'jan_long',
      title: 'Long Easy Run',
      phase: januaryPhase,
      category: WorkoutCategory.longRun,
      duration: 60,
      description: 'Uzun, rahat dayanıklılık koşusu.',
      steps: const ['45–60 dk rahat tempo'],
    ),
  ];

  static List<ScheduleEntry> get schedule {
    final entries = <ScheduleEntry>[];

    var date = AppConstants.initialProgramStart;

    while (!date.isAfter(AppConstants.initialProgramEnd)) {
      final normalizedDate = normalizeDate(date);

      final daysSinceStart = normalizedDate
          .difference(AppConstants.initialProgramStart)
          .inDays;

      final cycleDay = daysSinceStart % 7;
      final weekIndex = daysSinceStart ~/ 7;

      final workoutId = _workoutForDate(normalizedDate, cycleDay, weekIndex);

      final phase = _phaseForMonth(normalizedDate.month);

      entries.add(
        ScheduleEntry(
          id: dateKey(normalizedDate),
          date: normalizedDate,
          workoutId: workoutId,
          phase: phase,
          status: ScheduleStatus.planned,
          originalDate: normalizedDate,
        ),
      );

      date = date.add(const Duration(days: 1));
    }

    return entries;
  }

  static String _workoutForDate(DateTime date, int cycleDay, int weekIndex) {
    return switch (date.month) {
      9 => const [
        'sep_strength_a',
        'sep_easy_short',
        'rest',
        'sep_strength_b',
        'rest',
        'sep_strength_c',
        'sep_easy_long',
      ][cycleDay],

      10 => const [
        'oct_strength_a',
        'oct_easy',
        'rest',
        'oct_strength_b',
        'rest',
        'oct_strength_c',
        'oct_interval',
      ][cycleDay],

      11 => const [
        'nov_strength_a',
        'nov_easy',
        'nov_strength_b',
        'rest',
        'nov_interval',
        'nov_strength_c',
        'nov_long',
      ][cycleDay],

      12 => const [
        'dec_strength_a',
        'dec_easy',
        'dec_strength_b',
        'rest',
        'dec_tempo',
        'dec_strength_c',
        'dec_long',
      ][cycleDay],

      1 => [
        'jan_strength_a',
        'jan_easy',
        'jan_strength_b',
        'rest',
        weekIndex.isEven ? 'jan_interval' : 'jan_tempo',
        'jan_strength_c',
        'jan_long',
      ][cycleDay],

      _ => 'rest',
    };
  }

  static String _phaseForMonth(int month) {
    return switch (month) {
      9 => septemberPhase,
      10 => octoberPhase,
      11 => novemberPhase,
      12 => decemberPhase,
      1 => januaryPhase,
      _ => januaryPhase,
    };
  }

  static Workout _strengthA({
    required String id,
    required String phase,
    required String sets,
    required int duration,
    bool harder = false,
  }) {
    return Workout(
      id: id,
      title: 'Kuvvet A',
      phase: phase,
      category: WorkoutCategory.strength,
      estimatedDurationMinutes: duration,
      description: 'Temel full body kuvvet antrenmanı.',
      exercises: [
        Exercise(
          id: '${id}_squat',
          name: harder ? 'Pause / Tempo Squat' : 'Bodyweight Squat',
          prescription: '$sets • 10–20 tekrar',
          progression: 'Normal → Tempo → Pause → Split Squat',
        ),
        Exercise(
          id: '${id}_pushup',
          name: harder ? 'Slow / Close-Grip Push-up' : 'Push-up',
          prescription: '$sets • 6–15 tekrar',
          progression: 'Normal → Slow → Close-Grip → Diamond → Archer',
        ),
        Exercise(
          id: '${id}_reverse_lunge',
          name: 'Reverse Lunge',
          prescription: '$sets • her bacak 8–15 tekrar',
        ),
        Exercise(
          id: '${id}_row',
          name: 'Floor Elbow Row',
          prescription: '$sets • 8–15 tekrar',
          notes: 'Dirseklerini zemine bastırarak üst sırtını sık.',
        ),
        Exercise(
          id: '${id}_bridge',
          name: harder ? 'Single-Leg Glute Bridge' : 'Glute Bridge',
          prescription: '$sets • 10–20 tekrar',
        ),
        Exercise(
          id: '${id}_dead_bug',
          name: 'Dead Bug',
          prescription: '$sets • her taraf 8–12 tekrar',
        ),
        Exercise(
          id: '${id}_side_plank',
          name: 'Side Plank',
          prescription: '$sets • her taraf 20–45 saniye',
        ),
      ],
    );
  }

  static Workout _strengthB({
    required String id,
    required String phase,
    required String sets,
    required int duration,
    bool harder = false,
  }) {
    return Workout(
      id: id,
      title: 'Kuvvet B',
      phase: phase,
      category: WorkoutCategory.strength,
      estimatedDurationMinutes: duration,
      description: 'Tek bacak, omuz ve arka zincir odaklı.',
      exercises: [
        Exercise(
          id: '${id}_split_squat',
          name: harder ? 'Bulgarian / Split Squat' : 'Split Squat',
          prescription: '$sets • her bacak 8–15 tekrar',
        ),
        Exercise(
          id: '${id}_pike_pushup',
          name: 'Pike Push-up',
          prescription: '$sets • 6–12 tekrar',
          progression: 'Kalçayı yükselterek hareketi zorlaştır.',
        ),
        Exercise(
          id: '${id}_single_rdl',
          name: 'Single-Leg Romanian Deadlift',
          prescription: '$sets • her bacak 8–15 tekrar',
        ),
        Exercise(
          id: '${id}_lat_pull',
          name: 'Prone Lat Pull-down',
          prescription: '$sets • 10–15 tekrar',
        ),
        Exercise(
          id: '${id}_single_bridge',
          name: 'Single-Leg Glute Bridge',
          prescription: '$sets • her bacak 8–15 tekrar',
        ),
        Exercise(
          id: '${id}_calf',
          name: 'Calf Raise',
          prescription: '$sets • 15–30 tekrar',
        ),
        Exercise(
          id: '${id}_hollow',
          name: 'Hollow Body Hold',
          prescription: '$sets • 15–40 saniye',
        ),
      ],
    );
  }

  static Workout _strengthC({
    required String id,
    required String phase,
    required String sets,
    required int duration,
    bool harder = false,
    bool lightLegs = false,
  }) {
    return Workout(
      id: id,
      title: 'Kuvvet C',
      phase: phase,
      category: WorkoutCategory.strength,
      estimatedDurationMinutes: duration,
      description: lightLegs
          ? 'Uzun koşu öncesi daha kontrollü full body çalışma.'
          : 'Atletik full body kuvvet antrenmanı.',
      exercises: [
        Exercise(
          id: '${id}_tempo_squat',
          name: 'Tempo Squat',
          prescription: '$sets • ${lightLegs ? '8–12' : '10–15'} tekrar',
          notes: '3 sn aşağı, 1 sn bekle, kontrollü kalk.',
        ),
        Exercise(
          id: '${id}_pushup',
          name: harder ? 'Push-up Varyasyonu' : 'Push-up',
          prescription: '$sets • 8–15 tekrar',
        ),
        if (!lightLegs)
          Exercise(
            id: '${id}_lunge',
            name: 'Alternating Lunge',
            prescription: '$sets • her bacak 10–15 tekrar',
          ),
        Exercise(
          id: '${id}_snow_angel',
          name: 'Reverse Snow Angel',
          prescription: '$sets • 10–15 tekrar',
        ),
        Exercise(
          id: '${id}_shoulder_tap',
          name: 'Plank Shoulder Tap',
          prescription: '$sets • her taraf 10–20 tekrar',
        ),
        Exercise(
          id: '${id}_bridge',
          name: 'Single-Leg Glute Bridge',
          prescription: '$sets • her bacak 10–15 tekrar',
        ),
        Exercise(
          id: '${id}_ytw',
          name: 'Prone Y-T-W',
          prescription: '$sets • her pozisyon 6–10 tekrar',
        ),
      ],
    );
  }

  static Workout _run({
    required String id,
    required String title,
    required String phase,
    required WorkoutCategory category,
    required int duration,
    required String description,
    required List<String> steps,
  }) {
    return Workout(
      id: id,
      title: title,
      phase: phase,
      category: category,
      estimatedDurationMinutes: duration,
      description: description,
      steps: steps,
    );
  }

  static const _restWorkout = Workout(
    id: 'rest',
    title: 'Dinlenme',
    phase: 'Dinlenme',
    category: WorkoutCategory.rest,
    estimatedDurationMinutes: 0,
    description: 'Bugün planlı antrenman bulunmuyor.',
  );
}

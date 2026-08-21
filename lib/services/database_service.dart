import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../core/constants/app_constants.dart';

abstract final class DatabaseService {
  static Box<dynamic>? _workoutsBox;
  static Box<dynamic>? _scheduleBox;
  static Box<dynamic>? _settingsBox;

  static Future<void> initialize() async {
    await Hive.initFlutter();

    _workoutsBox = await Hive.openBox<dynamic>(AppConstants.workoutsBox);

    _scheduleBox = await Hive.openBox<dynamic>(AppConstants.scheduleBox);

    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }

  static Box<dynamic> get workoutsBox {
    final box = _workoutsBox;

    if (box == null) {
      throw StateError('DatabaseService.initialize() çağrılmadı.');
    }

    return box;
  }

  static Box<dynamic> get scheduleBox {
    final box = _scheduleBox;

    if (box == null) {
      throw StateError('DatabaseService.initialize() çağrılmadı.');
    }

    return box;
  }

  static Box<dynamic> get settingsBox {
    final box = _settingsBox;

    if (box == null) {
      throw StateError('DatabaseService.initialize() çağrılmadı.');
    }

    return box;
  }
}

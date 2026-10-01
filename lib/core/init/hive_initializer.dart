import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../hive_registrar.g.dart';
import '../data/models/user_model.dart';

abstract final class HiveInitializer {
  static const String userBox = 'userBox';
  static const String settingsBox = 'settingsBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    await _openBox<UserModel>(userBox);
    await _openBox<String>(settingsBox);
  }

  /// A box that fails to open (e.g. corrupted after a schema change) is
  /// dropped and recreated — both boxes only hold data the app can rebuild.
  static Future<void> _openBox<T>(String name) async {
    try {
      await Hive.openBox<T>(name);
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(name);
      } catch (_) {
        // Box files may not exist yet.
      }
      await Hive.openBox<T>(name);
    }
  }
}

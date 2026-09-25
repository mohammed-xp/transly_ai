import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../hive_registrar.g.dart';
import '../data/models/user_model.dart';

abstract final class HiveInitializer {
  static const String userBox = 'userBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    await _openUserBox();
  }

  /// A box that fails to open (e.g. corrupted after a schema change) is
  /// dropped and recreated — the cached user is just a cache.
  static Future<void> _openUserBox() async {
    try {
      await Hive.openBox<UserModel>(userBox);
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(userBox);
      } catch (_) {
        // Box files may not exist yet.
      }
      await Hive.openBox<UserModel>(userBox);
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:transly_ai/core/data/models/user_model.dart';
import 'package:transly_ai/core/di/service_locator.dart';
import 'package:transly_ai/core/init/hive_initializer.dart';
import 'package:transly_ai/core/theme/app_colors.dart';
import 'package:transly_ai/features/splash/presentation/cubit/splash_cubit.dart';
import 'package:transly_ai/hive_registrar.g.dart';
import 'package:transly_ai/main.dart';

void main() {
  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('transly_hive_');
    Hive.init(hiveDir.path);
    Hive.registerAdapters();
    await Hive.openBox<UserModel>(HiveInitializer.userBox);
    await Hive.openBox<String>(HiveInitializer.settingsBox);
    await configureDependencies();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDir.delete(recursive: true);
  });

  testWidgets('TranslyApp builds and applies the design-system theme', (
    tester,
  ) async {
    await tester.pumpWidget(const TranslyApp());
    // The initial splash route animates continuously, so pumpAndSettle would
    // never converge — a single frame is enough to assert the app/theme setup.
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.primary, AppColors.primary);
    expect(app.darkTheme!.colorScheme.primary, AppColors.accentDark);
    expect(app.themeMode, ThemeMode.system);

    // Let the splash's startup timer fire and route onward so no timers stay
    // pending when the test tears down the tree.
    await tester.pump(SplashCubit.minSplashDuration);
    await tester.pump();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transly_ai/features/auth/data/datasources/auth_local_data_source.dart';

void main() {
  Future<PrefsAuthLocalDataSource> buildSource([
    Map<String, Object> initialValues = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(initialValues);
    return PrefsAuthLocalDataSource(await SharedPreferences.getInstance());
  }

  group('PrefsAuthLocalDataSource', () {
    test('returns (false, "") when nothing was ever saved', () async {
      final source = await buildSource();

      expect(await source.loadRememberedAccount(), (false, ''));
    });

    test('round-trips a remembered account', () async {
      final source = await buildSource();

      await source.saveRememberedAccount(
        remember: true,
        email: 'ahmed@example.com',
      );

      expect(await source.loadRememberedAccount(), (true, 'ahmed@example.com'));
    });

    test(
      'saving with remember: false erases the previously stored email',
      () async {
        final source = await buildSource();
        await source.saveRememberedAccount(
          remember: true,
          email: 'ahmed@example.com',
        );

        await source.saveRememberedAccount(
          remember: false,
          email: 'ahmed@example.com',
        );

        // The flag alone is not enough — the address itself must be gone, or
        // unchecking "remember me" would leave the email on disk.
        expect(await source.loadRememberedAccount(), (false, ''));
      },
    );

    test('overwrites a previously remembered email', () async {
      final source = await buildSource();
      await source.saveRememberedAccount(
        remember: true,
        email: 'first@example.com',
      );

      await source.saveRememberedAccount(
        remember: true,
        email: 'second@example.com',
      );

      expect(await source.loadRememberedAccount(), (
        true,
        'second@example.com',
      ));
    });
  });
}

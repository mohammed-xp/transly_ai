import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_theme/data/datasources/app_theme_local_data_source.dart';
import 'package:transly_ai/features/app_theme/data/repos/app_theme_repo_impl.dart';
import 'package:transly_ai/features/app_theme/domain/entities/app_theme_mode.dart';

class _FakeDataSource implements AppThemeLocalDataSource {
  _FakeDataSource({this.name, this.failOnRead = false, this.saveError});

  String? name;
  final bool failOnRead;
  final Object? saveError;

  @override
  String? getThemeModeName() {
    if (failOnRead) throw StateError('box closed');
    return name;
  }

  @override
  Future<void> saveThemeModeName(String name) async {
    final error = saveError;
    if (error != null) throw error;
    this.name = name;
  }
}

void main() {
  group('getThemeMode', () {
    test('maps the saved name to its mode', () {
      final repo = AppThemeRepoImpl(_FakeDataSource(name: 'dark'));

      expect(repo.getThemeMode(), AppThemeMode.dark);
    });

    test('follows the device when nothing is saved', () {
      final repo = AppThemeRepoImpl(_FakeDataSource());

      expect(repo.getThemeMode(), AppThemeMode.system);
    });

    test('follows the device for an unknown name', () {
      final repo = AppThemeRepoImpl(_FakeDataSource(name: 'sepia'));

      expect(repo.getThemeMode(), AppThemeMode.system);
    });

    test('follows the device when storage throws', () {
      final repo = AppThemeRepoImpl(_FakeDataSource(failOnRead: true));

      expect(repo.getThemeMode(), AppThemeMode.system);
    });
  });

  group('saveThemeMode', () {
    test('saves the mode name', () async {
      final dataSource = _FakeDataSource();
      final repo = AppThemeRepoImpl(dataSource);

      final result = await repo.saveThemeMode(AppThemeMode.light);

      expect(result, isA<ApiSuccess<void>>());
      expect(dataSource.name, 'light');
    });

    test('returns a failure when storage throws', () async {
      final repo = AppThemeRepoImpl(
        _FakeDataSource(saveError: Exception('disk full')),
      );

      final result = await repo.saveThemeMode(AppThemeMode.dark);

      expect(result, isA<ApiFailure<void>>());
      expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/app_update/data/models/app_update_model.dart';
import 'package:transly_ai/features/app_update/data/repos/app_update_repo_impl.dart';
import 'package:transly_ai/features/app_update/domain/entities/app_update_entity.dart';

import '../../../../helpers/fake_app_update_data_source.dart';

void main() {
  group('checkForUpdate', () {
    test('succeeds with null when there is no update', () async {
      final repo = AppUpdateRepoImpl(FakeAppUpdateDataSource());

      final result = await repo.checkForUpdate();

      expect((result as ApiSuccess<AppUpdateEntity?>).data, isNull);
    });

    test('maps the model to an entity', () async {
      final repo = AppUpdateRepoImpl(
        FakeAppUpdateDataSource(
          update: const AppUpdateModel(
            installedVersion: '2.1.0',
            latestVersion: '2.4.0',
            isRequired: true,
            releaseNotes: '- Faster\n- Friendlier',
          ),
        ),
      );

      final result = await repo.checkForUpdate();

      final update = (result as ApiSuccess<AppUpdateEntity?>).data!;
      expect(update.installedVersion, '2.1.0');
      expect(update.latestVersion, '2.4.0');
      expect(update.isRequired, isTrue);
      expect(update.releaseNotes, ['Faster', 'Friendlier']);
    });

    test('maps a thrown error to a failure', () async {
      final repo = AppUpdateRepoImpl(
        FakeAppUpdateDataSource(error: const NetworkException()),
      );

      final result = await repo.checkForUpdate();

      expect(
        (result as ApiFailure<AppUpdateEntity?>).failure,
        isA<NetworkFailure>(),
      );
    });
  });

  group('markPrompted', () {
    test('succeeds and forwards to the data source', () async {
      final dataSource = FakeAppUpdateDataSource();
      final repo = AppUpdateRepoImpl(dataSource);

      final result = await repo.markPrompted();

      expect(result, isA<ApiSuccess<void>>());
      expect(dataSource.markPromptedCalls, 1);
    });

    test('maps a thrown error to a failure', () async {
      final repo = AppUpdateRepoImpl(
        FakeAppUpdateDataSource(error: StateError('prefs unavailable')),
      );

      final result = await repo.markPrompted();

      expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
    });
  });

  group('openStore', () {
    test('succeeds and forwards to the data source', () async {
      final dataSource = FakeAppUpdateDataSource();
      final repo = AppUpdateRepoImpl(dataSource);

      final result = await repo.openStore();

      expect(result, isA<ApiSuccess<void>>());
      expect(dataSource.openStoreCalls, 1);
    });

    test('maps a missing store listing to UnknownFailure', () async {
      final repo = AppUpdateRepoImpl(
        FakeAppUpdateDataSource(error: const UnknownException()),
      );

      final result = await repo.openStore();

      expect((result as ApiFailure<void>).failure, isA<UnknownFailure>());
    });
  });
}

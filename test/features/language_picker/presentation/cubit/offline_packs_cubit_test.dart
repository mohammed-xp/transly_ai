import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/offline_model_error.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/offline_packs_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/offline_packs_state.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';
import '../../../../helpers/offline_packs_cubit_factory.dart';

void main() {
  late FakeLanguagesRepo languagesRepo;
  late FakeOfflineModelsRepo modelsRepo;

  setUp(() {
    languagesRepo = FakeLanguagesRepo(cached: testLanguages);
    modelsRepo = FakeOfflineModelsRepo(
      statuses: {
        'en': const OfflineModelBuiltIn(),
        'ar': const OfflineModelDownloaded(),
        'de': const OfflineModelNotDownloaded(),
      },
    );
  });

  OfflinePacksCubit buildCubit() {
    final cubit = buildOfflinePacksCubit(
      languages: languagesRepo,
      models: modelsRepo,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  Future<OfflinePacksCubit> loadedCubit() async {
    final cubit = buildCubit();
    await cubit.load();
    return cubit;
  }

  test('starts loading', () {
    expect(buildCubit().state.status, isA<OfflinePacksLoading>());
  });

  group('load', () {
    test('lists the cached languages with their statuses', () async {
      final cubit = await loadedCubit();

      final status = cubit.state.status as OfflinePacksLoaded;
      expect(status.languages, testLanguages);
      expect(cubit.state.modelStatuses['ar'], isA<OfflineModelDownloaded>());
    });

    test('does not ask the server when languages are cached', () async {
      await loadedCubit();

      expect(languagesRepo.syncCalls, 0);
    });

    test('asks the server when there is no cache yet', () async {
      languagesRepo.cached = const [];

      final cubit = await loadedCubit();

      expect(languagesRepo.syncCalls, 1);
      expect(cubit.state.status, isA<OfflinePacksLoaded>());
    });

    test('fails when the languages cannot be fetched', () async {
      languagesRepo
        ..cached = const []
        ..syncResult = const ApiResult.failure(NetworkFailure());

      final cubit = await loadedCubit();

      final status = cubit.state.status as OfflinePacksFailed;
      expect(status.failure, isA<NetworkFailure>());
    });

    test('fails when the device cannot report the statuses', () async {
      modelsRepo.statusesResult = const ApiResult.failure(UnknownFailure());

      final cubit = await loadedCubit();

      expect(cubit.state.status, isA<OfflinePacksFailed>());
    });

    test('a retry after a failure loads the packs', () async {
      modelsRepo.statusesResult = const ApiResult.failure(UnknownFailure());
      final cubit = await loadedCubit();

      modelsRepo.statusesResult = null;
      await cubit.load();

      expect(cubit.state.status, isA<OfflinePacksLoaded>());
    });

    test('keeps an update that arrived while loading', () async {
      modelsRepo.statusesGate = Completer();
      final cubit = buildCubit();
      final loading = cubit.load();
      await pumpEventQueue();

      modelsRepo.updates.add((
        code: 'de',
        status: const OfflineModelDownloading(),
      ));
      await pumpEventQueue();
      modelsRepo.statusesGate!.complete();
      await loading;

      expect(cubit.state.modelStatuses['de'], isA<OfflineModelDownloading>());
    });
  });

  group('grouping', () {
    test('installed holds the built-in and downloaded languages', () async {
      final cubit = await loadedCubit();

      expect(cubit.state.installed, [
        LanguageEntity.arabic,
        LanguageEntity.english,
      ]);
    });

    test('available holds the languages that can be downloaded', () async {
      final cubit = await loadedCubit();

      expect(cubit.state.available, [testGerman]);
    });

    test('leaves out the languages the device cannot translate', () async {
      final cubit = await loadedCubit();

      expect(cubit.state.installed, isNot(contains(testFrench)));
      expect(cubit.state.available, isNot(contains(testFrench)));
    });

    test('lists a downloading language among the installed ones', () async {
      modelsRepo.statuses['de'] = const OfflineModelDownloading();

      final cubit = await loadedCubit();

      expect(cubit.state.installed, contains(testGerman));
      expect(cubit.state.available, isEmpty);
    });

    test('counts an auto-downloaded pack', () async {
      modelsRepo.statuses['de'] = const OfflineModelDownloaded(isAuto: true);

      final cubit = await loadedCubit();

      expect(cubit.state.downloadedCount, 2);
    });

    test('counts the downloaded packs but not the built-in one', () async {
      final cubit = await loadedCubit();

      expect(cubit.state.downloadedCount, 1);
    });

    test('is empty before the packs are loaded', () {
      final cubit = buildCubit();

      expect(cubit.state.installed, isEmpty);
      expect(cubit.state.available, isEmpty);
    });
  });

  group('updates', () {
    test('a finished download moves the language to installed', () async {
      final cubit = await loadedCubit();

      modelsRepo.updates.add((
        code: 'de',
        status: const OfflineModelDownloaded(),
      ));
      await pumpEventQueue();

      expect(cubit.state.installed, contains(testGerman));
      expect(cubit.state.available, isEmpty);
      expect(cubit.state.downloadedCount, 2);
    });
  });

  group('downloadModel', () {
    test('downloads a language that is not on the device', () async {
      final cubit = await loadedCubit();

      await cubit.downloadModel(testGerman);

      expect(modelsRepo.downloads, ['de']);
    });

    test('ignores a language that is already downloaded', () async {
      final cubit = await loadedCubit();

      await cubit.downloadModel(LanguageEntity.arabic);

      expect(modelsRepo.downloads, isEmpty);
    });

    test('ignores a second tap while the first is running', () async {
      modelsRepo.downloadGate = Completer();
      final cubit = await loadedCubit();

      final first = cubit.downloadModel(testGerman);
      final second = cubit.downloadModel(testGerman);
      modelsRepo.downloadGate!.complete();
      await Future.wait([first, second]);

      expect(modelsRepo.downloads, ['de']);
    });

    test('reports a failed download', () async {
      modelsRepo.downloadResult = const ApiResult.failure(
        ModelDownloadFailure(),
      );
      final cubit = await loadedCubit();

      await cubit.downloadModel(testGerman);

      final error = cubit.state.modelError!;
      expect(error.language, testGerman);
      expect(error.failure, isA<ModelDownloadFailure>());
    });

    test('reports the same failure twice in a row', () async {
      modelsRepo.downloadResult = const ApiResult.failure(NetworkFailure());
      final cubit = await loadedCubit();
      final errors = <OfflineModelError>[];
      final subscription = cubit.stream
          .map((state) => state.modelError)
          .distinct()
          .listen((error) => errors.add(error!));
      addTearDown(subscription.cancel);

      await cubit.downloadModel(testGerman);
      await cubit.downloadModel(testGerman);
      await pumpEventQueue();

      expect(errors, hasLength(2));
    });
  });

  group('deleteModel', () {
    test('removes a downloaded language', () async {
      final cubit = await loadedCubit();

      await cubit.deleteModel(LanguageEntity.arabic);

      expect(modelsRepo.deletes, ['ar']);
    });

    test('never removes the built-in language', () async {
      final cubit = await loadedCubit();

      await cubit.deleteModel(LanguageEntity.english);

      expect(modelsRepo.deletes, isEmpty);
    });

    test('reports a failed removal', () async {
      modelsRepo.deleteResult = const ApiResult.failure(UnknownFailure());
      final cubit = await loadedCubit();

      await cubit.deleteModel(LanguageEntity.arabic);

      expect(cubit.state.modelError!.failure, isA<UnknownFailure>());
    });
  });

  group('settings', () {
    test('start from the saved settings', () {
      modelsRepo.settings = (autoDownload: false, wifiOnly: true);

      expect(buildCubit().state.settings, (
        autoDownload: false,
        wifiOnly: true,
      ));
    });

    test('turning auto-download off saves it', () async {
      final cubit = buildCubit();

      final saved = await cubit.setAutoDownload(false);

      expect(saved, isTrue);
      expect(cubit.state.settings.autoDownload, isFalse);
      expect(modelsRepo.savedSettings, [(autoDownload: false, wifiOnly: true)]);
    });

    test('turning Wi-Fi only off saves it', () async {
      final cubit = buildCubit();

      await cubit.setWifiOnly(false);

      expect(cubit.state.settings, (autoDownload: true, wifiOnly: false));
      expect(modelsRepo.savedSettings, [(autoDownload: true, wifiOnly: false)]);
    });

    test('picking the current value saves nothing', () async {
      final cubit = buildCubit();

      final saved = await cubit.setAutoDownload(true);

      expect(saved, isTrue);
      expect(modelsRepo.savedSettings, isEmpty);
    });

    test('a failed save puts the switch back', () async {
      modelsRepo.saveSettingsResult = const ApiResult.failure(UnknownFailure());
      final cubit = buildCubit();

      final saved = await cubit.setAutoDownload(false);

      expect(saved, isFalse);
      expect(cubit.state.settings.autoDownload, isTrue);
    });
  });

  test('stops listening to updates once closed', () async {
    final cubit = buildCubit();
    await cubit.close();

    modelsRepo.updates.add((
      code: 'de',
      status: const OfflineModelDownloaded(),
    ));
    await pumpEventQueue();

    expect(cubit.state.modelStatuses, isEmpty);
  });
}

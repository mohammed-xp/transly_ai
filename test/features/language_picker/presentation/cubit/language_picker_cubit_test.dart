import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/entities/language_side.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/entities/offline_model_status.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/add_recent_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/delete_offline_model_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/download_offline_model_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_model_statuses_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_recent_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/select_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/sync_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/watch_offline_model_updates_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/language_picker_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/language_picker_state.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/offline_model_error.dart';

import '../../../../helpers/fake_languages_repo.dart';
import '../../../../helpers/fake_offline_models_repo.dart';

void main() {
  const initialPair = (from: LanguageEntity.english, to: LanguageEntity.arabic);

  LanguagePickerCubit buildCubit(
    FakeLanguagesRepo repo, {
    FakeOfflineModelsRepo? models,
  }) {
    final modelsRepo = models ?? FakeOfflineModelsRepo();
    final cubit = LanguagePickerCubit(
      initialPair: initialPair,
      getCachedLanguages: GetCachedLanguagesUseCase(repo),
      syncLanguages: SyncLanguagesUseCase(repo),
      getRecentLanguages: GetRecentLanguagesUseCase(repo),
      addRecentLanguage: AddRecentLanguageUseCase(repo),
      selectLanguage: const SelectLanguageUseCase(),
      getOfflineModelStatuses: GetOfflineModelStatusesUseCase(modelsRepo),
      watchOfflineModelUpdates: WatchOfflineModelUpdatesUseCase(modelsRepo),
      downloadOfflineModel: DownloadOfflineModelUseCase(modelsRepo),
      deleteOfflineModel: DeleteOfflineModelUseCase(modelsRepo),
    );
    addTearDown(cubit.close);
    return cubit;
  }

  LanguagesLoaded loaded(LanguagePickerCubit cubit) =>
      cubit.state.status as LanguagesLoaded;

  group('initial state', () {
    test('holds the pair the sheet was opened with', () {
      final cubit = buildCubit(FakeLanguagesRepo());

      expect(cubit.state.pair, initialPair);
    });

    test('holds the saved recents', () {
      final cubit = buildCubit(FakeLanguagesRepo(recents: [testFrench]));

      expect(cubit.state.recents, [testFrench]);
    });

    test('is loading', () {
      final cubit = buildCubit(FakeLanguagesRepo());

      expect(cubit.state.status, isA<LanguagesLoading>());
    });
  });

  group('load', () {
    test('shows the cached languages', () async {
      final cubit = buildCubit(FakeLanguagesRepo(cached: testLanguages));

      await cubit.load();

      expect(loaded(cubit).languages, testLanguages);
    });

    test('does not ask the server when languages are cached', () async {
      final repo = FakeLanguagesRepo(cached: testLanguages);
      final cubit = buildCubit(repo);

      await cubit.load();

      expect(repo.syncCalls, 0);
    });

    test('fetches the languages when nothing is cached', () async {
      final repo = FakeLanguagesRepo();
      final cubit = buildCubit(repo);

      await cubit.load();

      expect(repo.syncCalls, 1);
      expect(loaded(cubit).languages, testLanguages);
    });

    test('fails with the failure from the fetch', () async {
      final cubit = buildCubit(
        FakeLanguagesRepo(
          syncResult: const ApiResult.failure(NetworkFailure()),
        ),
      );

      await cubit.load();

      expect(
        (cubit.state.status as LanguagesFailed).failure,
        isA<NetworkFailure>(),
      );
    });

    test('recovers on a retry after a failure', () async {
      final repo = FakeLanguagesRepo(
        syncResult: const ApiResult.failure(NetworkFailure()),
      );
      final cubit = buildCubit(repo);
      await cubit.load();

      repo.syncResult = const ApiResult.success(testLanguages);
      await cubit.load();

      expect(cubit.state.status, isA<LanguagesLoaded>());
    });

    test('does nothing once closed', () async {
      final repo = FakeLanguagesRepo(cached: testLanguages);
      final cubit = buildCubit(repo);
      await cubit.close();

      await expectLater(cubit.load(), completes);
      expect(cubit.state.status, isA<LanguagesLoading>());
    });

    test('does not emit when closed while fetching', () async {
      final cubit = buildCubit(FakeLanguagesRepo());

      final loading = cubit.load();
      await cubit.close();

      await expectLater(loading, completes);
    });

    test('applies a search typed while the languages were loading', () async {
      final cubit = buildCubit(FakeLanguagesRepo());

      final loading = cubit.load();
      cubit.queryChanged('germ');
      await loading;

      expect(loaded(cubit).visibleLanguages, [testGerman]);
    });
  });

  group('queryChanged', () {
    Future<LanguagePickerCubit> loadedCubit() async {
      final cubit = buildCubit(FakeLanguagesRepo(cached: testLanguages));
      await cubit.load();
      return cubit;
    }

    test('matches the English name, ignoring case', () async {
      final cubit = await loadedCubit();

      cubit.queryChanged('GERM');

      expect(loaded(cubit).visibleLanguages, [testGerman]);
    });

    test('matches the native name', () async {
      final cubit = await loadedCubit();

      cubit.queryChanged('عرب');

      expect(loaded(cubit).visibleLanguages, [LanguageEntity.arabic]);
    });

    test('matches the exact code', () async {
      final cubit = await loadedCubit();

      cubit.queryChanged('fr');

      expect(loaded(cubit).visibleLanguages, [testFrench]);
    });

    test('shows nothing when no language matches', () async {
      final cubit = await loadedCubit();

      cubit.queryChanged('zzz');

      expect(loaded(cubit).visibleLanguages, isEmpty);
      expect(loaded(cubit).languages, testLanguages);
    });

    test('a blank query shows every language again', () async {
      final cubit = await loadedCubit();
      cubit.queryChanged('germ');

      cubit.queryChanged('  ');

      expect(loaded(cubit).visibleLanguages, testLanguages);
      expect(cubit.state.isSearching, isFalse);
    });
  });

  group('pick', () {
    test('a new language replaces the side it was picked for', () async {
      final cubit = buildCubit(FakeLanguagesRepo());

      await cubit.pick(LanguageSide.target, testGerman);

      expect(cubit.state.pair, (from: LanguageEntity.english, to: testGerman));
    });

    test('a new language goes first in the recents', () async {
      final cubit = buildCubit(FakeLanguagesRepo(recents: [testFrench]));

      await cubit.pick(LanguageSide.target, testGerman);

      expect(cubit.state.recents, [testGerman, testFrench]);
    });

    test('the other side\'s language swaps the pair', () async {
      final cubit = buildCubit(FakeLanguagesRepo());

      await cubit.pick(LanguageSide.source, LanguageEntity.arabic);

      expect(cubit.state.pair, (
        from: LanguageEntity.arabic,
        to: LanguageEntity.english,
      ));
    });

    test('a swap does not change the recents', () async {
      final repo = FakeLanguagesRepo(recents: [testFrench]);
      final cubit = buildCubit(repo);

      await cubit.pick(LanguageSide.source, LanguageEntity.arabic);

      expect(cubit.state.recents, [testFrench]);
      expect(repo.recents, [testFrench]);
    });

    test('the side\'s own language changes nothing', () async {
      final cubit = buildCubit(FakeLanguagesRepo());
      final states = <LanguagePickerState>[];
      final subscription = cubit.stream.listen(states.add);
      addTearDown(subscription.cancel);

      await cubit.pick(LanguageSide.target, LanguageEntity.arabic);

      expect(states, isEmpty);
    });

    test('keeps the recents when saving them fails', () async {
      final cubit = buildCubit(
        FakeLanguagesRepo(
          recents: [testFrench],
          saveResult: const ApiResult.failure(UnknownFailure()),
        ),
      );

      await cubit.pick(LanguageSide.target, testGerman);

      expect(cubit.state.recents, [testFrench]);
      expect(cubit.state.pair.to, testGerman);
    });

    test('keeps the current search', () async {
      final cubit = buildCubit(FakeLanguagesRepo(cached: testLanguages));
      await cubit.load();
      cubit.queryChanged('germ');

      await cubit.pick(LanguageSide.target, testGerman);

      expect(cubit.state.query, 'germ');
      expect(loaded(cubit).visibleLanguages, [testGerman]);
    });

    test('does nothing once closed', () async {
      final cubit = buildCubit(FakeLanguagesRepo());
      await cubit.close();

      await expectLater(cubit.pick(LanguageSide.target, testGerman), completes);
    });
  });

  group('offline models', () {
    Future<LanguagePickerCubit> loadedCubit(
      FakeOfflineModelsRepo models,
    ) async {
      final cubit = buildCubit(
        FakeLanguagesRepo(cached: testLanguages),
        models: models,
      );
      await cubit.load();
      return cubit;
    }

    test('load fetches the status of every listed language', () async {
      final cubit = await loadedCubit(
        FakeOfflineModelsRepo(
          statuses: {
            'en': const OfflineModelBuiltIn(),
            'de': const OfflineModelDownloaded(),
            'fr': const OfflineModelNotDownloaded(),
          },
        ),
      );

      expect(cubit.state.modelStatuses['de'], isA<OfflineModelDownloaded>());
      expect(
        cubit.state.modelStatuses.keys,
        unorderedEquals(['ar', 'en', 'de', 'fr']),
      );
    });

    test('load fetches the statuses after a fresh sync too', () async {
      final cubit = buildCubit(
        FakeLanguagesRepo(),
        models: FakeOfflineModelsRepo(
          statuses: {'fr': const OfflineModelNotDownloaded()},
        ),
      );

      await cubit.load();

      expect(cubit.state.modelStatuses['fr'], isA<OfflineModelNotDownloaded>());
    });

    test('a failed status check leaves the statuses empty', () async {
      final cubit = await loadedCubit(
        FakeOfflineModelsRepo(
          statusesResult: const ApiResult.failure(UnknownFailure()),
        ),
      );

      expect(cubit.state.modelStatuses, isEmpty);
      expect(cubit.state.status, isA<LanguagesLoaded>());
    });

    test('applies a status update from the repo', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
      );
      final cubit = await loadedCubit(models);

      models.updates.add((code: 'fr', status: const OfflineModelDownloading()));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.modelStatuses['fr'], isA<OfflineModelDownloading>());
    });

    test('downloadModel downloads a language that is not downloaded', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
      );
      final cubit = await loadedCubit(models);

      await cubit.downloadModel(testFrench);

      expect(models.downloads, ['fr']);
    });

    test(
      'downloadModel ignores a language that is already downloaded',
      () async {
        final models = FakeOfflineModelsRepo(
          statuses: {'de': const OfflineModelDownloaded()},
        );
        final cubit = await loadedCubit(models);

        await cubit.downloadModel(testGerman);

        expect(models.downloads, isEmpty);
      },
    );

    test('a failed download reports the failure', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
        downloadResult: const ApiResult.failure(NetworkFailure()),
      );
      final cubit = await loadedCubit(models);

      await cubit.downloadModel(testFrench);

      expect(cubit.state.modelError?.language, testFrench);
      expect(cubit.state.modelError?.failure, isA<NetworkFailure>());
    });

    test('the same failure twice is reported as a new error', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
        downloadResult: const ApiResult.failure(NetworkFailure()),
      );
      final cubit = await loadedCubit(models);
      await cubit.downloadModel(testFrench);
      final first = cubit.state.modelError;

      await cubit.downloadModel(testFrench);

      expect(cubit.state.modelError, isNot(same(first)));
    });

    test('deleteModel removes a downloaded language', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'de': const OfflineModelDownloaded()},
      );
      final cubit = await loadedCubit(models);

      await cubit.deleteModel(testGerman);

      expect(models.deletes, ['de']);
    });

    test('deleteModel ignores a built-in language', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'en': const OfflineModelBuiltIn()},
      );
      final cubit = await loadedCubit(models);

      await cubit.deleteModel(LanguageEntity.english);

      expect(models.deletes, isEmpty);
    });

    test('a failed removal reports the failure', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'de': const OfflineModelDownloaded()},
        deleteResult: const ApiResult.failure(UnknownFailure()),
      );
      final cubit = await loadedCubit(models);

      await cubit.deleteModel(testGerman);

      expect(cubit.state.modelError?.failure, isA<UnknownFailure>());
    });

    test('a quick second download tap is ignored', () async {
      final gate = Completer<void>();
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
        downloadResult: const ApiResult.failure(NetworkFailure()),
      )..downloadGate = gate;
      final cubit = await loadedCubit(models);
      final errors = <OfflineModelError>[];
      final subscription = cubit.stream
          .map((state) => state.modelError)
          .where((error) => error != null)
          .distinct()
          .listen((error) => errors.add(error!));
      addTearDown(subscription.cancel);

      final first = cubit.downloadModel(testFrench);
      final second = cubit.downloadModel(testFrench);
      gate.complete();
      await Future.wait([first, second]);
      await Future<void>.delayed(Duration.zero);

      expect(models.downloads, ['fr']);
      expect(errors, hasLength(1));
    });

    test('deleteModel ignores a language that is not downloaded', () async {
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
      );
      final cubit = await loadedCubit(models);

      await cubit.deleteModel(testFrench);

      expect(models.deletes, isEmpty);
    });

    test('an update arriving while the statuses load wins', () async {
      final gate = Completer<void>();
      final models = FakeOfflineModelsRepo(
        statuses: {'fr': const OfflineModelNotDownloaded()},
      )..statusesGate = gate;
      final cubit = buildCubit(
        FakeLanguagesRepo(cached: testLanguages),
        models: models,
      );

      final loading = cubit.load();
      models.updates.add((code: 'fr', status: const OfflineModelDownloading()));
      await Future<void>.delayed(Duration.zero);
      gate.complete();
      await loading;

      expect(cubit.state.modelStatuses['fr'], isA<OfflineModelDownloading>());
    });

    test('stops listening for updates once closed', () async {
      final models = FakeOfflineModelsRepo();
      final cubit = await loadedCubit(models);

      await cubit.close();

      expect(models.updates.hasListener, isFalse);
    });
  });
}

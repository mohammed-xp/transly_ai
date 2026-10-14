import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/entities/language_side.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/add_recent_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_recent_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/select_language_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/sync_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/language_picker_cubit.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/language_picker_state.dart';

import '../../../../helpers/fake_languages_repo.dart';

void main() {
  const initialPair = (from: LanguageEntity.english, to: LanguageEntity.arabic);

  LanguagePickerCubit buildCubit(FakeLanguagesRepo repo) {
    final cubit = LanguagePickerCubit(
      initialPair: initialPair,
      getCachedLanguages: GetCachedLanguagesUseCase(repo),
      syncLanguages: SyncLanguagesUseCase(repo),
      getRecentLanguages: GetRecentLanguagesUseCase(repo),
      addRecentLanguage: AddRecentLanguageUseCase(repo),
      selectLanguage: const SelectLanguageUseCase(),
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
}

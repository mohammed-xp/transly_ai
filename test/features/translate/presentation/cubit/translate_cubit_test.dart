import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/services/tts_service.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/auto_download_offline_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/entities/tone_catalog.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/usecases/get_cached_tones_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/get_saved_tone_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/save_tone_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/speak_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/sync_tones_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/watch_online_availability_usecase.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_cubit.dart';

import '../../../../helpers/fake_offline_models_repo.dart';
import '../../../../helpers/fake_translation_repo.dart';

class _SilentTts implements TtsService {
  @override
  Future<void> speak({required String text, required String languageCode}) =>
      Future.value();

  @override
  Future<void> stop() => Future.value();
}

const _friendlyTone = TranslationTone(
  code: 'friendly',
  name: 'Friendly',
  nameAr: '',
);

void main() {
  TranslateCubit buildCubit(FakeTranslationRepo repo) {
    return TranslateCubit(
      translateText: TranslateTextUseCase(
        repo,
        AutoDownloadOfflineModelsUseCase(FakeOfflineModelsRepo()),
      ),
      speakText: SpeakTextUseCase(_SilentTts()),
      watchOnlineAvailability: WatchOnlineAvailabilityUseCase(repo),
      getCachedTones: GetCachedTonesUseCase(repo),
      syncTones: SyncTonesUseCase(repo),
      getSavedTone: GetSavedToneUseCase(repo),
      saveTone: SaveToneUseCase(repo),
    );
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('tones', () {
    test('starts on the cached tones and the saved tone', () {
      final repo = FakeTranslationRepo(savedToneCode: 'casual');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      expect(cubit.state.tones, defaultToneCatalog.tones);
      expect(cubit.state.tone, casualTone);
    });

    test('starts on the default tone when nothing is saved', () {
      final cubit = buildCubit(FakeTranslationRepo());
      addTearDown(cubit.close);

      expect(cubit.state.tone, formalTone);
    });

    test('replaces the cached tones with the synced ones', () async {
      final repo = FakeTranslationRepo(
        syncedTones: const ToneCatalog(
          tones: [formalTone, _friendlyTone],
          defaultCode: 'formal',
        ),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await settle();

      expect(cubit.state.tones, [formalTone, _friendlyTone]);
    });

    test('keeps the current tone when the sync still offers it', () async {
      final repo = FakeTranslationRepo(
        savedToneCode: 'casual',
        syncedTones: const ToneCatalog(
          tones: [formalTone, casualTone],
          defaultCode: 'formal',
        ),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await settle();

      expect(cubit.state.tone, casualTone);
    });

    test('moves to the default when the sync drops the current tone', () async {
      final repo = FakeTranslationRepo(
        savedToneCode: 'concise',
        syncedTones: const ToneCatalog(
          tones: [formalTone, casualTone],
          defaultCode: 'casual',
        ),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await settle();

      expect(cubit.state.tone, casualTone);
    });

    test('keeps the cached tones when the sync fails', () async {
      final repo = FakeTranslationRepo(syncFailure: const NetworkFailure());
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await settle();

      expect(cubit.state.tones, defaultToneCatalog.tones);
    });

    test('has no tones without a cache and a failed sync', () async {
      final repo = FakeTranslationRepo(
        cachedTones: null,
        syncFailure: const NetworkFailure(),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await settle();

      expect(cubit.state.tones, isEmpty);
      expect(cubit.state.tone, isNull);
    });

    test('syncs again once online when there are still no tones', () async {
      final repo = FakeTranslationRepo(
        cachedTones: null,
        syncFailure: const NetworkFailure(),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      await settle();
      repo
        ..syncFailure = null
        ..syncedTones = defaultToneCatalog;

      repo.onlineAvailability.add(true);
      await settle();

      expect(repo.syncCalls, 2);
      expect(cubit.state.tone, formalTone);
    });

    test('does not sync again once online when tones exist', () async {
      final repo = FakeTranslationRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      await settle();

      repo.onlineAvailability.add(true);
      await settle();

      expect(repo.syncCalls, 1);
    });
  });

  group('toneChanged', () {
    test('saves the tone code while online', () async {
      final repo = FakeTranslationRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      repo.onlineAvailability.add(true);
      await settle();

      cubit.toneChanged(conciseTone);

      expect(cubit.state.tone, conciseTone);
      expect(repo.savedToneCodes, ['concise']);
    });

    test('does not save while offline', () async {
      final repo = FakeTranslationRepo();
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      repo.onlineAvailability.add(false);
      await settle();

      cubit.toneChanged(casualTone);

      expect(repo.savedToneCodes, isEmpty);
    });

    test('does not re-save the current tone', () async {
      final repo = FakeTranslationRepo(savedToneCode: 'casual');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      repo.onlineAvailability.add(true);
      await settle();

      cubit.toneChanged(casualTone);

      expect(repo.savedToneCodes, isEmpty);
    });
  });

  group('translate', () {
    test('sends the selected tone code', () async {
      final repo = FakeTranslationRepo(savedToneCode: 'casual');
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      cubit.sourceTextChanged('hello');

      cubit.translateNow();
      await settle();

      expect(repo.requestedTones, ['casual']);
    });

    test('sends no tone when there are no tones', () async {
      final repo = FakeTranslationRepo(
        cachedTones: null,
        syncFailure: const NetworkFailure(),
      );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);
      cubit.sourceTextChanged('hello');

      cubit.translateNow();
      await settle();

      expect(repo.requestedTones, [null]);
    });
  });
}

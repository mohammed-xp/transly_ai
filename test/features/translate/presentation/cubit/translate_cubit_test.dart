import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/services/tts_service.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/usecases/get_saved_tone_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/save_tone_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/speak_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/watch_online_availability_usecase.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_cubit.dart';

import '../../../../helpers/fake_translation_repo.dart';

class _SilentTts implements TtsService {
  @override
  Future<void> speak({required String text, required String languageCode}) =>
      Future.value();

  @override
  Future<void> stop() => Future.value();
}

void main() {
  TranslateCubit buildCubit(FakeTranslationRepo repo) {
    return TranslateCubit(
      translateText: TranslateTextUseCase(repo),
      speakText: SpeakTextUseCase(_SilentTts()),
      watchOnlineAvailability: WatchOnlineAvailabilityUseCase(repo),
      getSavedTone: GetSavedToneUseCase(repo),
      saveTone: SaveToneUseCase(repo),
    );
  }

  test('starts on the saved tone', () {
    final repo = FakeTranslationRepo(savedTone: TranslationTone.casual);
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);

    expect(cubit.state.tone, TranslationTone.casual);
  });

  test('toneChanged saves the tone while online', () async {
    final repo = FakeTranslationRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    repo.onlineAvailability.add(true);
    await Future<void>.delayed(Duration.zero);

    cubit.toneChanged(TranslationTone.concise);

    expect(cubit.state.tone, TranslationTone.concise);
    expect(repo.savedTones, [TranslationTone.concise]);
  });

  test('toneChanged does not save while offline', () async {
    final repo = FakeTranslationRepo();
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    repo.onlineAvailability.add(false);
    await Future<void>.delayed(Duration.zero);

    cubit.toneChanged(TranslationTone.casual);

    expect(repo.savedTones, isEmpty);
  });

  test('toneChanged does not re-save the current tone', () async {
    final repo = FakeTranslationRepo(savedTone: TranslationTone.casual);
    final cubit = buildCubit(repo);
    addTearDown(cubit.close);
    repo.onlineAvailability.add(true);
    await Future<void>.delayed(Duration.zero);

    cubit.toneChanged(TranslationTone.casual);

    expect(repo.savedTones, isEmpty);
  });
}

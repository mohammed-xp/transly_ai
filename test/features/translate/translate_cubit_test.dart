import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/repos/translation_repository.dart';
import 'package:transly_ai/features/translate/domain/usecases/check_translation_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/download_translation_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_cubit.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_state.dart';

/// Deterministic in-memory repository. Real use cases wrap it so the cubit is
/// exercised through its real dependencies (no mocking framework).
class _FakeTranslationRepository implements TranslationRepository {
  bool modelsDownloaded = true;
  Failure? downloadFailure;
  Failure? translateFailure;
  Duration translateDelay = Duration.zero;
  int translateCallCount = 0;

  @override
  Future<ApiResult<bool>> areModelsDownloaded({
    required Language from,
    required Language to,
  }) async {
    return ApiResult.success(modelsDownloaded);
  }

  @override
  Future<ApiResult<void>> downloadModels({
    required Language from,
    required Language to,
  }) async {
    if (downloadFailure != null) return ApiResult.failure(downloadFailure!);
    modelsDownloaded = true;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<TranslationEntity>> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async {
    translateCallCount++;
    if (translateDelay > Duration.zero) {
      await Future<void>.delayed(translateDelay);
    }
    if (translateFailure != null) return ApiResult.failure(translateFailure!);
    return ApiResult.success(
      TranslationEntity(
        sourceText: text,
        translatedText: 'x:$text',
        from: from,
        to: to,
      ),
    );
  }
}

TranslateCubit _buildCubit(_FakeTranslationRepository repo) {
  return TranslateCubit(
    translateText: TranslateTextUseCase(repo),
    checkModels: CheckTranslationModelsUseCase(repo),
    downloadModels: DownloadTranslationModelsUseCase(repo),
  );
}

List<TranslationStatus> _statuses(List<TranslateState> states) =>
    states.map((s) => s.status).toList();

void main() {
  group('TranslateCubit', () {
    test('starts idle with the offline defaults', () {
      final cubit = _buildCubit(_FakeTranslationRepository());
      addTearDown(cubit.close);

      expect(cubit.state.status, isA<TranslationIdle>());
      expect(cubit.state.from, Language.english);
      expect(cubit.state.to, Language.arabic);
      expect(cubit.state.tone, TranslationTone.formal);
      expect(cubit.state.isToneEnabled, isFalse);
    });

    test('does not translate until the debounce elapses, then succeeds', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);
        final emitted = <TranslateState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.sourceTextChanged('hi');

        // One tick before the debounce completes: nothing translated yet.
        async.elapse(
          TranslateCubit.debounceDuration - const Duration(milliseconds: 1),
        );
        async.flushMicrotasks();
        expect(repo.translateCallCount, 0);

        // After the full debounce: in-progress then done.
        async.elapse(const Duration(milliseconds: 1));
        async.flushMicrotasks();

        expect(repo.translateCallCount, 1);
        expect(_statuses(emitted), [
          isA<TranslationIdle>(), // from sourceTextChanged
          isA<TranslationInProgress>(),
          isA<TranslationDone>(),
        ]);
        expect(cubit.state.translatedText, 'x:hi');

        sub.cancel();
        cubit.close();
      });
    });

    test('rapid typing restarts the debounce — only one translation runs', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);

        cubit.sourceTextChanged('h');
        async.elapse(const Duration(milliseconds: 300));
        cubit.sourceTextChanged('he'); // restarts the timer
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(repo.translateCallCount, 0); // 600ms not yet since last keystroke

        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        expect(repo.translateCallCount, 1);

        cubit.close();
      });
    });

    test('empty input clears output and stays idle without translating', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);

        cubit.sourceTextChanged('   ');
        async.elapse(TranslateCubit.debounceDuration + const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(repo.translateCallCount, 0);
        expect(cubit.state.status, isA<TranslationIdle>());
        expect(cubit.state.translatedText, '');

        cubit.close();
      });
    });

    test('downloads the model first when it is missing', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()..modelsDownloaded = false;
        final cubit = _buildCubit(repo);
        final emitted = <TranslateState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.sourceTextChanged('hi');
        cubit.translateNow(); // skip the debounce
        async.flushMicrotasks();

        final statuses = _statuses(emitted);
        final downloadIndex =
            statuses.indexWhere((s) => s is TranslationDownloadingModel);
        final inProgressIndex =
            statuses.indexWhere((s) => s is TranslationInProgress);
        expect(downloadIndex, greaterThanOrEqualTo(0));
        expect(inProgressIndex, greaterThan(downloadIndex));
        expect(cubit.state.status, isA<TranslationDone>());

        sub.cancel();
        cubit.close();
      });
    });

    test('emits a ModelDownloadFailure error when the download fails', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..modelsDownloaded = false
          ..downloadFailure = const ModelDownloadFailure();
        final cubit = _buildCubit(repo);

        cubit.sourceTextChanged('hi');
        cubit.translateNow(); // skip the debounce
        async.flushMicrotasks();

        expect(repo.translateCallCount, 0);
        final status = cubit.state.status;
        expect(status, isA<TranslationError>());
        expect((status as TranslationError).failure, isA<ModelDownloadFailure>());

        cubit.close();
      });
    });

    test('swap flips the pair, moves output to source, and retranslates', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();
        expect(cubit.state.translatedText, 'x:hi');

        cubit.swapLanguages();
        async.flushMicrotasks();

        expect(cubit.state.from, Language.arabic);
        expect(cubit.state.to, Language.english);
        expect(cubit.state.sourceText, 'x:hi'); // previous output became source
        expect(cubit.state.translatedText, 'x:x:hi');
        expect(repo.translateCallCount, 2);

        cubit.close();
      });
    });

    test('a stale translation does not overwrite a newer one', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..translateDelay = const Duration(seconds: 1);
        final cubit = _buildCubit(repo);
        final emitted = <TranslateState>[];
        final sub = cubit.stream.listen(emitted.add);

        // Two translations in flight; the first is still awaiting its delay.
        cubit.sourceTextChanged('one');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks(); // run1 past checkModels, now in the delay
        cubit.translateNow(); // run2 starts, bumps the request id
        async.flushMicrotasks(); // run2 past checkModels, now in the delay

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks(); // both delays complete

        // Only the latest run emits Done — the stale one bails.
        final doneCount =
            _statuses(emitted).whereType<TranslationDone>().length;
        expect(doneCount, 1);
        expect(repo.translateCallCount, 2);

        sub.cancel();
        cubit.close();
      });
    });

    test('typing during an in-flight translation supersedes it', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..translateDelay = const Duration(seconds: 1);
        final cubit = _buildCubit(repo);
        final emitted = <TranslateState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.sourceTextChanged('one');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks(); // run for 'one' is now awaiting its delay

        cubit.sourceTextChanged('two'); // supersedes the in-flight run
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks(); // 'one' completes but must not emit

        expect(
          emitted.where((s) => s.translatedText == 'x:one'),
          isEmpty,
          reason: 'stale result must never pair with newer source text',
        );

        // The rescheduled debounce translates the newer text.
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(cubit.state.translatedText, 'x:two');
        expect(cubit.state.status, isA<TranslationDone>());

        sub.cancel();
        cubit.close();
      });
    });

    test('swap without an output only flips the pair — no retranslation', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);

        cubit.sourceTextChanged('hello'); // debounce still pending
        cubit.swapLanguages();
        async.elapse(TranslateCubit.debounceDuration + const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(cubit.state.from, Language.arabic);
        expect(cubit.state.to, Language.english);
        expect(cubit.state.sourceText, 'hello'); // source text kept as-is
        expect(repo.translateCallCount, 0,
            reason: 'old-language text must not be retranslated reversed');
        expect(cubit.state.status, isA<TranslationIdle>());

        cubit.close();
      });
    });

    test('translateNow with empty text does nothing', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);

        cubit.translateNow();
        async.flushMicrotasks();

        expect(repo.translateCallCount, 0);
        expect(cubit.state.status, isA<TranslationIdle>());

        cubit.close();
      });
    });

    test('toneChanged is inert while the tone selector is disabled', () {
      final cubit = _buildCubit(_FakeTranslationRepository());
      addTearDown(cubit.close);

      cubit.toneChanged(TranslationTone.concise);

      expect(cubit.state.tone, TranslationTone.formal);
    });

    test('does not emit after being closed mid-debounce', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);
        final emitted = <TranslateState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.sourceTextChanged('hi');
        cubit.close();

        async.elapse(TranslateCubit.debounceDuration + const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(repo.translateCallCount, 0);
        expect(
          _statuses(emitted).whereType<TranslationInProgress>(),
          isEmpty,
        );

        sub.cancel();
      });
    });
  });
}

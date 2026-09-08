import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/errors/failure.dart';
import 'package:transly_ai/core/result/api_result.dart';
import 'package:transly_ai/core/services/tts_service.dart';
import 'package:transly_ai/features/translate/domain/entities/language.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_engine.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_entity.dart';
import 'package:transly_ai/features/translate/domain/entities/translation_tone.dart';
import 'package:transly_ai/features/translate/domain/repos/translation_repository.dart';
import 'package:transly_ai/features/translate/domain/usecases/check_translation_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/download_translation_models_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/speak_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/translate_text_usecase.dart';
import 'package:transly_ai/features/translate/domain/usecases/watch_online_availability_usecase.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_cubit.dart';
import 'package:transly_ai/features/translate/presentation/cubit/translate_state.dart';

/// Deterministic in-memory repository. Real use cases wrap it so the cubit is
/// exercised through its real dependencies (no mocking framework).
///
/// [watchOnlineAvailability] never emits by default — this keeps every
/// pre-existing test's [TranslateState.isToneEnabled] expectations driven
/// solely by the post-translate `engine` field, exactly as before. Tests that
/// care about the online-availability signal call [setOnlineAvailable].
class _FakeTranslationRepository implements TranslationRepository {
  bool modelsDownloaded = true;
  Failure? downloadFailure;
  Failure? translateFailure;
  Duration translateDelay = Duration.zero;
  int translateCallCount = 0;
  TranslationEngine engine = TranslationEngine.offline;
  TranslationTone? receivedTone;

  final _onlineAvailability = StreamController<bool>.broadcast();

  void setOnlineAvailable(bool available) => _onlineAvailability.add(available);

  void failOnlineAvailability(Object error) =>
      _onlineAvailability.addError(error);

  bool get onlineAvailabilityHasListener => _onlineAvailability.hasListener;

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
    receivedTone = tone;
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
        engine: engine,
      ),
    );
  }

  @override
  Stream<bool> watchOnlineAvailability() => _onlineAvailability.stream;
}

/// Records speak/stop calls instead of touching a platform channel.
class _FakeTtsService implements TtsService {
  final List<String> speakCalls = [];
  int stopCallCount = 0;

  @override
  Future<void> speak({
    required String text,
    required String languageCode,
  }) async {
    speakCalls.add('$languageCode:$text');
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
  }
}

TranslateCubit _buildCubit(
  _FakeTranslationRepository repo, {
  _FakeTtsService? tts,
}) {
  return TranslateCubit(
    translateText: TranslateTextUseCase(repo),
    checkModels: CheckTranslationModelsUseCase(repo),
    downloadModels: DownloadTranslationModelsUseCase(repo),
    speakText: SpeakTextUseCase(tts ?? _FakeTtsService()),
    watchOnlineAvailability: WatchOnlineAvailabilityUseCase(repo),
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
        expect(
          repo.translateCallCount,
          0,
        ); // 600ms not yet since last keystroke

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
        async.elapse(
          TranslateCubit.debounceDuration + const Duration(seconds: 1),
        );
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
        final downloadIndex = statuses.indexWhere(
          (s) => s is TranslationDownloadingModel,
        );
        final inProgressIndex = statuses.indexWhere(
          (s) => s is TranslationInProgress,
        );
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
        expect(
          (status as TranslationError).failure,
          isA<ModelDownloadFailure>(),
        );

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
        final doneCount = _statuses(
          emitted,
        ).whereType<TranslationDone>().length;
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
        async.elapse(
          TranslateCubit.debounceDuration + const Duration(seconds: 1),
        );
        async.flushMicrotasks();

        expect(cubit.state.from, Language.arabic);
        expect(cubit.state.to, Language.english);
        expect(cubit.state.sourceText, 'hello'); // source text kept as-is
        expect(
          repo.translateCallCount,
          0,
          reason: 'old-language text must not be retranslated reversed',
        );
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

    test('an online translation enables the tone selector', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..engine = TranslationEngine.online;
        final cubit = _buildCubit(repo);

        // In production these are coupled: the repository only routes to the
        // remote while connected, so an online result implies the availability
        // stream said `true`. The fake decouples them, so state it explicitly.
        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();

        expect(cubit.state.isToneEnabled, isTrue);

        cubit.close();
      });
    });

    test('a subsequent offline fallback disables the tone selector again', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..engine = TranslationEngine.online;
        final cubit = _buildCubit(repo);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isTrue);

        repo.engine = TranslationEngine.offline;
        cubit.sourceTextChanged('bye');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();

        expect(cubit.state.isToneEnabled, isFalse);

        cubit.close();
      });
    });

    test('toneChanged retranslates with the new tone while enabled', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..engine = TranslationEngine.online;
        final cubit = _buildCubit(repo);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isTrue);
        final callsBeforeToneChange = repo.translateCallCount;

        cubit.toneChanged(TranslationTone.concise);
        async.flushMicrotasks();

        expect(cubit.state.tone, TranslationTone.concise);
        expect(repo.receivedTone, TranslationTone.concise);
        expect(repo.translateCallCount, callsBeforeToneChange + 1);

        cubit.close();
      });
    });

    test('does not emit after being closed mid-debounce', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);
        final emitted = <TranslateState>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit.sourceTextChanged('hi');
        cubit.close();

        async.elapse(
          TranslateCubit.debounceDuration + const Duration(seconds: 1),
        );
        async.flushMicrotasks();

        expect(repo.translateCallCount, 0);
        expect(_statuses(emitted).whereType<TranslationInProgress>(), isEmpty);

        sub.cancel();
      });
    });
  });

  group('TranslateCubit — speech', () {
    test('speakSource speaks the source text in the source language', () {
      fakeAsync((async) {
        final tts = _FakeTtsService();
        final cubit = _buildCubit(_FakeTranslationRepository(), tts: tts);

        cubit.sourceTextChanged('hi');
        cubit.speakSource();

        expect(tts.speakCalls, ['en:hi']);

        cubit.close();
      });
    });

    test('speakOutput speaks the translated text in the target language', () {
      fakeAsync((async) {
        final tts = _FakeTtsService();
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo, tts: tts);

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();
        cubit.speakOutput();

        expect(tts.speakCalls, ['ar:x:hi']);

        cubit.close();
      });
    });

    test('speakSource is a no-op while the source text is blank', () {
      final tts = _FakeTtsService();
      final cubit = _buildCubit(_FakeTranslationRepository(), tts: tts);
      addTearDown(cubit.close);

      cubit.speakSource();

      expect(tts.speakCalls, isEmpty);
    });

    test('close stops any speech in progress', () {
      final tts = _FakeTtsService();
      final cubit = _buildCubit(_FakeTranslationRepository(), tts: tts);

      cubit.close();

      expect(tts.stopCallCount, 1);
    });

    test('close cancels the online-availability subscription', () {
      final repo = _FakeTranslationRepository();
      final cubit = _buildCubit(repo);
      expect(repo.onlineAvailabilityHasListener, isTrue);

      cubit.close();

      expect(repo.onlineAvailabilityHasListener, isFalse);
    });
  });

  group('TranslateCubit — online availability', () {
    test('the tone selector enables as soon as the online signal fires — '
        'before any translation runs', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        expect(cubit.state.isToneEnabled, isFalse);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        expect(cubit.state.isToneEnabled, isTrue);
        expect(repo.translateCallCount, 0);
      });
    });

    test('the tone selector disables again when the online signal drops', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isTrue);

        repo.setOnlineAvailable(false);
        async.flushMicrotasks();

        expect(cubit.state.isToneEnabled, isFalse);
      });
    });

    test('an offline translation result disables the tone selector even while '
        'the online signal still says available', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..engine = TranslationEngine.offline;
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isTrue);

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();

        expect(cubit.state.isToneEnabled, isFalse);
      });
    });

    test('a transient offline fallback does not latch the tone off — coming '
        'back online re-enables it without another translation', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..engine = TranslationEngine.offline;
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        // A transient remote failure falls back to the offline engine while
        // connectivity itself never changed.
        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isFalse);

        // Connectivity flaps; the `true` edge must clear the stale latch.
        repo.setOnlineAvailable(false);
        async.flushMicrotasks();
        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        expect(
          cubit.state.isToneEnabled,
          isTrue,
          reason: 'availability returning must clear the offline latch',
        );
      });
    });

    test('an online result landing after the signal dropped does not re-enable '
        'the tone', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository()
          ..engine = TranslationEngine.online
          ..translateDelay = const Duration(seconds: 1);
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();

        cubit.sourceTextChanged('hi');
        async.elapse(TranslateCubit.debounceDuration);
        async.flushMicrotasks(); // translation now in flight

        // Connectivity drops while the request is still running.
        repo.setOnlineAvailable(false);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isFalse);

        // The in-flight online result lands afterwards. It must not resurrect
        // the tone selector — the device is offline now.
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(cubit.state.translatedText, 'x:hi');
        expect(
          cubit.state.isToneEnabled,
          isFalse,
          reason: 'a stale online result must not override live availability',
        );
      });
    });

    test('a stream error degrades to unavailable instead of escaping', () {
      fakeAsync((async) {
        final repo = _FakeTranslationRepository();
        final cubit = _buildCubit(repo);
        addTearDown(cubit.close);

        repo.setOnlineAvailable(true);
        async.flushMicrotasks();
        expect(cubit.state.isToneEnabled, isTrue);

        repo.failOnlineAvailability(Exception('platform channel blew up'));
        async.flushMicrotasks();

        expect(cubit.state.isOnlineAvailable, isFalse);
      });
    });
  });
}

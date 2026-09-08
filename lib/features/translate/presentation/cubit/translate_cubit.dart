import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_tone.dart';
import '../../domain/usecases/check_translation_models_usecase.dart';
import '../../domain/usecases/download_translation_models_usecase.dart';
import '../../domain/usecases/speak_text_usecase.dart';
import '../../domain/usecases/translate_text_usecase.dart';
import '../../domain/usecases/watch_online_availability_usecase.dart';
import 'translate_state.dart';

/// Orchestrates the translate screen: holds source text + language pair + tone,
/// debounces typing, ensures the on-device models exist, and runs the
/// translation. Depends only on use cases (CLAUDE.md §B-1).
class TranslateCubit extends Cubit<TranslateState> {
  TranslateCubit({
    required TranslateTextUseCase translateText,
    required CheckTranslationModelsUseCase checkModels,
    required DownloadTranslationModelsUseCase downloadModels,
    required SpeakTextUseCase speakText,
    required WatchOnlineAvailabilityUseCase watchOnlineAvailability,
  }) : _translateText = translateText,
       _checkModels = checkModels,
       _downloadModels = downloadModels,
       _speakText = speakText,
       super(TranslateState.initial()) {
    _onlineAvailabilitySubscription = watchOnlineAvailability().listen(
      (available) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isOnlineAvailable: available,
            // Coming back online clears a stale offline-fallback latch; without
            // this, one transient remote failure would keep the tone disabled
            // until another translation happened to succeed online.
            lastEngineWasOnline: available ? true : null,
          ),
        );
      },
      onError: (_) {
        // Defence in depth — the repository already contains connectivity
        // errors. Without this the subscription would rethrow into the zone.
        if (!isClosed) emit(state.copyWith(isOnlineAvailable: false));
      },
    );
  }

  final TranslateTextUseCase _translateText;
  final CheckTranslationModelsUseCase _checkModels;
  final DownloadTranslationModelsUseCase _downloadModels;
  final SpeakTextUseCase _speakText;

  late final StreamSubscription<bool> _onlineAvailabilitySubscription;

  /// Delay after the last keystroke before translating. Public so tests advance
  /// the clock against the same source of truth.
  static const Duration debounceDuration = Duration(milliseconds: 600);

  Timer? _debounce;

  /// Incremented on every translate attempt; a run only emits if it is still
  /// the latest, so a slow earlier translation can't overwrite a newer result.
  int _requestId = 0;

  /// Called on every keystroke. Empty input clears the output; otherwise the
  /// translation is (re)scheduled after [debounceDuration].
  void sourceTextChanged(String text) {
    _debounce?.cancel();
    // Any edit supersedes an in-flight run — without this, a slow translation
    // of the previous text could land as Done next to the newer source text.
    _requestId++;
    emit(state.copyWith(sourceText: text));

    if (text.trim().isEmpty) {
      emit(state.copyWith(translatedText: '', status: const TranslationIdle()));
      return;
    }

    _debounce = Timer(debounceDuration, _translate);
  }

  /// Explicit trigger (e.g. keyboard submit) — skips the debounce.
  void translateNow() {
    _debounce?.cancel();
    if (state.sourceText.trim().isEmpty) return;
    _translate();
  }

  /// Swaps the language pair. When a translation output exists it becomes the
  /// new source and is retranslated (classic swap UX). Without an output only
  /// the pair flips — the current source text belongs to the old source
  /// language, so retranslating it under the reversed pair would be garbage.
  void swapLanguages() {
    _debounce?.cancel();
    _requestId++; // supersede any in-flight run
    final hasOutput = state.translatedText.isNotEmpty;
    emit(
      state.copyWith(
        from: state.to,
        to: state.from,
        sourceText: hasOutput ? state.translatedText : state.sourceText,
        translatedText: '',
        status: const TranslationIdle(),
      ),
    );
    if (hasOutput) _translate();
  }

  /// Records the selected tone. Inert while the tone is disabled (offline).
  /// Retranslates so an existing output reflects the new tone.
  void toneChanged(TranslationTone tone) {
    if (!state.isToneEnabled) return;
    emit(state.copyWith(tone: tone));
    if (state.sourceText.trim().isNotEmpty) _translate();
  }

  /// Speaks the current source text. No-op while it is blank. Fire-and-forget:
  /// a speech failure is swallowed by the TTS service and must not block or
  /// surface in the UI.
  void speakSource() {
    if (state.sourceText.trim().isEmpty) return;
    unawaited(_speakText(text: state.sourceText, language: state.from));
  }

  /// Speaks the current translation output. No-op while it is blank. See
  /// [speakSource] for why the future is not awaited.
  void speakOutput() {
    if (state.translatedText.trim().isEmpty) return;
    unawaited(_speakText(text: state.translatedText, language: state.to));
  }

  Future<void> _translate() async {
    final id = ++_requestId;
    // One consistent snapshot — later awaits must not see newer field values.
    final text = state.sourceText;
    final from = state.from;
    final to = state.to;
    final tone = state.tone;

    // Ensure the on-device models exist, downloading on first use.
    final modelsResult = await _checkModels(from: from, to: to);
    if (_isStale(id)) return;

    final needsDownload = modelsResult.when(
      success: (downloaded) => !downloaded,
      failure: (_) =>
          false, // treat as ready; the translate call will surface it
    );

    if (needsDownload) {
      emit(state.copyWith(status: const TranslationDownloadingModel()));
      final downloadResult = await _downloadModels(from: from, to: to);
      if (_isStale(id)) return;
      final downloadFailure = downloadResult.when(
        success: (_) => null,
        failure: (f) => f,
      );
      if (downloadFailure != null) {
        emit(state.copyWith(status: TranslationError(downloadFailure)));
        return;
      }
    }

    emit(state.copyWith(status: const TranslationInProgress()));
    final result = await _translateText(
      text: text,
      from: from,
      to: to,
      tone: tone,
    );
    if (_isStale(id)) return;

    result.when(
      success: (translation) => emit(
        state.copyWith(
          translatedText: translation.translatedText,
          status: const TranslationDone(),
          lastEngineWasOnline: translation.engine == TranslationEngine.online,
        ),
      ),
      failure: (f) => emit(state.copyWith(status: TranslationError(f))),
    );
  }

  bool _isStale(int id) => isClosed || id != _requestId;

  @override
  Future<void> close() {
    _debounce?.cancel();
    unawaited(_onlineAvailabilitySubscription.cancel());
    unawaited(_speakText.stop());
    return super.close();
  }
}

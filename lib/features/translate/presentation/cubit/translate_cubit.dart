import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_tone.dart';
import '../../domain/usecases/check_translation_models_usecase.dart';
import '../../domain/usecases/download_translation_models_usecase.dart';
import '../../domain/usecases/speak_text_usecase.dart';
import '../../domain/usecases/translate_text_usecase.dart';
import '../../domain/usecases/watch_online_availability_usecase.dart';
import 'translate_state.dart';

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
            lastEngineWasOnline: available ? true : null,
          ),
        );
      },
      onError: (_) {
        if (!isClosed) emit(state.copyWith(isOnlineAvailable: false));
      },
    );
  }

  final TranslateTextUseCase _translateText;
  final CheckTranslationModelsUseCase _checkModels;
  final DownloadTranslationModelsUseCase _downloadModels;
  final SpeakTextUseCase _speakText;

  late final StreamSubscription<bool> _onlineAvailabilitySubscription;

  static const Duration debounceDuration = Duration(milliseconds: 600);

  Timer? _debounce;

  int _requestId = 0;

  void sourceTextChanged(String text) {
    _debounce?.cancel();
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

  /// Applies the language pair chosen in the shared language bar. An exact
  /// swap carries the current output over as the new source text.
  void languagesChanged({
    required LanguageEntity from,
    required LanguageEntity to,
  }) {
    if (from == state.from && to == state.to) return;
    _debounce?.cancel();
    _requestId++; // supersede any in-flight run
    final isSwap = from == state.to && to == state.from;
    final carryOutput = isSwap && state.translatedText.isNotEmpty;
    emit(
      state.copyWith(
        from: from,
        to: to,
        sourceText: carryOutput ? state.translatedText : state.sourceText,
        translatedText: '',
        status: const TranslationIdle(),
      ),
    );
    if (state.sourceText.trim().isNotEmpty) _translate();
  }

  void toneChanged(TranslationTone tone) {
    if (!state.isToneEnabled) return;
    emit(state.copyWith(tone: tone));
    if (state.sourceText.trim().isNotEmpty) _translate();
  }

  void speakSource() {
    if (state.sourceText.trim().isEmpty) return;
    unawaited(_speakText(text: state.sourceText, language: state.from));
  }

  void speakOutput() {
    if (state.translatedText.trim().isEmpty) return;
    unawaited(_speakText(text: state.translatedText, language: state.to));
  }

  Future<void> _translate() async {
    final id = ++_requestId;
    final text = state.sourceText;
    final from = state.from;
    final to = state.to;
    final tone = state.tone;

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
      tone: tone.name,
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

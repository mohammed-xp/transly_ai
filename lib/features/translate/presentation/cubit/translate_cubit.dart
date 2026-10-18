import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/tone_catalog.dart';
import '../../domain/entities/translation_engine.dart';
import '../../domain/entities/translation_tone.dart';
import '../../domain/usecases/get_cached_tones_usecase.dart';
import '../../domain/usecases/get_saved_tone_usecase.dart';
import '../../domain/usecases/save_tone_usecase.dart';
import '../../domain/usecases/speak_text_usecase.dart';
import '../../domain/usecases/sync_tones_usecase.dart';
import '../../domain/usecases/translate_text_usecase.dart';
import '../../domain/usecases/watch_online_availability_usecase.dart';
import 'translate_state.dart';

class TranslateCubit extends Cubit<TranslateState> {
  TranslateCubit({
    required TranslateTextUseCase translateText,
    required SpeakTextUseCase speakText,
    required WatchOnlineAvailabilityUseCase watchOnlineAvailability,
    required GetCachedTonesUseCase getCachedTones,
    required SyncTonesUseCase syncTones,
    required GetSavedToneUseCase getSavedTone,
    required SaveToneUseCase saveTone,
  }) : _translateText = translateText,
       _speakText = speakText,
       _syncTones = syncTones,
       _getSavedTone = getSavedTone,
       _saveTone = saveTone,
       super(_initialState(getCachedTones(), getSavedTone())) {
    unawaited(_loadTones());
    _onlineAvailabilitySubscription = watchOnlineAvailability().listen(
      (available) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isOnlineAvailable: available,
            lastEngineWasOnline: available ? true : null,
          ),
        );
        if (available && _tonesStale) unawaited(_loadTones());
      },
      onError: (_) {
        if (!isClosed) emit(state.copyWith(isOnlineAvailable: false));
      },
    );
  }

  final TranslateTextUseCase _translateText;
  final SpeakTextUseCase _speakText;
  final SyncTonesUseCase _syncTones;
  final GetSavedToneUseCase _getSavedTone;
  final SaveToneUseCase _saveTone;

  late final StreamSubscription<bool> _onlineAvailabilitySubscription;

  static const Duration debounceDuration = Duration(milliseconds: 600);

  Timer? _debounce;

  int _requestId = 0;

  int _tonesRequestId = 0;

  /// The last tones sync failed, so the shown tones may be missing or in an
  /// older UI language. Retried once the device is back online.
  bool _tonesStale = false;

  static TranslateState _initialState(ToneCatalog? cached, String? savedCode) =>
      TranslateState.initial(
        tones: cached?.tones ?? const [],
        tone: cached?.resolve(savedCode),
      );

  /// The server names tones in the UI language, so a language change needs a
  /// fresh list. The current one stays shown until it arrives.
  void uiLanguageChanged() => unawaited(_loadTones());

  /// Refreshes the tones from the server, keeping the current pick when it is
  /// still offered. A failure keeps whatever is already shown. Only the latest
  /// call applies, so a list fetched in the previous language can't land last.
  Future<void> _loadTones() async {
    final id = ++_tonesRequestId;
    final result = await _syncTones();
    if (isClosed || id != _tonesRequestId) return;
    switch (result) {
      case ApiSuccess(:final data):
        _tonesStale = false;
        final tone = data.resolve(state.tone?.code ?? _getSavedTone());
        emit(state.copyWith(tones: data.tones, tone: tone));
      case ApiFailure():
        _tonesStale = true;
    }
  }

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
    if (!state.isToneEnabled || tone == state.tone) return;
    emit(state.copyWith(tone: tone));
    unawaited(_saveTone(tone.code));
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

    emit(state.copyWith(status: const TranslationInProgress()));
    final result = await _translateText(
      text: text,
      from: from,
      to: to,
      tone: tone?.code,
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

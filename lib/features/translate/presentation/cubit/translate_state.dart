import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/translation_tone.dart';

sealed class TranslationStatus {
  const TranslationStatus();
}

class TranslationIdle extends TranslationStatus {
  const TranslationIdle();
}

class TranslationDownloadingModel extends TranslationStatus {
  const TranslationDownloadingModel();
}

class TranslationInProgress extends TranslationStatus {
  const TranslationInProgress();
}

class TranslationDone extends TranslationStatus {
  const TranslationDone();
}

class TranslationError extends TranslationStatus {
  const TranslationError(this.failure);

  final Failure failure;
}

/// Single immutable screen state. Persistent fields (source text, languages,
/// tone, last result) survive across [status] transitions so the output card
/// never flashes empty mid-translate — the varying async phase lives in the
/// sealed [status] instead of in separate top-level states.
class TranslateState {
  const TranslateState({
    required this.sourceText,
    required this.from,
    required this.to,
    required this.tone,
    required this.translatedText,
    required this.status,
    required this.isOnlineAvailable,
    required this.lastEngineWasOnline,
  });

  /// Default language pair (same as `HomeState.initial`), formal tone.
  /// [isOnlineAvailable] starts `false` only because it is the
  /// pre-first-emission value of the availability stream, which reports the
  /// real answer immediately.
  factory TranslateState.initial() => const TranslateState(
    sourceText: '',
    from: LanguageEntity.defaultSource,
    to: LanguageEntity.defaultTarget,
    tone: TranslationTone.formal,
    translatedText: '',
    status: TranslationIdle(),
    isOnlineAvailable: false,
    lastEngineWasOnline: true,
  );

  final String sourceText;
  final LanguageEntity from;
  final LanguageEntity to;
  final TranslationTone tone;
  final String translatedText;
  final TranslationStatus status;

  /// A tone-aware (online) source is configured and the device is connected.
  /// Driven by the availability stream.
  final bool isOnlineAvailable;

  /// Whether the most recent successful translation actually came from the
  /// online engine. A remote call can fail and fall back to the offline engine
  /// while connectivity still looks fine, so this is tracked separately from
  /// [isOnlineAvailable] rather than overwriting it.
  final bool lastEngineWasOnline;

  /// Tone is offered only when online translation is available *and* the last
  /// result actually honoured it. Derived rather than stored so the two
  /// independent signals can arrive in any order without one clobbering the
  /// other.
  bool get isToneEnabled => isOnlineAvailable && lastEngineWasOnline;

  /// A model download or a translation is in flight — drives the loading UI
  /// (design `02b · Translating`).
  bool get isBusy =>
      status is TranslationDownloadingModel || status is TranslationInProgress;

  TranslateState copyWith({
    String? sourceText,
    LanguageEntity? from,
    LanguageEntity? to,
    TranslationTone? tone,
    String? translatedText,
    TranslationStatus? status,
    bool? isOnlineAvailable,
    bool? lastEngineWasOnline,
  }) {
    return TranslateState(
      sourceText: sourceText ?? this.sourceText,
      from: from ?? this.from,
      to: to ?? this.to,
      tone: tone ?? this.tone,
      translatedText: translatedText ?? this.translatedText,
      status: status ?? this.status,
      isOnlineAvailable: isOnlineAvailable ?? this.isOnlineAvailable,
      lastEngineWasOnline: lastEngineWasOnline ?? this.lastEngineWasOnline,
    );
  }
}

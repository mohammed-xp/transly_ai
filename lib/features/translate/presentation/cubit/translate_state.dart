import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/translation_tone.dart';

sealed class TranslationStatus {
  const TranslationStatus();
}

class TranslationIdle extends TranslationStatus {
  const TranslationIdle();
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

/// Speech couldn't start. Deliberately not `const`: each notice is a new
/// object, so the same failure twice in a row is still told twice.
class SpeakFailedNotice {
  SpeakFailedNotice(this.failure);

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
    required this.tones,
    required this.tone,
    required this.translatedText,
    required this.status,
    required this.isOnlineAvailable,
    required this.lastEngineWasOnline,
    this.speakNotice,
  });

  /// Default language pair (same as `HomeState.initial`), with whatever tones
  /// are already cached.
  /// [isOnlineAvailable] starts `false` only because it is the
  /// pre-first-emission value of the availability stream, which reports the
  /// real answer immediately.
  factory TranslateState.initial({
    List<TranslationTone> tones = const [],
    TranslationTone? tone,
  }) => TranslateState(
    sourceText: '',
    from: LanguageEntity.defaultSource,
    to: LanguageEntity.defaultTarget,
    tones: tones,
    tone: tone,
    translatedText: '',
    status: const TranslationIdle(),
    isOnlineAvailable: false,
    lastEngineWasOnline: true,
  );

  final String sourceText;
  final LanguageEntity from;
  final LanguageEntity to;

  /// Empty until the tones have been loaded once, which hides the selector.
  final List<TranslationTone> tones;

  /// Null only while [tones] is empty; the server then applies its default.
  final TranslationTone? tone;
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

  /// The latest speech failure to tell the user about.
  final SpeakFailedNotice? speakNotice;

  /// Tone is offered only when online translation is available *and* the last
  /// result actually honoured it. Derived rather than stored so the two
  /// independent signals can arrive in any order without one clobbering the
  /// other.
  bool get isToneEnabled => isOnlineAvailable && lastEngineWasOnline;

  /// A translation is in flight — drives the loading UI
  /// (design `02b · Translating`).
  bool get isBusy => status is TranslationInProgress;

  TranslateState copyWith({
    String? sourceText,
    LanguageEntity? from,
    LanguageEntity? to,
    List<TranslationTone>? tones,
    TranslationTone? tone,
    String? translatedText,
    TranslationStatus? status,
    bool? isOnlineAvailable,
    bool? lastEngineWasOnline,
    SpeakFailedNotice? speakNotice,
  }) {
    return TranslateState(
      sourceText: sourceText ?? this.sourceText,
      from: from ?? this.from,
      to: to ?? this.to,
      tones: tones ?? this.tones,
      tone: tone ?? this.tone,
      translatedText: translatedText ?? this.translatedText,
      status: status ?? this.status,
      isOnlineAvailable: isOnlineAvailable ?? this.isOnlineAvailable,
      lastEngineWasOnline: lastEngineWasOnline ?? this.lastEngineWasOnline,
      speakNotice: speakNotice ?? this.speakNotice,
    );
  }
}

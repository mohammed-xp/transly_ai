import '../../../../core/errors/failure.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation_tone.dart';

/// The async phase of translation. Sealed so the UI matches exhaustively. Pure
/// Dart — no Flutter imports (CLAUDE.md §B-3). [TranslationError] carries the
/// typed [Failure]; the presentation layer maps it to a localized message.
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

  /// Offline default: English → Arabic, formal tone. [isOnlineAvailable] starts
  /// `false` only because it is the pre-first-emission value of the
  /// availability stream, which reports the real answer immediately.
  factory TranslateState.initial() => const TranslateState(
        sourceText: '',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
        translatedText: '',
        status: TranslationIdle(),
        isOnlineAvailable: false,
        lastEngineWasOnline: true,
      );

  final String sourceText;
  final Language from;
  final Language to;
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

  TranslateState copyWith({
    String? sourceText,
    Language? from,
    Language? to,
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

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
    required this.isToneEnabled,
  });

  /// Offline default: English → Arabic, formal tone, tone disabled until the
  /// first online (Gemini) translation completes.
  factory TranslateState.initial() => const TranslateState(
        sourceText: '',
        from: Language.english,
        to: Language.arabic,
        tone: TranslationTone.formal,
        translatedText: '',
        status: TranslationIdle(),
        isToneEnabled: false,
      );

  final String sourceText;
  final Language from;
  final Language to;
  final TranslationTone tone;
  final String translatedText;
  final TranslationStatus status;
  final bool isToneEnabled;

  TranslateState copyWith({
    String? sourceText,
    Language? from,
    Language? to,
    TranslationTone? tone,
    String? translatedText,
    TranslationStatus? status,
    bool? isToneEnabled,
  }) {
    return TranslateState(
      sourceText: sourceText ?? this.sourceText,
      from: from ?? this.from,
      to: to ?? this.to,
      tone: tone ?? this.tone,
      translatedText: translatedText ?? this.translatedText,
      status: status ?? this.status,
      isToneEnabled: isToneEnabled ?? this.isToneEnabled,
    );
  }
}

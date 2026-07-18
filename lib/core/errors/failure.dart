/// Typed failures that flow up from the data layer to presentation. Pure Dart —
/// no Flutter imports (CLAUDE.md §B-3). Carries an optional [debugMessage] for
/// logging only; user-facing text is mapped in the presentation layer.
sealed class Failure {
  const Failure([this.debugMessage]);

  /// Developer-facing detail (exception text). Never shown to users directly.
  final String? debugMessage;
}

/// The translation call itself failed (engine/platform error, unsupported pair).
class TranslationFailure extends Failure {
  const TranslationFailure([super.debugMessage]);
}

/// Downloading an on-device translation model failed.
class ModelDownloadFailure extends Failure {
  const ModelDownloadFailure([super.debugMessage]);
}

/// No network connection while an online-only source was required. Unused by
/// the offline path; the repository's remote (Gemini) branch must map its
/// connectivity errors here so `translateErrorNoConnection` becomes reachable.
class NoConnectionFailure extends Failure {
  const NoConnectionFailure([super.debugMessage]);
}

/// Anything the data layer could not classify.
class UnknownFailure extends Failure {
  const UnknownFailure([super.debugMessage]);
}

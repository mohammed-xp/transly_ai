/// Thin abstraction over a text-to-speech engine so callers can be
/// unit-tested without hitting platform channels. Lives in `core/services/`
/// alongside other device-capability wrappers; the conversation feature
/// (voice mode) will reuse it. Pure Dart — no Flutter imports (CLAUDE.md
/// §B-3) so the domain layer can depend on it.
abstract class TtsService {
  /// Speaks [text] in [languageCode] ('en'/'ar'). No-op on blank text or when
  /// no matching voice is available on the device.
  Future<void> speak({required String text, required String languageCode});

  /// Stops any speech in progress.
  Future<void> stop();
}

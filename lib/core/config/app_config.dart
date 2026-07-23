/// Compile-time configuration, supplied via `--dart-define`. Never hardcode
/// secrets in source (CLAUDE.md §A-6).
abstract final class AppConfig {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  static bool get isGeminiConfigured => geminiApiKey.isNotEmpty;
}

abstract final class ApiEndpoints {
  static const String baseUrl = 'https://api.transly.ai/v1';

  // Translation proxy (future Claude API proxy)
  static const String translate = '/translate';
  static const String supportedLanguages = '/languages';
}

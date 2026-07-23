import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/network/rest_client.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation_tone.dart';
import 'translation_remote_data_source.dart';

/// Online, tone-aware translation source backed by the Gemini REST API.
/// Depends on [RestClient] rather than any specific HTTP package — network
/// transport errors are already mapped to [RemoteConnectionException] /
/// [RemoteApiException] there (CLAUDE.md §B-5). Never logs or includes
/// [_apiKey] in an exception message (CLAUDE.md §A-6).
class GeminiTranslationRemoteDataSource implements TranslationRemoteDataSource {
  GeminiTranslationRemoteDataSource({
    required RestClient restClient,
    required String apiKey,
  })  : _restClient = restClient,
        _apiKey = apiKey;

  static const String _model = 'gemini-3.5-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  final RestClient _restClient;
  final String _apiKey;

  @override
  Future<String> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async {
    final data = await _restClient.postJson(
      _endpoint,
      headers: {'x-goog-api-key': _apiKey},
      body: {
        'contents': [
          {
            'parts': [
              {'text': _buildPrompt(text: text, from: from, to: to, tone: tone)},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'thinkingConfig': {'thinkingBudget': 0},
        },
      },
    );

    return _parseResponse(data);
  }

  String _buildPrompt({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) {
    final toneInstruction = switch (tone) {
      TranslationTone.formal => 'Use a formal, professional register.',
      TranslationTone.casual => 'Use a relaxed, conversational register.',
      TranslationTone.concise =>
        'Translate as briefly as possible while preserving meaning.',
    };
    return '''
You are a translation engine. Translate the following text from ${_languageName(from)} to ${_languageName(to)}. $toneInstruction
Respond with ONLY the translated text — no preamble, no explanations, no quotation marks, no markdown.

Text: $text
''';
  }

  String _languageName(Language language) => switch (language) {
        Language.english => 'English',
        Language.arabic => 'Arabic',
      };

  String _parseResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const RemoteApiException('Unexpected response shape');
    }

    final promptFeedback = data['promptFeedback'];
    if (promptFeedback is Map && promptFeedback['blockReason'] != null) {
      throw RemoteApiException('Blocked: ${promptFeedback['blockReason']}');
    }

    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const RemoteApiException('No candidates in response');
    }

    final candidate = candidates.first;
    if (candidate is! Map) {
      throw const RemoteApiException('Malformed candidate');
    }

    final finishReason = candidate['finishReason'];
    final content = candidate['content'];
    final parts = content is Map ? content['parts'] : null;

    final text = (parts is List ? parts : const [])
        .whereType<Map>()
        .map((part) => part['text'])
        .whereType<String>()
        .join()
        .trim();

    if (text.isEmpty) {
      throw RemoteApiException('Empty translation (finishReason: $finishReason)');
    }

    return text;
  }
}

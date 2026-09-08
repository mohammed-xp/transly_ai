import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/rest_client.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/translation_tone.dart';
import '../models/translation_response_model.dart';
import 'translation_remote_data_source.dart';

/// Online, tone-aware translation source backed by the backend's
/// `POST /v1/translations` endpoint. Depends on [RestClient] rather than any
/// specific HTTP package (CLAUDE.md §A-1, §A-2). The session token is
/// attached by the shared `AuthInterceptor`, not here.
class ApiTranslationRemoteDataSource implements TranslationRemoteDataSource {
  ApiTranslationRemoteDataSource(this._restClient);

  final RestClient _restClient;

  @override
  Future<TranslationResponseModel> translate({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) async {
    final data = await _restClient.postJson(
      ApiEndpoints.translations,
      body: {
        'text': text,
        'sourceLanguage': from.code,
        'targetLanguage': to.code,
        'tone': tone.name,
      },
    );

    return TranslationResponseModel.fromJson(data);
  }
}

import '../../../../core/network/endpoints.dart';
import '../../../../core/network/api_consumer.dart';
import '../models/translation_response_model.dart';
import 'translation_remote_data_source.dart';

class ApiTranslationRemoteDataSource implements TranslationRemoteDataSource {
  ApiTranslationRemoteDataSource(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<TranslationResponseModel> translate({
    required String text,
    required String from,
    required String to,
    required String tone,
  }) async {
    final data = await _apiConsumer.post(
      Endpoints.translations,
      data: {
        'text': text,
        'sourceLanguage': from,
        'targetLanguage': to,
        'tone': tone,
      },
    );

    return TranslationResponseModel.fromJson(data["data"]);
  }
}

import '../../../../core/data/models/language_model.dart';
import '../../../../core/network/api_consumer.dart';
import '../../../../core/network/endpoints.dart';
import 'languages_remote_data_source.dart';

class LanguagesRemoteDataSourceImpl implements LanguagesRemoteDataSource {
  LanguagesRemoteDataSourceImpl(this._apiConsumer);

  final ApiConsumer _apiConsumer;

  @override
  Future<List<LanguageModel>> getLanguages() async {
    final data = await _apiConsumer.get(Endpoints.languages);
    final body = data['data'] as Map<String, dynamic>;
    return [
      for (final language in body['languages'] as List<dynamic>)
        LanguageModel.fromJson(language as Map<String, dynamic>),
    ];
  }
}

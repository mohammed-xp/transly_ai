import '../models/translation_response_model.dart';

abstract class TranslationRemoteDataSource {
  Future<TranslationResponseModel> translate({
    required String text,
    required String from,
    required String to,
    required String tone,
  });
}

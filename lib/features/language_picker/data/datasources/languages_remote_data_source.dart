import '../../../../core/data/models/language_model.dart';

abstract class LanguagesRemoteDataSource {
  Future<List<LanguageModel>> getLanguages();
}

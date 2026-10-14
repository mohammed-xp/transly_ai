import '../../../../core/data/models/language_model.dart';

abstract class LanguagesLocalDataSource {
  /// Null when no list has been cached yet.
  List<LanguageModel>? getCachedLanguages();

  Future<void> cacheLanguages(List<LanguageModel> languages);

  /// Null when no pair has been saved yet.
  ({LanguageModel from, LanguageModel to})? getSavedPair();

  Future<void> savePair(LanguageModel from, LanguageModel to);

  List<LanguageModel> getRecentLanguages();

  Future<void> saveRecentLanguages(List<LanguageModel> languages);
}

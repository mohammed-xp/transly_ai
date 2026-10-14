import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/language_pair.dart';

abstract class LanguagesRepo {
  /// The last list fetched from the server; empty when there is none yet.
  List<LanguageEntity> getCachedLanguages();

  /// Fetches the list from the server and stores it when it differs from the
  /// cached one. A failed fetch leaves the cache as it was.
  Future<ApiResult<List<LanguageEntity>>> syncLanguages();

  /// The pair last translated between, or the default pair when none is
  /// saved.
  LanguagePair getSavedPair();

  Future<ApiResult<void>> savePair(LanguagePair pair);

  /// Most recently picked first.
  List<LanguageEntity> getRecentLanguages();

  Future<ApiResult<void>> saveRecentLanguages(List<LanguageEntity> languages);
}

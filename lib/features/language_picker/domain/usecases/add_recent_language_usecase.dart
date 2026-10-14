import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../repos/languages_repo.dart';

class AddRecentLanguageUseCase {
  const AddRecentLanguageUseCase(this._repo);

  static const int maxRecents = 6;

  final LanguagesRepo _repo;

  /// Moves [language] to the front of the recent list and returns the new
  /// list, which holds at most [maxRecents] languages.
  Future<ApiResult<List<LanguageEntity>>> call(LanguageEntity language) async {
    final recents = [
      language,
      for (final recent in _repo.getRecentLanguages())
        if (recent != language) recent,
    ].take(maxRecents).toList();

    final result = await _repo.saveRecentLanguages(recents);
    return result.when(
      success: (_) => ApiResult.success(recents),
      failure: ApiResult.failure,
    );
  }
}

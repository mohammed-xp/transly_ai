import '../../../../core/result/api_result.dart';
import '../entities/language_pair.dart';
import '../repos/languages_repo.dart';

class SaveLanguagePairUseCase {
  const SaveLanguagePairUseCase(this._repo);

  final LanguagesRepo _repo;

  Future<ApiResult<void>> call(LanguagePair pair) => _repo.savePair(pair);
}

import '../../../../core/result/api_result.dart';
import '../repos/translation_repo.dart';

class SaveToneUseCase {
  const SaveToneUseCase(this._repository);

  final TranslationRepo _repository;

  Future<ApiResult<void>> call(String code) => _repository.saveToneCode(code);
}

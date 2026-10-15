import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../repos/offline_models_repo.dart';

class DeleteOfflineModelUseCase {
  const DeleteOfflineModelUseCase(this._repo);

  final OfflineModelsRepo _repo;

  Future<ApiResult<void>> call(LanguageEntity language) =>
      _repo.delete(language.code);
}

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/offline_model_status.dart';
import '../repos/offline_models_repo.dart';

class GetOfflineModelStatusesUseCase {
  const GetOfflineModelStatusesUseCase(this._repo);

  final OfflineModelsRepo _repo;

  Future<ApiResult<Map<String, OfflineModelStatus>>> call(
    List<LanguageEntity> languages,
  ) => _repo.getStatuses([for (final language in languages) language.code]);
}

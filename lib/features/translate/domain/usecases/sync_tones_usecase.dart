import '../../../../core/result/api_result.dart';
import '../entities/tone_catalog.dart';
import '../repos/translation_repo.dart';

class SyncTonesUseCase {
  const SyncTonesUseCase(this._repository);

  final TranslationRepo _repository;

  Future<ApiResult<ToneCatalog>> call() => _repository.syncTones();
}

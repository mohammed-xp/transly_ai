import '../entities/tone_catalog.dart';
import '../repos/translation_repo.dart';

class GetCachedTonesUseCase {
  const GetCachedTonesUseCase(this._repository);

  final TranslationRepo _repository;

  ToneCatalog? call() => _repository.getCachedTones();
}

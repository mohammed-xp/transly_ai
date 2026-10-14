import '../../../../core/domain/entities/language_entity.dart';
import '../repos/languages_repo.dart';

class GetCachedLanguagesUseCase {
  const GetCachedLanguagesUseCase(this._repo);

  final LanguagesRepo _repo;

  List<LanguageEntity> call() => _repo.getCachedLanguages();
}

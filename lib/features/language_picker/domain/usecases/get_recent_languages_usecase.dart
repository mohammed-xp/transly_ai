import '../../../../core/domain/entities/language_entity.dart';
import '../repos/languages_repo.dart';

class GetRecentLanguagesUseCase {
  const GetRecentLanguagesUseCase(this._repo);

  final LanguagesRepo _repo;

  List<LanguageEntity> call() => _repo.getRecentLanguages();
}

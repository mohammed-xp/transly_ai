import '../entities/language_pair.dart';
import '../repos/languages_repo.dart';

class GetSavedLanguagePairUseCase {
  const GetSavedLanguagePairUseCase(this._repo);

  final LanguagesRepo _repo;

  LanguagePair call() => _repo.getSavedPair();
}

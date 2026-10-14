import '../entities/translation_tone.dart';
import '../repos/translation_repo.dart';

class GetSavedToneUseCase {
  const GetSavedToneUseCase(this._repository);

  final TranslationRepo _repository;

  TranslationTone call() => _repository.getSavedTone();
}

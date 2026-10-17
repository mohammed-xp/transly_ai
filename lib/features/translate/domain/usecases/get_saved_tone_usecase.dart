import '../repos/translation_repo.dart';

class GetSavedToneUseCase {
  const GetSavedToneUseCase(this._repository);

  final TranslationRepo _repository;

  String? call() => _repository.getSavedToneCode();
}

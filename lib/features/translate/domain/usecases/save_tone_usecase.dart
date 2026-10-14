import '../../../../core/result/api_result.dart';
import '../entities/translation_tone.dart';
import '../repos/translation_repo.dart';

class SaveToneUseCase {
  const SaveToneUseCase(this._repository);

  final TranslationRepo _repository;

  Future<ApiResult<void>> call(TranslationTone tone) =>
      _repository.saveTone(tone);
}

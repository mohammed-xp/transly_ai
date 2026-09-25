import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../entities/translation_entity.dart';
import '../repos/translation_repo.dart';

class TranslateTextUseCase {
  const TranslateTextUseCase(this._repository);

  final TranslationRepo _repository;

  Future<ApiResult<TranslationEntity>> call({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String tone,
  }) {
    return _repository.translate(text: text, from: from, to: to, tone: tone);
  }
}

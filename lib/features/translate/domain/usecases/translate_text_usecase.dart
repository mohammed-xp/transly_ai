import '../../../../core/result/api_result.dart';
import '../entities/language.dart';
import '../entities/translation_entity.dart';
import '../entities/translation_tone.dart';
import '../repos/translation_repository.dart';

/// Translates [text] from [from] to [to] with the requested [tone].
class TranslateTextUseCase {
  const TranslateTextUseCase(this._repository);

  final TranslationRepository _repository;

  Future<ApiResult<TranslationEntity>> call({
    required String text,
    required Language from,
    required Language to,
    required TranslationTone tone,
  }) {
    return _repository.translate(text: text, from: from, to: to, tone: tone);
  }
}

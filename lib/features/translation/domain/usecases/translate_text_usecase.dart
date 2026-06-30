import '../../../../core/result/api_result.dart';
import '../entities/translation.dart';
import '../repositories/translation_repository.dart';

final class TranslateTextUseCase {
  const TranslateTextUseCase(this._repository);

  final TranslationRepository _repository;

  Future<ApiResult<Translation>> call(TranslationRequest request) =>
      _repository.translate(request);
}

import '../../../../core/domain/entities/language.dart';
import '../../../../core/result/api_result.dart';
import '../repositories/translation_repository.dart';

final class GetSupportedLanguagesUseCase {
  const GetSupportedLanguagesUseCase(this._repository);

  final TranslationRepository _repository;

  Future<ApiResult<List<Language>>> call() => _repository.supportedLanguages();
}

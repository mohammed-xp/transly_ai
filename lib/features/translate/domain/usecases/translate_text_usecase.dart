import 'dart:async';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/analytics_event.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../language_picker/domain/usecases/auto_download_offline_models_usecase.dart';
import '../entities/translation_engine.dart';
import '../entities/translation_entity.dart';
import '../repos/translation_repo.dart';

class TranslateTextUseCase {
  const TranslateTextUseCase(
    this._repository,
    this._autoDownloadModels,
    this._analytics,
  );

  final TranslationRepo _repository;
  final AutoDownloadOfflineModelsUseCase _autoDownloadModels;
  final AnalyticsService _analytics;

  /// An online result also starts downloading the pair for offline use; the
  /// translation is returned without waiting for it.
  Future<ApiResult<TranslationEntity>> call({
    required String text,
    required LanguageEntity from,
    required LanguageEntity to,
    required String? tone,
  }) async {
    final result = await _repository.translate(
      text: text,
      from: from,
      to: to,
      tone: tone,
    );
    switch (result) {
      case ApiSuccess(:final data):
        if (data.engine == TranslationEngine.online) {
          unawaited(_autoDownloadModels([from, to]));
        }
        unawaited(
          _analytics.logEvent(
            TranslateEvent(
              sourceLanguage: from.code,
              targetLanguage: to.code,
              engine: data.engine.name,
            ),
          ),
        );
      case ApiFailure(:final failure) when failure.isQuotaExceeded:
        unawaited(
          _analytics.logEvent(const QuotaReachedEvent(QuotaFeature.translate)),
        );
      case ApiFailure():
        break;
    }
    return result;
  }
}

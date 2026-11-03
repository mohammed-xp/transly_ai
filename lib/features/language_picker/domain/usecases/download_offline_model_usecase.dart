import 'dart:async';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../../../core/services/analytics_event.dart';
import '../../../../core/services/analytics_service.dart';
import '../repos/offline_models_repo.dart';

class DownloadOfflineModelUseCase {
  const DownloadOfflineModelUseCase(this._repo, this._analytics);

  final OfflineModelsRepo _repo;
  final AnalyticsService _analytics;

  Future<ApiResult<void>> call(LanguageEntity language) async {
    final result = await _repo.download(language.code);
    if (result is ApiSuccess) {
      unawaited(_analytics.logEvent(OfflinePackDownloadEvent(language.code)));
    }
    return result;
  }
}

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/usecases/delete_offline_model_usecase.dart';
import '../../domain/usecases/download_offline_model_usecase.dart';
import '../../domain/usecases/watch_offline_model_updates_usecase.dart';
import 'offline_model_error.dart';

/// Downloads and removals of offline models for the cubits that list
/// languages with their offline status. Call [initModelActions] from the
/// constructor.
mixin OfflineModelActions<S> on Cubit<S> {
  late final DownloadOfflineModelUseCase _downloadOfflineModel;
  late final DeleteOfflineModelUseCase _deleteOfflineModel;
  late final StreamSubscription<OfflineModelUpdate> _modelUpdatesSubscription;

  /// Codes with a download or removal asked for and not yet answered, so a
  /// quick second tap neither repeats it nor reports its failure twice.
  final Set<String> _pendingModelActions = {};

  Map<String, OfflineModelStatus> get modelStatuses;

  S copyWithModelStatuses(Map<String, OfflineModelStatus> statuses);

  S copyWithModelError(OfflineModelError error);

  void initModelActions({
    required WatchOfflineModelUpdatesUseCase watchOfflineModelUpdates,
    required DownloadOfflineModelUseCase downloadOfflineModel,
    required DeleteOfflineModelUseCase deleteOfflineModel,
  }) {
    _downloadOfflineModel = downloadOfflineModel;
    _deleteOfflineModel = deleteOfflineModel;
    _modelUpdatesSubscription = watchOfflineModelUpdates().listen(
      _applyModelUpdate,
    );
  }

  /// The statuses themselves arrive through the updates stream.
  Future<void> downloadModel(LanguageEntity language) async {
    if (isClosed ||
        modelStatuses[language.code] is! OfflineModelNotDownloaded) {
      return;
    }
    await _runModelAction(language, _downloadOfflineModel.call);
  }

  Future<void> deleteModel(LanguageEntity language) async {
    if (isClosed || modelStatuses[language.code] is! OfflineModelDownloaded) {
      return;
    }
    await _runModelAction(language, _deleteOfflineModel.call);
  }

  /// Statuses already set by an update that arrived meanwhile win.
  void mergeModelStatuses(Map<String, OfflineModelStatus> statuses) {
    if (isClosed) return;
    emit(copyWithModelStatuses({...statuses, ...modelStatuses}));
  }

  Future<void> _runModelAction(
    LanguageEntity language,
    Future<ApiResult<void>> Function(LanguageEntity) action,
  ) async {
    if (!_pendingModelActions.add(language.code)) return;
    try {
      _reportModelFailure(language, await action(language));
    } finally {
      _pendingModelActions.remove(language.code);
    }
  }

  void _applyModelUpdate(OfflineModelUpdate update) {
    if (isClosed) return;
    emit(copyWithModelStatuses({...modelStatuses, update.code: update.status}));
  }

  void _reportModelFailure(LanguageEntity language, ApiResult<void> result) {
    if (isClosed) return;
    if (result case ApiFailure(:final failure)) {
      emit(copyWithModelError(OfflineModelError(language, failure)));
    }
  }

  @override
  Future<void> close() {
    unawaited(_modelUpdatesSubscription.cancel());
    return super.close();
  }
}

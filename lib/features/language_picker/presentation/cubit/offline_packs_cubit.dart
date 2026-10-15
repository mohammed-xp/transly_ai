import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/entities/offline_packs_settings.dart';
import '../../domain/usecases/delete_offline_model_usecase.dart';
import '../../domain/usecases/download_offline_model_usecase.dart';
import '../../domain/usecases/get_cached_languages_usecase.dart';
import '../../domain/usecases/get_offline_model_statuses_usecase.dart';
import '../../domain/usecases/get_offline_packs_settings_usecase.dart';
import '../../domain/usecases/save_offline_packs_settings_usecase.dart';
import '../../domain/usecases/sync_languages_usecase.dart';
import '../../domain/usecases/watch_offline_model_updates_usecase.dart';
import 'offline_model_actions.dart';
import 'offline_model_error.dart';
import 'offline_packs_state.dart';

class OfflinePacksCubit extends Cubit<OfflinePacksState>
    with OfflineModelActions<OfflinePacksState> {
  OfflinePacksCubit({
    required GetCachedLanguagesUseCase getCachedLanguages,
    required SyncLanguagesUseCase syncLanguages,
    required GetOfflineModelStatusesUseCase getOfflineModelStatuses,
    required WatchOfflineModelUpdatesUseCase watchOfflineModelUpdates,
    required DownloadOfflineModelUseCase downloadOfflineModel,
    required DeleteOfflineModelUseCase deleteOfflineModel,
    required GetOfflinePacksSettingsUseCase getSettings,
    required SaveOfflinePacksSettingsUseCase saveSettings,
  }) : _getCachedLanguages = getCachedLanguages,
       _syncLanguages = syncLanguages,
       _getOfflineModelStatuses = getOfflineModelStatuses,
       _saveSettings = saveSettings,
       super(OfflinePacksState(settings: getSettings())) {
    initModelActions(
      watchOfflineModelUpdates: watchOfflineModelUpdates,
      downloadOfflineModel: downloadOfflineModel,
      deleteOfflineModel: deleteOfflineModel,
    );
  }

  final GetCachedLanguagesUseCase _getCachedLanguages;
  final SyncLanguagesUseCase _syncLanguages;
  final GetOfflineModelStatusesUseCase _getOfflineModelStatuses;
  final SaveOfflinePacksSettingsUseCase _saveSettings;

  @override
  Map<String, OfflineModelStatus> get modelStatuses => state.modelStatuses;

  @override
  OfflinePacksState copyWithModelStatuses(
    Map<String, OfflineModelStatus> statuses,
  ) => state.copyWith(modelStatuses: statuses);

  @override
  OfflinePacksState copyWithModelError(OfflineModelError error) =>
      state.copyWith(modelError: error);

  /// Uses the cached languages, and asks the server only when there is no
  /// cache yet. Without the statuses there is nothing to show, so failing to
  /// get them fails the whole load.
  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: const OfflinePacksLoading()));
    final languages = await _languages();
    if (isClosed) return;
    switch (languages) {
      case ApiFailure(:final failure):
        emit(state.copyWith(status: OfflinePacksFailed(failure)));
      case ApiSuccess(:final data):
        final statuses = await _getOfflineModelStatuses(data);
        if (isClosed) return;
        statuses.when(
          success: (statuses) => emit(
            state.copyWith(
              status: OfflinePacksLoaded(data),
              modelStatuses: {...statuses, ...state.modelStatuses},
            ),
          ),
          failure: (failure) =>
              emit(state.copyWith(status: OfflinePacksFailed(failure))),
        );
    }
  }

  Future<ApiResult<List<LanguageEntity>>> _languages() async {
    final cached = _getCachedLanguages();
    if (cached.isNotEmpty) return ApiResult.success(cached);
    return _syncLanguages();
  }

  /// Turning auto-download off leaves Wi-Fi only as it was, for when it is
  /// turned back on. False when the choice couldn't be saved; the switch then
  /// goes back.
  Future<bool> setAutoDownload(bool value) =>
      _changeSettings((autoDownload: value, wifiOnly: state.settings.wifiOnly));

  Future<bool> setWifiOnly(bool value) => _changeSettings((
    autoDownload: state.settings.autoDownload,
    wifiOnly: value,
  ));

  Future<bool> _changeSettings(OfflinePacksSettings settings) async {
    if (isClosed || settings == state.settings) return true;
    final previous = state.settings;
    emit(state.copyWith(settings: settings));
    final result = await _saveSettings(settings);
    if (isClosed) return false;
    return result.when(
      success: (_) => true,
      failure: (_) {
        emit(state.copyWith(settings: previous));
        return false;
      },
    );
  }
}

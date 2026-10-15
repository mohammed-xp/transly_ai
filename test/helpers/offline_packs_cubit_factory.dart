import 'package:transly_ai/features/language_picker/domain/usecases/delete_offline_model_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/download_offline_model_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_cached_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_model_statuses_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/get_offline_packs_settings_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/save_offline_packs_settings_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/sync_languages_usecase.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/watch_offline_model_updates_usecase.dart';
import 'package:transly_ai/features/language_picker/presentation/cubit/offline_packs_cubit.dart';

import 'fake_languages_repo.dart';
import 'fake_offline_models_repo.dart';

OfflinePacksCubit buildOfflinePacksCubit({
  FakeLanguagesRepo? languages,
  FakeOfflineModelsRepo? models,
}) {
  final languagesRepo = languages ?? FakeLanguagesRepo();
  final modelsRepo = models ?? FakeOfflineModelsRepo();
  return OfflinePacksCubit(
    getCachedLanguages: GetCachedLanguagesUseCase(languagesRepo),
    syncLanguages: SyncLanguagesUseCase(languagesRepo),
    getOfflineModelStatuses: GetOfflineModelStatusesUseCase(modelsRepo),
    watchOfflineModelUpdates: WatchOfflineModelUpdatesUseCase(modelsRepo),
    downloadOfflineModel: DownloadOfflineModelUseCase(modelsRepo),
    deleteOfflineModel: DeleteOfflineModelUseCase(modelsRepo),
    getSettings: GetOfflinePacksSettingsUseCase(modelsRepo),
    saveSettings: SaveOfflinePacksSettingsUseCase(modelsRepo),
  );
}

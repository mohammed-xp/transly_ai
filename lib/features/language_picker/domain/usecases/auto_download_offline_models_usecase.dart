import '../../../../core/domain/entities/language_entity.dart';
import '../repos/offline_models_repo.dart';

/// Puts the languages of an online translation on the device in the
/// background, so the same pair works offline next time. Failures are
/// dropped: nobody asked for this download.
class AutoDownloadOfflineModelsUseCase {
  const AutoDownloadOfflineModelsUseCase(this._repo);

  final OfflineModelsRepo _repo;

  Future<void> call(List<LanguageEntity> languages) async {
    await Future.wait([
      for (final code in {for (final language in languages) language.code})
        _repo.autoDownload(code),
    ]);
  }
}

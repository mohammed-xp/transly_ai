import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/entities/offline_packs_settings.dart';
import 'offline_model_error.dart';

class OfflinePacksState {
  const OfflinePacksState({
    this.status = const OfflinePacksLoading(),
    this.modelStatuses = const {},
    this.modelError,
    this.settings = defaultOfflinePacksSettings,
  });

  final OfflinePacksStatus status;

  /// Keyed by language code.
  final Map<String, OfflineModelStatus> modelStatuses;

  /// The last download or removal that failed.
  final OfflineModelError? modelError;

  final OfflinePacksSettings settings;

  /// On the device or on its way there: built in, downloaded, or
  /// downloading right now.
  List<LanguageEntity> get installed => _where(
    (status) =>
        status is OfflineModelBuiltIn ||
        status is OfflineModelDownloaded ||
        status is OfflineModelDownloading,
  );

  /// Can be downloaded.
  List<LanguageEntity> get available =>
      _where((status) => status is OfflineModelNotDownloaded);

  /// The downloaded packs, by the user or by auto-download; the built-in one
  /// isn't counted.
  int get downloadedCount =>
      modelStatuses.values.whereType<OfflineModelDownloaded>().length;

  List<LanguageEntity> _where(bool Function(OfflineModelStatus?) test) {
    final status = this.status;
    if (status is! OfflinePacksLoaded) return const [];
    return [
      for (final language in status.languages)
        if (test(modelStatuses[language.code])) language,
    ];
  }

  OfflinePacksState copyWith({
    OfflinePacksStatus? status,
    Map<String, OfflineModelStatus>? modelStatuses,
    OfflineModelError? modelError,
    OfflinePacksSettings? settings,
  }) {
    return OfflinePacksState(
      status: status ?? this.status,
      modelStatuses: modelStatuses ?? this.modelStatuses,
      modelError: modelError ?? this.modelError,
      settings: settings ?? this.settings,
    );
  }
}

sealed class OfflinePacksStatus {
  const OfflinePacksStatus();
}

class OfflinePacksLoading extends OfflinePacksStatus {
  const OfflinePacksLoading();
}

/// Set once both the languages and their statuses are known.
class OfflinePacksLoaded extends OfflinePacksStatus {
  const OfflinePacksLoaded(this.languages);

  final List<LanguageEntity> languages;
}

class OfflinePacksFailed extends OfflinePacksStatus {
  const OfflinePacksFailed(this.failure);

  final Failure failure;
}

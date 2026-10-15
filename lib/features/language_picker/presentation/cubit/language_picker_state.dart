import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/language_pair.dart';
import '../../domain/entities/offline_model_status.dart';
import 'offline_model_error.dart';

class LanguagePickerState {
  const LanguagePickerState({
    required this.pair,
    this.status = const LanguagesLoading(),
    this.recents = const [],
    this.query = '',
    this.modelStatuses = const {},
    this.modelError,
  });

  /// The pair as picked so far; applied by the caller once the sheet closes.
  final LanguagePair pair;
  final LanguagesStatus status;
  final List<LanguageEntity> recents;

  /// Kept apart from [status] so a search typed while the list is loading
  /// still applies once it arrives.
  final String query;

  /// Keyed by language code. Empty while unknown, or when the device couldn't
  /// be asked: the list then shows no offline controls at all.
  final Map<String, OfflineModelStatus> modelStatuses;

  /// The last download or removal that failed.
  final OfflineModelError? modelError;

  bool get isSearching => query.isNotEmpty;

  LanguagePickerState copyWith({
    LanguagePair? pair,
    LanguagesStatus? status,
    List<LanguageEntity>? recents,
    String? query,
    Map<String, OfflineModelStatus>? modelStatuses,
    OfflineModelError? modelError,
  }) {
    return LanguagePickerState(
      pair: pair ?? this.pair,
      status: status ?? this.status,
      recents: recents ?? this.recents,
      query: query ?? this.query,
      modelStatuses: modelStatuses ?? this.modelStatuses,
      modelError: modelError ?? this.modelError,
    );
  }
}

sealed class LanguagesStatus {
  const LanguagesStatus();
}

class LanguagesLoading extends LanguagesStatus {
  const LanguagesLoading();
}

class LanguagesLoaded extends LanguagesStatus {
  const LanguagesLoaded({
    required this.languages,
    required this.visibleLanguages,
  });

  final List<LanguageEntity> languages;

  /// [languages] narrowed down to the ones matching the query.
  final List<LanguageEntity> visibleLanguages;
}

class LanguagesFailed extends LanguagesStatus {
  const LanguagesFailed(this.failure);

  final Failure failure;
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/language_side.dart';
import '../../../../core/result/api_result.dart';
import '../../domain/entities/language_pair.dart';
import '../../domain/entities/language_selection.dart';
import '../../domain/entities/offline_model_status.dart';
import '../../domain/usecases/add_recent_language_usecase.dart';
import '../../domain/usecases/delete_offline_model_usecase.dart';
import '../../domain/usecases/download_offline_model_usecase.dart';
import '../../domain/usecases/get_cached_languages_usecase.dart';
import '../../domain/usecases/get_offline_model_statuses_usecase.dart';
import '../../domain/usecases/get_recent_languages_usecase.dart';
import '../../domain/usecases/select_language_usecase.dart';
import '../../domain/usecases/sync_languages_usecase.dart';
import '../../domain/usecases/watch_offline_model_updates_usecase.dart';
import 'language_picker_state.dart';
import 'offline_model_actions.dart';
import 'offline_model_error.dart';

class LanguagePickerCubit extends Cubit<LanguagePickerState>
    with OfflineModelActions<LanguagePickerState> {
  LanguagePickerCubit({
    required LanguagePair initialPair,
    required GetCachedLanguagesUseCase getCachedLanguages,
    required SyncLanguagesUseCase syncLanguages,
    required GetRecentLanguagesUseCase getRecentLanguages,
    required AddRecentLanguageUseCase addRecentLanguage,
    required SelectLanguageUseCase selectLanguage,
    required GetOfflineModelStatusesUseCase getOfflineModelStatuses,
    required WatchOfflineModelUpdatesUseCase watchOfflineModelUpdates,
    required DownloadOfflineModelUseCase downloadOfflineModel,
    required DeleteOfflineModelUseCase deleteOfflineModel,
  }) : _getCachedLanguages = getCachedLanguages,
       _syncLanguages = syncLanguages,
       _addRecentLanguage = addRecentLanguage,
       _selectLanguage = selectLanguage,
       _getOfflineModelStatuses = getOfflineModelStatuses,
       super(
         LanguagePickerState(pair: initialPair, recents: getRecentLanguages()),
       ) {
    initModelActions(
      watchOfflineModelUpdates: watchOfflineModelUpdates,
      downloadOfflineModel: downloadOfflineModel,
      deleteOfflineModel: deleteOfflineModel,
    );
  }

  final GetCachedLanguagesUseCase _getCachedLanguages;
  final SyncLanguagesUseCase _syncLanguages;
  final AddRecentLanguageUseCase _addRecentLanguage;
  final SelectLanguageUseCase _selectLanguage;
  final GetOfflineModelStatusesUseCase _getOfflineModelStatuses;

  @override
  Map<String, OfflineModelStatus> get modelStatuses => state.modelStatuses;

  @override
  LanguagePickerState copyWithModelStatuses(
    Map<String, OfflineModelStatus> statuses,
  ) => state.copyWith(modelStatuses: statuses);

  @override
  LanguagePickerState copyWithModelError(OfflineModelError error) =>
      state.copyWith(modelError: error);

  /// Shows the cached list straight away. The server is only asked when
  /// there is no cache yet; otherwise the sync at app start keeps it fresh.
  Future<void> load() async {
    if (isClosed) return;
    final cached = _getCachedLanguages();
    if (cached.isNotEmpty) {
      emit(state.copyWith(status: _loaded(cached)));
      await _loadModelStatuses(cached);
      return;
    }
    emit(state.copyWith(status: const LanguagesLoading()));
    final result = await _syncLanguages();
    if (isClosed) return;
    emit(
      state.copyWith(
        status: result.when<LanguagesStatus>(
          success: _loaded,
          failure: LanguagesFailed.new,
        ),
      ),
    );
    if (result case ApiSuccess(:final data)) await _loadModelStatuses(data);
  }

  void queryChanged(String query) {
    final trimmed = query.trim();
    if (isClosed || trimmed == state.query) return;
    final status = state.status;
    emit(
      state.copyWith(
        query: trimmed,
        status: status is LanguagesLoaded
            ? LanguagesLoaded(
                languages: status.languages,
                visibleLanguages: _matching(status.languages, trimmed),
              )
            : status,
      ),
    );
  }

  /// A failed save of the recents keeps them as they were: the pick itself
  /// has already been applied.
  Future<void> pick(LanguageSide side, LanguageEntity language) async {
    if (isClosed) return;
    switch (_selectLanguage(state.pair, side: side, language: language)) {
      case SelectionUnchanged():
        return;
      case SelectionSwapped(:final pair):
        emit(state.copyWith(pair: pair));
      case SelectionReplaced(:final pair):
        emit(state.copyWith(pair: pair));
        final result = await _addRecentLanguage(language);
        if (isClosed) return;
        result.when(
          success: (recents) => emit(state.copyWith(recents: recents)),
          failure: (_) {},
        );
    }
  }

  /// A failure leaves the statuses empty, which hides the offline controls;
  /// the list itself still works.
  Future<void> _loadModelStatuses(List<LanguageEntity> languages) async {
    final result = await _getOfflineModelStatuses(languages);
    result.when(success: mergeModelStatuses, failure: (_) {});
  }

  LanguagesLoaded _loaded(List<LanguageEntity> languages) => LanguagesLoaded(
    languages: languages,
    visibleLanguages: _matching(languages, state.query),
  );

  List<LanguageEntity> _matching(List<LanguageEntity> languages, String query) {
    if (query.isEmpty) return languages;
    final needle = query.toLowerCase();
    return [
      for (final language in languages)
        if (language.name.toLowerCase().contains(needle) ||
            language.nativeName.toLowerCase().contains(needle) ||
            language.code.toLowerCase() == needle)
          language,
    ];
  }
}

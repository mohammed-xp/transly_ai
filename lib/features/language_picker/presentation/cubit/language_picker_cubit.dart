import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/language_side.dart';
import '../../domain/entities/language_pair.dart';
import '../../domain/entities/language_selection.dart';
import '../../domain/usecases/add_recent_language_usecase.dart';
import '../../domain/usecases/get_cached_languages_usecase.dart';
import '../../domain/usecases/get_recent_languages_usecase.dart';
import '../../domain/usecases/select_language_usecase.dart';
import '../../domain/usecases/sync_languages_usecase.dart';
import 'language_picker_state.dart';

class LanguagePickerCubit extends Cubit<LanguagePickerState> {
  LanguagePickerCubit({
    required LanguagePair initialPair,
    required GetCachedLanguagesUseCase getCachedLanguages,
    required SyncLanguagesUseCase syncLanguages,
    required GetRecentLanguagesUseCase getRecentLanguages,
    required AddRecentLanguageUseCase addRecentLanguage,
    required SelectLanguageUseCase selectLanguage,
  }) : _getCachedLanguages = getCachedLanguages,
       _syncLanguages = syncLanguages,
       _addRecentLanguage = addRecentLanguage,
       _selectLanguage = selectLanguage,
       super(
         LanguagePickerState(pair: initialPair, recents: getRecentLanguages()),
       );

  final GetCachedLanguagesUseCase _getCachedLanguages;
  final SyncLanguagesUseCase _syncLanguages;
  final AddRecentLanguageUseCase _addRecentLanguage;
  final SelectLanguageUseCase _selectLanguage;

  /// Shows the cached list straight away. The server is only asked when
  /// there is no cache yet; otherwise the sync at app start keeps it fresh.
  Future<void> load() async {
    if (isClosed) return;
    final cached = _getCachedLanguages();
    if (cached.isNotEmpty) {
      emit(state.copyWith(status: _loaded(cached)));
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

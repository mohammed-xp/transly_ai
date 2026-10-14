import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/language_pair.dart';

class LanguagePickerState {
  const LanguagePickerState({
    required this.pair,
    this.status = const LanguagesLoading(),
    this.recents = const [],
    this.query = '',
  });

  /// The pair as picked so far; applied by the caller once the sheet closes.
  final LanguagePair pair;
  final LanguagesStatus status;
  final List<LanguageEntity> recents;

  /// Kept apart from [status] so a search typed while the list is loading
  /// still applies once it arrives.
  final String query;

  bool get isSearching => query.isNotEmpty;

  LanguagePickerState copyWith({
    LanguagePair? pair,
    LanguagesStatus? status,
    List<LanguageEntity>? recents,
    String? query,
  }) {
    return LanguagePickerState(
      pair: pair ?? this.pair,
      status: status ?? this.status,
      recents: recents ?? this.recents,
      query: query ?? this.query,
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

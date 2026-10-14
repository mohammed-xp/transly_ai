import '../../../../core/domain/entities/language_entity.dart';
import '../../../../core/domain/entities/language_side.dart';
import '../entities/language_pair.dart';
import '../entities/language_selection.dart';

/// Puts [language] on [side] of [pair]. Picking the other side's language
/// swaps the pair, so both sides never hold the same language.
class SelectLanguageUseCase {
  const SelectLanguageUseCase();

  LanguageSelection call(
    LanguagePair pair, {
    required LanguageSide side,
    required LanguageEntity language,
  }) {
    final isSource = side == LanguageSide.source;
    final current = isSource ? pair.from : pair.to;
    final other = isSource ? pair.to : pair.from;
    if (language == current) return const SelectionUnchanged();
    if (language == other) {
      return SelectionSwapped((from: pair.to, to: pair.from));
    }
    return SelectionReplaced(
      isSource
          ? (from: language, to: pair.to)
          : (from: pair.from, to: language),
    );
  }
}

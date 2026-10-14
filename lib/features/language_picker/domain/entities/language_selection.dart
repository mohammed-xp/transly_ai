import 'language_pair.dart';

sealed class LanguageSelection {
  const LanguageSelection();
}

class SelectionUnchanged extends LanguageSelection {
  const SelectionUnchanged();
}

/// The language picked was the other side's, so the two sides traded places.
class SelectionSwapped extends LanguageSelection {
  const SelectionSwapped(this.pair);

  final LanguagePair pair;
}

class SelectionReplaced extends LanguageSelection {
  const SelectionReplaced(this.pair);

  final LanguagePair pair;
}

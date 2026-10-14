import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/core/domain/entities/language_entity.dart';
import 'package:transly_ai/core/domain/entities/language_side.dart';
import 'package:transly_ai/features/language_picker/domain/entities/language_pair.dart';
import 'package:transly_ai/features/language_picker/domain/entities/language_selection.dart';
import 'package:transly_ai/features/language_picker/domain/usecases/select_language_usecase.dart';

import '../../../../helpers/fake_languages_repo.dart';

void main() {
  const select = SelectLanguageUseCase();
  const pair = (from: LanguageEntity.english, to: LanguageEntity.arabic);

  LanguagePair pairOf(LanguageSelection selection) => switch (selection) {
    SelectionSwapped(:final pair) || SelectionReplaced(:final pair) => pair,
    SelectionUnchanged() => throw StateError('no new pair'),
  };

  test('replaces the source language', () {
    final selection = select(
      pair,
      side: LanguageSide.source,
      language: testGerman,
    );

    expect(selection, isA<SelectionReplaced>());
    expect(pairOf(selection), (from: testGerman, to: LanguageEntity.arabic));
  });

  test('replaces the target language', () {
    final selection = select(
      pair,
      side: LanguageSide.target,
      language: testFrench,
    );

    expect(selection, isA<SelectionReplaced>());
    expect(pairOf(selection), (from: LanguageEntity.english, to: testFrench));
  });

  test('swaps the pair when the other side\'s language is picked', () {
    final selection = select(
      pair,
      side: LanguageSide.source,
      language: LanguageEntity.arabic,
    );

    expect(selection, isA<SelectionSwapped>());
    expect(pairOf(selection), (
      from: LanguageEntity.arabic,
      to: LanguageEntity.english,
    ));
  });

  test('leaves the pair alone when the side\'s own language is picked', () {
    final selection = select(
      pair,
      side: LanguageSide.target,
      language: LanguageEntity.arabic,
    );

    expect(selection, isA<SelectionUnchanged>());
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/translate/domain/entities/tone_catalog.dart';

import '../../../../helpers/fake_translation_repo.dart';

void main() {
  const catalog = ToneCatalog(
    tones: [formalTone, casualTone, conciseTone],
    defaultCode: 'casual',
  );

  test('resolves an offered code to its tone', () {
    expect(catalog.resolve('concise'), conciseTone);
  });

  test('falls back to the default for an unknown code', () {
    expect(catalog.resolve('poetic'), casualTone);
  });

  test('falls back to the default when no code is given', () {
    expect(catalog.resolve(null), casualTone);
  });

  test('falls back to the first tone when the default is not offered', () {
    const noDefault = ToneCatalog(
      tones: [formalTone, conciseTone],
      defaultCode: 'casual',
    );

    expect(noDefault.resolve(null), formalTone);
  });

  test('resolves to null when there are no tones', () {
    const empty = ToneCatalog(tones: [], defaultCode: 'formal');

    expect(empty.resolve('formal'), isNull);
  });
}

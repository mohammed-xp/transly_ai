import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/translate/data/models/tone_catalog_model.dart';

void main() {
  test('parses the server response', () {
    final model = ToneCatalogModel.fromJson({
      'defaultTone': 'formal',
      'tones': [
        {
          'code': 'formal',
          'name': 'رسمية',
          'description': 'Polite and professional.',
        },
      ],
    });

    final entity = model.toEntity();
    expect(entity.defaultCode, 'formal');
    expect(entity.tones.single.code, 'formal');
    expect(entity.tones.single.name, 'رسمية');
  });

  test('reads a cache written with the old nameAr field', () {
    final model = ToneCatalogModel.fromJson({
      'defaultTone': 'formal',
      'tones': [
        {'code': 'formal', 'name': 'Formal', 'nameAr': ''},
      ],
    });

    expect(model.tones.single.name, 'Formal');
  });

  test('round-trips through its cached json', () {
    final model = ToneCatalogModel.fromJson({
      'defaultTone': 'casual',
      'tones': [
        {'code': 'casual', 'name': 'Casual'},
      ],
    });

    final restored = ToneCatalogModel.fromJson(model.toJson());

    expect(restored.toJson(), model.toJson());
  });
}

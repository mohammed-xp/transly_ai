import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/translate/data/models/tone_catalog_model.dart';

void main() {
  test('parses the server response', () {
    final model = ToneCatalogModel.fromJson({
      'defaultTone': 'formal',
      'tones': [
        {
          'code': 'formal',
          'name': 'Formal',
          'nameAr': 'رسمية',
          'description': 'Polite and professional.',
        },
      ],
    });

    final entity = model.toEntity();
    expect(entity.defaultCode, 'formal');
    expect(entity.tones.single.code, 'formal');
    expect(entity.tones.single.name, 'Formal');
    expect(entity.tones.single.nameAr, 'رسمية');
  });

  test('treats a missing Arabic name as empty', () {
    final model = ToneCatalogModel.fromJson({
      'defaultTone': 'formal',
      'tones': [
        {'code': 'formal', 'name': 'Formal'},
      ],
    });

    expect(model.tones.single.nameAr, isEmpty);
  });

  test('round-trips through its cached json', () {
    final model = ToneCatalogModel.fromJson({
      'defaultTone': 'casual',
      'tones': [
        {'code': 'casual', 'name': 'Casual', 'nameAr': 'عامية'},
      ],
    });

    final restored = ToneCatalogModel.fromJson(model.toJson());

    expect(restored.toJson(), model.toJson());
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:transly_ai/core/data/models/language_model.dart';
import 'package:transly_ai/features/language_picker/data/datasources/languages_local_data_source_impl.dart';

const _german = LanguageModel(
  code: 'de',
  name: 'German',
  nativeName: 'Deutsch',
  isRtl: false,
);
const _arabic = LanguageModel(
  code: 'ar',
  name: 'Arabic',
  nativeName: 'العربية',
  isRtl: true,
);

List<Map<String, dynamic>> _json(List<LanguageModel> languages) => [
  for (final language in languages) language.toJson(),
];

void main() {
  late Directory directory;
  late Box<String> box;
  late LanguagesLocalDataSourceImpl dataSource;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('languages_test');
    Hive.init(directory.path);
    box = await Hive.openBox<String>('settings');
    dataSource = LanguagesLocalDataSourceImpl(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('languages cache', () {
    test('is null before anything is cached', () {
      expect(dataSource.getCachedLanguages(), isNull);
    });

    test('reads back the cached languages', () async {
      await dataSource.cacheLanguages([_german, _arabic]);

      expect(
        _json(dataSource.getCachedLanguages()!),
        _json([_german, _arabic]),
      );
    });

    test('throws on a corrupted cache', () async {
      await box.put('translationLanguages', 'not json');

      expect(dataSource.getCachedLanguages, throwsFormatException);
    });
  });

  group('pair', () {
    test('is null before a pair is saved', () {
      expect(dataSource.getSavedPair(), isNull);
    });

    test('reads back the saved pair', () async {
      await dataSource.savePair(_german, _arabic);

      final pair = dataSource.getSavedPair()!;
      expect(pair.from.toJson(), _german.toJson());
      expect(pair.to.toJson(), _arabic.toJson());
    });

    test('is null when only one side is stored', () async {
      await dataSource.savePair(_german, _arabic);
      await box.delete('translationTargetLanguage');

      expect(dataSource.getSavedPair(), isNull);
    });
  });

  group('recent languages', () {
    test('are empty before any is saved', () {
      expect(dataSource.getRecentLanguages(), isEmpty);
    });

    test('read back in the saved order', () async {
      await dataSource.saveRecentLanguages([_arabic, _german]);

      expect(_json(dataSource.getRecentLanguages()), _json([_arabic, _german]));
    });
  });
}

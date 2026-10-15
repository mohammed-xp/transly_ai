import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:transly_ai/core/data/datasources/offline_models_data_source_impl.dart';
import 'package:transly_ai/core/errors/app_exceptions.dart';

class _FakeModelManager implements OnDeviceTranslatorModelManager {
  final Set<String> downloaded = {};
  bool? lastWifiRequired;
  bool downloadSucceeds = true;
  bool deleteSucceeds = true;

  @override
  Future<bool> isModelDownloaded(String model) async =>
      downloaded.contains(model);

  @override
  Future<bool> downloadModel(String model, {bool isWifiRequired = true}) async {
    lastWifiRequired = isWifiRequired;
    if (downloadSucceeds) downloaded.add(model);
    return downloadSucceeds;
  }

  @override
  Future<bool> deleteModel(String model) async {
    if (deleteSucceeds) downloaded.remove(model);
    return deleteSucceeds;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeModelManager manager;
  late MlKitOfflineModelsDataSource dataSource;

  setUp(() {
    manager = _FakeModelManager();
    dataSource = MlKitOfflineModelsDataSource(manager);
  });

  group('isSupported', () {
    test('is true for a language ML Kit has a model for', () {
      expect(dataSource.isSupported('fr'), isTrue);
    });

    test('ignores the case of the code', () {
      expect(dataSource.isSupported('FR'), isTrue);
    });

    test('is false for a language ML Kit has no model for', () {
      expect(dataSource.isSupported('xx'), isFalse);
    });
  });

  group('isBuiltIn', () {
    test('is true for English', () {
      expect(dataSource.isBuiltIn('en'), isTrue);
    });

    test('is false for any other language', () {
      expect(dataSource.isBuiltIn('ar'), isFalse);
    });
  });

  group('isDownloaded', () {
    test('reports a downloaded model', () async {
      manager.downloaded.add('de');

      expect(await dataSource.isDownloaded('de'), isTrue);
    });

    test('throws for an unsupported language', () {
      expect(
        dataSource.isDownloaded('xx'),
        throwsA(isA<UnsupportedLanguageException>()),
      );
    });
  });

  group('download', () {
    test('downloads the model', () async {
      await dataSource.download('fr');

      expect(manager.downloaded, {'fr'});
    });

    test('allows mobile data', () async {
      await dataSource.download('fr');

      expect(manager.lastWifiRequired, isFalse);
    });

    test('throws when ML Kit reports a failed download', () {
      manager.downloadSucceeds = false;

      expect(dataSource.download('fr'), throwsA(isA<UnknownException>()));
    });
  });

  group('delete', () {
    test('removes the model', () async {
      manager.downloaded.add('fr');

      await dataSource.delete('fr');

      expect(manager.downloaded, isEmpty);
    });

    test('throws when ML Kit reports a failed removal', () {
      manager.deleteSucceeds = false;

      expect(dataSource.delete('fr'), throwsA(isA<UnknownException>()));
    });
  });
}

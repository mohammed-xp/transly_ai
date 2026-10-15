import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import '../../errors/app_exceptions.dart';
import 'ml_kit_language.dart';
import 'offline_models_data_source.dart';

class MlKitOfflineModelsDataSource implements OfflineModelsDataSource {
  MlKitOfflineModelsDataSource(this._modelManager);

  final OnDeviceTranslatorModelManager _modelManager;

  @override
  bool isSupported(String code) =>
      BCP47Code.fromRawValue(code.toLowerCase()) != null;

  @override
  bool isBuiltIn(String code) =>
      code.toLowerCase() == TranslateLanguage.english.bcpCode;

  @override
  Future<bool> isDownloaded(String code) async =>
      _modelManager.isModelDownloaded(mlKitLanguage(code).bcpCode);

  /// Mobile data is allowed unless [wifiRequired]: a download the user asked
  /// for shouldn't sit pending waiting for Wi-Fi with no way to tell why.
  @override
  Future<void> download(String code, {bool wifiRequired = false}) async {
    final downloaded = await _modelManager.downloadModel(
      mlKitLanguage(code).bcpCode,
      isWifiRequired: wifiRequired,
    );
    if (!downloaded) throw const UnknownException();
  }

  @override
  Future<void> delete(String code) async {
    final deleted = await _modelManager.deleteModel(
      mlKitLanguage(code).bcpCode,
    );
    if (!deleted) throw const UnknownException();
  }
}

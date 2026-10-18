import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../models/tone_catalog_model.dart';
import 'translation_settings_local_data_source.dart';

class TranslationSettingsLocalDataSourceImpl
    implements TranslationSettingsLocalDataSource {
  TranslationSettingsLocalDataSourceImpl(this._box);

  static const _toneKey = 'translationTone';
  static const _tonesKey = 'translationTones';

  final Box<String> _box;

  @override
  String? getToneCode() => _box.get(_toneKey);

  @override
  Future<void> saveToneCode(String code) => _box.put(_toneKey, code);

  @override
  ToneCatalogModel? getCachedTones() {
    final raw = _box.get(_tonesKey);
    if (raw == null) return null;
    return ToneCatalogModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> cacheTones(ToneCatalogModel tones) =>
      _box.put(_tonesKey, jsonEncode(tones.toJson()));
}

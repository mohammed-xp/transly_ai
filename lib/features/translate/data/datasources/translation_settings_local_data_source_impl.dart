import 'package:hive_ce/hive.dart';

import 'translation_settings_local_data_source.dart';

class TranslationSettingsLocalDataSourceImpl
    implements TranslationSettingsLocalDataSource {
  TranslationSettingsLocalDataSourceImpl(this._box);

  static const _toneKey = 'translationTone';

  final Box<String> _box;

  @override
  String? getToneName() => _box.get(_toneKey);

  @override
  Future<void> saveToneName(String name) => _box.put(_toneKey, name);
}

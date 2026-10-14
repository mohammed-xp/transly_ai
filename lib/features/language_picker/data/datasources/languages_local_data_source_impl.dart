import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../../../../core/data/models/language_model.dart';
import 'languages_local_data_source.dart';

class LanguagesLocalDataSourceImpl implements LanguagesLocalDataSource {
  LanguagesLocalDataSourceImpl(this._box);

  static const _languagesKey = 'translationLanguages';
  static const _sourceKey = 'translationSourceLanguage';
  static const _targetKey = 'translationTargetLanguage';
  static const _recentsKey = 'recentTranslationLanguages';

  final Box<String> _box;

  @override
  List<LanguageModel>? getCachedLanguages() => _readList(_languagesKey);

  @override
  Future<void> cacheLanguages(List<LanguageModel> languages) =>
      _box.put(_languagesKey, _encodeList(languages));

  @override
  ({LanguageModel from, LanguageModel to})? getSavedPair() {
    final from = _box.get(_sourceKey);
    final to = _box.get(_targetKey);
    if (from == null || to == null) return null;
    return (from: _decode(jsonDecode(from)), to: _decode(jsonDecode(to)));
  }

  @override
  Future<void> savePair(LanguageModel from, LanguageModel to) => _box.putAll({
    _sourceKey: jsonEncode(from.toJson()),
    _targetKey: jsonEncode(to.toJson()),
  });

  @override
  List<LanguageModel> getRecentLanguages() => _readList(_recentsKey) ?? [];

  @override
  Future<void> saveRecentLanguages(List<LanguageModel> languages) =>
      _box.put(_recentsKey, _encodeList(languages));

  List<LanguageModel>? _readList(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return [for (final item in jsonDecode(raw) as List<dynamic>) _decode(item)];
  }

  String _encodeList(List<LanguageModel> languages) =>
      jsonEncode([for (final language in languages) language.toJson()]);

  LanguageModel _decode(dynamic json) =>
      LanguageModel.fromJson(json as Map<String, dynamic>);
}

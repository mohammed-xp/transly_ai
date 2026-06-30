import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/domain/entities/language.dart';
import '../../../../core/domain/entities/translation_tone.dart';
import '../../domain/entities/history_entry.dart';

abstract interface class HistoryLocalDatasource {
  Future<List<HistoryEntry>> getAll();
  Future<List<HistoryEntry>> search(String query);
  Future<void> insert(HistoryEntry entry);
  Future<void> toggleFavorite(int id);
  Future<void> delete(int id);
  Future<void> clearAll();
}

final class SqfliteHistoryDatasource implements HistoryLocalDatasource {
  SqfliteHistoryDatasource._();

  static final SqfliteHistoryDatasource instance = SqfliteHistoryDatasource._();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  static const _table = 'history';

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'transly_history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source_text TEXT NOT NULL,
          translated_text TEXT NOT NULL,
          source_lang TEXT NOT NULL,
          target_lang TEXT NOT NULL,
          tone TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          is_favorite INTEGER NOT NULL DEFAULT 0
        )
      '''),
    );
  }

  @override
  Future<List<HistoryEntry>> getAll() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'created_at DESC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<HistoryEntry>> search(String query) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'source_text LIKE ? OR translated_text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> insert(HistoryEntry entry) async {
    final db = await _database;
    await db.insert(
      _table,
      _toRow(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> toggleFavorite(int id) async {
    final db = await _database;
    final rows = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final current = rows.first['is_favorite'] as int;
    await db.update(
      _table,
      {'is_favorite': current == 0 ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearAll() async {
    final db = await _database;
    await db.delete(_table);
  }

  HistoryEntry _fromRow(Map<String, Object?> row) {
    final sourceLang = Language.wellKnown.firstWhere(
      (l) => l.code == row['source_lang'],
      orElse: () => Language.english,
    );
    final targetLang = Language.wellKnown.firstWhere(
      (l) => l.code == row['target_lang'],
      orElse: () => Language.arabic,
    );
    final tone = TranslationTone.values.firstWhere(
      (t) => t.value == row['tone'],
      orElse: () => TranslationTone.formal,
    );
    return HistoryEntry(
      id: row['id'] as int,
      sourceText: row['source_text'] as String,
      translatedText: row['translated_text'] as String,
      pair: LanguagePair(source: sourceLang, target: targetLang),
      tone: tone,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      isFavorite: (row['is_favorite'] as int) == 1,
    );
  }

  Map<String, Object?> _toRow(HistoryEntry e) => {
        'source_text': e.sourceText,
        'translated_text': e.translatedText,
        'source_lang': e.pair.source.code,
        'target_lang': e.pair.target.code,
        'tone': e.tone.value,
        'created_at': e.createdAt.millisecondsSinceEpoch,
        'is_favorite': e.isFavorite ? 1 : 0,
      };
}

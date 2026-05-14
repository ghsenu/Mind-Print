import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/journal_entry.dart';

class LocalStorageService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mind_print_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE journal_entries(
            id TEXT PRIMARY KEY,
            userId TEXT,
            content TEXT,
            moodScore INTEGER,
            entryType TEXT,
            voiceUrl TEXT,
            isAnalyzed INTEGER,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  // --- Journal Operations ---

  Future<void> saveJournalEntries(List<JournalEntry> entries) async {
    final db = await database;
    final batch = db.batch();
    for (var entry in entries) {
      batch.insert(
        'journal_entries',
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<JournalEntry>> getCachedJournalEntries(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'journal_entries',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => JournalEntry.fromMap(maps[i]));
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('journal_entries');
  }
}

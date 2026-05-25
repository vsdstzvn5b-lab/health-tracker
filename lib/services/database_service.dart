import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_record.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'health_tracker.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        caloriesConsumed REAL DEFAULT 0,
        caloriesGoal REAL DEFAULT 2000,
        waterIntake REAL DEFAULT 0,
        waterGoal REAL DEFAULT 2000,
        exerciseMinutes INTEGER DEFAULT 0,
        exerciseGoal INTEGER DEFAULT 60,
        weight REAL DEFAULT 0,
        height REAL DEFAULT 0,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE food_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recordId INTEGER NOT NULL,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (recordId) REFERENCES daily_records(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_food_record ON food_entries(recordId)');
    await db.execute('CREATE INDEX idx_date ON daily_records(date)');
  }

  // --- 日记录 ---
  static Future<DailyRecord?> getRecordByDate(DateTime date) async {
    final db = await db;
    final key = _dateKey(date);
    final maps = await db.query('daily_records', where: 'date = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return DailyRecord.fromMap(maps.first);
  }

  static Future<DailyRecord> getOrCreateToday([Map<String, dynamic>? overrides]) async {
    final today = DateTime.now();
    final existing = await getRecordByDate(today);
    if (existing != null) return existing;
    final record = DailyRecord(date: today);
    if (overrides != null) {
      final updated = record.copyWith(
        caloriesGoal: overrides['caloriesGoal'],
        waterGoal: overrides['waterGoal'],
        exerciseGoal: overrides['exerciseGoal'],
        height: overrides['height'],
        weight: overrides['weight'],
      );
      await db.insert('daily_records', updated.toMap()..remove('id'));
      return (await getRecordByDate(today))!;
    }
    await db.insert('daily_records', record.toMap()..remove('id'));
    return (await getRecordByDate(today))!;
  }

  static Future<void> saveRecord(DailyRecord record) async {
    final db = await db;
    if (record.id != null) {
      await db.update('daily_records', record.toMap(),
        where: 'id = ?', whereArgs: [record.id]);
    } else {
      await db.insert('daily_records', record.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<List<DailyRecord>> getRecentRecords(int days) async {
    final db = await db;
    final start = DateTime.now().subtract(Duration(days: days - 1));
    final maps = await db.query('daily_records',
      where: 'date >= ?', whereArgs: [_dateKey(start)],
      orderBy: 'date DESC');
    return maps.map((m) => DailyRecord.fromMap(m)).toList();
  }

  // --- 饮食记录 ---
  static Future<List<FoodEntry>> getFoodEntries(int recordId) async {
    final db = await db;
    final maps = await db.query('food_entries',
      where: 'recordId = ?', whereArgs: [recordId],
      orderBy: 'createdAt DESC');
    return maps.map((m) => FoodEntry.fromMap(m)).toList();
  }

  static Future<void> addFoodEntry(FoodEntry entry) async {
    final db = await db;
    await db.insert('food_entries', entry.toMap()..remove('id'));
    // 更新主记录热量汇总
    final entries = await getFoodEntries(entry.recordId);
    final total = entries.fold<double>(0, (sum, e) => sum + e.calories);
    await db.update('daily_records',
      {'caloriesConsumed': total},
      where: 'id = ?', whereArgs: [entry.recordId]);
  }

  static Future<void> deleteFoodEntry(int entryId, int recordId) async {
    final db = await db;
    await db.delete('food_entries', where: 'id = ?', whereArgs: [entryId]);
    final entries = await getFoodEntries(recordId);
    final total = entries.fold<double>(0, (sum, e) => sum + e.calories);
    await db.update('daily_records',
      {'caloriesConsumed': total},
      where: 'id = ?', whereArgs: [recordId]);
  }

  static String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
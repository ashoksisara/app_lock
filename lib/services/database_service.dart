// SQLite database service using sqflite — manages tables for profiles and locked apps
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String _dbName = 'app_lock.db';
  static const int _dbVersion = 2;
  static const String tableProfiles = 'profiles';
  static const String tableLockedApps = 'locked_apps';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final String dbPath = await getDatabasesPath();
    final String path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProfiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        emoji TEXT NOT NULL,
        hashed_pin TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await _createLockedAppsTable(db);
  }

  Future<void> _createLockedAppsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableLockedApps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_id INTEGER NOT NULL,
        package_name TEXT NOT NULL,
        FOREIGN KEY (profile_id) REFERENCES $tableProfiles(id) ON DELETE CASCADE,
        UNIQUE(profile_id, package_name)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Database upgrade from v$oldVersion to v$newVersion');
    if (oldVersion < 2) {
      await _createLockedAppsTable(db);
    }
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    final Database db = await database;
    return db.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final Database db = await database;
    return db.query(table, orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> queryById(String table, int id) async {
    final Database db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    required int id,
  }) async {
    final Database db = await database;
    return db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final Database db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final Database db = await database;
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteAll(String table) async {
    final Database db = await database;
    return db.delete(table);
  }

  Future<int> deleteWhere(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final Database db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int?> count(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM $table WHERE $where',
      whereArgs,
    );
    return Sqflite.firstIntValue(result);
  }
}

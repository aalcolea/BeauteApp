import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
//tablas
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE session(
            id INTEGER PRIMARY KEY,
            token TEXT,
            user_id INTEGER,
            is_doctor INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE users(
            id BIGINT PRIMARY KEY,
            name TEXT,
            email TEXT,
            email_verified_at TEXT,
            fcm_token TEXT,
            created_at TEXT,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE clients(
            id BIGINT PRIMARY KEY,
            name TEXT,
            number TEXT,
            email TEXT,
            visit_count INTEGER,
            last_visit TEXT,
            next_visit TEXT,
            occupation TEXT,
            marital_status TEXT,
            created_at TEXT,
            updated_at TEXT
        ''');
      },
    );
  }
  //funciones usuarios
  Future<void> saveUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
  Future<void> saveSession(String token, int userId, bool isDoctor) async {
    final db = await database;
    await db.insert(
      'session',
      {'id': 1, 'token': token, 'user_id': userId, 'is_doctor': isDoctor ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSession() async {
    final db = await database;
    final List<Map<String, dynamic>> session = await db.query('session', where: 'id = ?', whereArgs: [1]);
    if (session.isNotEmpty) return session.first;
    return null;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('session');
  }
  //funciones clientes
  Future<void> insertClient(List<Map<String, dynamic>> clients) async{
    final db = await database;
    Batch batch = db.batch();
    for(var client in clients){
      batch.insert('clients',client, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }
}

import 'package:path/path.dart';
import 'package:renjana/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tugas12.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        email TEXT UNIQUE,
        noHp TEXT,
        password TEXT,
        asalKota TEXT
        )
      ''');
      },
    );
  }

  Future<bool> userRegister(UserSQLModel pengguna) async {
    final db = await database;

    try {
      await db.insert('user', pengguna.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserSQLModel?> loginUser(String email, String password) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return UserSQLModel.fromMap(results.first);
    }
    return null;
  }

  Future<List<UserSQLModel>> getAllUser() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('user');
    return results.map((map) => UserSQLModel.fromMap(map)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> updateUser(UserSQLModel pengguna) async {
    final db = await database;

    try {
      int count = await db.update(
        'user',
        pengguna.toMap(),
        where: 'id = ?',
        whereArgs: [pengguna.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}

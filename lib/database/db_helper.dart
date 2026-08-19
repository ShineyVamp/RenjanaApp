import 'package:path/path.dart';
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
    final path = join(dbPath, 'renjana.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        email TEXT UNIQUE,
        noHp TEXT,
        password TEXT)''');

        await db.execute('''CREATE TABLE quiz (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kategori TEXT,
        soal TEXT UNIQUE,
        daftarJawaban TEXT,
        jawabanBenar INTEGER)''');
      },
    );
  }
}

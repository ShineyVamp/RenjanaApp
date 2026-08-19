import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'budaya_data.dart';
import 'sejarah_data.dart';

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
      version: 3,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT,
      email TEXT UNIQUE,
      noHp TEXT,
      password TEXT
    )''');

    await db.execute('''CREATE TABLE IF NOT EXISTS quiz (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kategori TEXT,
      tema TEXT,
      soal TEXT UNIQUE,
      daftarJawaban TEXT,
      jawabanBenar INTEGER,
      gambar TEXT
    )''');

    await db.execute('''CREATE TABLE IF NOT EXISTS content (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipe TEXT,
      kodeTag TEXT,
      judul TEXT,
      deskripsi TEXT,
      gambar TEXT,
      extraInfo TEXT
    )''');

    await db.execute('''CREATE TABLE IF NOT EXISTS sejarah (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kodeTag TEXT UNIQUE,
      tanggalKey TEXT,
      urutan INTEGER,
      judul TEXT,
      subtitle TEXT,
      ringkasan TEXT,
      gambarUtama TEXT,
      alurPeristiwa TEXT,
      relatedItems TEXT
    )''');

    await db.execute('''CREATE TABLE IF NOT EXISTS budaya (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kodeTag TEXT UNIQUE,
      jenis TEXT,
      urutan INTEGER,
      judul TEXT,
      kategoriLabel TEXT,
      tagline TEXT,
      deskripsi TEXT,
      gambarUtama TEXT,
      maknaSpiritual TEXT,
      gambarMaknaSpiritual TEXT,
      konteksBudaya TEXT,
      gambarKonteksBudaya TEXT,
      relatedItems TEXT
    )''');
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed initial quizzes if empty
    final quizCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM quiz'),
    );
    if (quizCount == 0) {
      await db.insert('quiz', {
        'kategori': 'SEJARAH',
        'tema': 'Perjalanan Revolusi',
        'soal': 'Di kota manakah teks proklamasi kemerdekaan Indonesia dirumuskan?',
        'daftarJawaban': jsonEncode([
          'Jakarta (Rumah Laksamana Maeda)',
          'Bandung',
          'Yogyakarta',
          'Rengasdengklok',
        ]),
        'jawabanBenar': 0,
        'gambar': 'assets/images/rengasdengklok.jpg',
      });

      await db.insert('quiz', {
        'kategori': 'BUDAYA',
        'tema': 'Budaya Sulawesi Selatan',
        'soal': 'Rumah adat khas masyarakat Toraja di Sulawesi Selatan disebut apa?',
        'daftarJawaban': jsonEncode([
          'Tongkonan',
          'Rumah Gadang',
          'Joglo',
          'Honai',
        ]),
        'jawabanBenar': 0,
        'gambar': 'assets/images/borobudurB.jpg',
      });
    }

    // Seed initial sejarah if empty
    final sejarahCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sejarah'),
    );
    if (sejarahCount == 0) {
      for (final s in defaultSejarahList) {
        await db.insert('sejarah', {
          'kodeTag': s.kodeTag,
          'tanggalKey': s.tanggalKey,
          'urutan': s.urutan,
          'judul': s.judul,
          'subtitle': s.subtitle,
          'ringkasan': s.ringkasan,
          'gambarUtama': s.gambarUtama,
          'alurPeristiwa': jsonEncode(
            s.alurPeristiwa.map((item) => item.toMap()).toList(),
          ),
          'relatedItems': jsonEncode(
            s.relatedItems.map((item) => item.toMap()).toList(),
          ),
        });
      }
    }

    // Seed initial budaya if empty
    final budayaCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM budaya'),
    );
    if (budayaCount == 0) {
      for (final b in defaultBudayaList) {
        await db.insert('budaya', {
          'kodeTag': b.kodeTag,
          'jenis': b.jenis,
          'urutan': b.urutan,
          'judul': b.judul,
          'kategoriLabel': b.kategoriLabel,
          'tagline': b.tagline,
          'deskripsi': b.deskripsi,
          'gambarUtama': b.gambarUtama,
          'maknaSpiritual': b.maknaSpiritual,
          'gambarMaknaSpiritual': b.gambarMaknaSpiritual,
          'konteksBudaya': b.konteksBudaya,
          'gambarKonteksBudaya': b.gambarKonteksBudaya,
          'relatedItems': jsonEncode(
            b.relatedItems.map((item) => item.toMap()).toList(),
          ),
        });
      }
    }
  }
}

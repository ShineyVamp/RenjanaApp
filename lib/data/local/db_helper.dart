import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'seed/budaya_seed.dart';
import 'seed/quiz_seed.dart';
import 'seed/sejarah_seed.dart';

// Nilai tujuan satu baris budaya saat migrasi kategori.
class _BudayaKategoriTarget {
  final String kodeTag;
  final String jenis;
  final int urutan;
  final String kategoriLabel;

  const _BudayaKategoriTarget({
    required this.kodeTag,
    required this.jenis,
    required this.urutan,
    required this.kategoriLabel,
  });
}

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static const int _dbVersion = 7;

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
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
        await _migrateSchema(db);
        await _seedInitialData(db);
      },
    );
  }

  // Penyesuaian skema untuk database bawaan versi aplikasi sebelumnya.
  Future<void> _migrateSchema(Database db) async {
    // v5: kolom penjelasan pada soal kuis
    try {
      final quizInfo = await db.rawQuery('PRAGMA table_info(quiz)');
      final hasPenjelasan = quizInfo.any((col) => col['name'] == 'penjelasan');
      if (!hasPenjelasan) {
        await db.execute('ALTER TABLE quiz ADD COLUMN penjelasan TEXT');
      }
    } catch (_) {}

    // v6: bookmark dipisah per user, tabel dibangun ulang karena UNIQUE
    // pada skema lama masih global.
    try {
      final bookmarkInfo = await db.rawQuery('PRAGMA table_info(bookmark)');
      final hasUserEmail = bookmarkInfo.any(
        (col) => col['name'] == 'userEmail',
      );
      if (bookmarkInfo.isNotEmpty && !hasUserEmail) {
        await db.transaction((txn) async {
          await txn.execute('ALTER TABLE bookmark RENAME TO bookmark_legacy');
          await txn.execute(_bookmarkTableSql);
          await txn.execute('''
            INSERT INTO bookmark (userEmail, itemType, kodeTag, createdAt)
            SELECT '', itemType, kodeTag, createdAt FROM bookmark_legacy
          ''');
          await txn.execute('DROP TABLE bookmark_legacy');
        });
      }
    } catch (_) {}

    // v6: kategori budaya dibakukan jadi delapan kategori resmi, destinasi
    // ditandai suffix -D pada ID tag
    try {
      for (final entry in _budayaKategoriMigration.entries) {
        final target = entry.value;
        await db.update(
          'budaya',
          {
            'kodeTag': target.kodeTag,
            'jenis': target.jenis,
            'urutan': target.urutan,
            'kategoriLabel': target.kategoriLabel,
          },
          where: 'kodeTag = ?',
          whereArgs: [entry.key],
        );
        // bookmark menyimpan kodeTag, ikut disesuaikan agar tidak putus
        await db.rawUpdate(
          'UPDATE OR IGNORE bookmark SET kodeTag = ? WHERE kodeTag = ?',
          [target.kodeTag, entry.key],
        );
      }
      // jenis lama 'ADT' diarahkan ke Rumah Adat
      await db.update(
        'budaya',
        {'jenis': 'RMH', 'kategoriLabel': 'RUMAH ADAT'},
        where: 'jenis = ?',
        whereArgs: ['ADT'],
      );
    } catch (_) {}

    // v6: tabel content digantikan tabel sejarah & budaya
    try {
      await db.execute('DROP TABLE IF EXISTS content');
    } catch (_) {}

    // v7: kolom relatedItems dibuang lewat rebuild tabel, karena SQLite lama
    // belum mendukung ALTER TABLE DROP COLUMN
    await _dropKolomRelatedItems(db, 'sejarah', _sejarahTableSql, const [
      'id',
      'kodeTag',
      'tanggalKey',
      'urutan',
      'judul',
      'subtitle',
      'ringkasan',
      'gambarUtama',
      'alurPeristiwa',
    ]);
    await _dropKolomRelatedItems(db, 'budaya', _budayaTableSql, const [
      'id',
      'kodeTag',
      'jenis',
      'urutan',
      'judul',
      'kategoriLabel',
      'tagline',
      'deskripsi',
      'gambarUtama',
      'maknaSpiritual',
      'gambarMaknaSpiritual',
      'konteksBudaya',
      'gambarKonteksBudaya',
    ]);
  }

  Future<void> _dropKolomRelatedItems(
    Database db,
    String tabel,
    String createSql,
    List<String> kolom,
  ) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info($tabel)');
      final punyaRelatedItems = info.any(
        (col) => col['name'] == 'relatedItems',
      );
      if (!punyaRelatedItems) return;

      final daftarKolom = kolom.join(', ');
      await db.transaction((txn) async {
        await txn.execute('ALTER TABLE $tabel RENAME TO ${tabel}_lama');
        await txn.execute(createSql);
        await txn.execute(
          'INSERT INTO $tabel ($daftarKolom) '
          'SELECT $daftarKolom FROM ${tabel}_lama',
        );
        await txn.execute('DROP TABLE ${tabel}_lama');
      });
    } catch (_) {}
  }

  // Pemetaan ID tag budaya bawaan versi lama ke skema kategori baru.
  static const Map<String, _BudayaKategoriTarget> _budayaKategoriMigration = {
    'BUD-ADT-1': _BudayaKategoriTarget(
      kodeTag: 'BUD-SRK-1-D',
      jenis: 'SRK',
      urutan: 1,
      kategoriLabel: 'SENI RUPA DAN KRIYA',
    ),
    'BUD-ADT-2': _BudayaKategoriTarget(
      kodeTag: 'BUD-RMH-1-D',
      jenis: 'RMH',
      urutan: 1,
      kategoriLabel: 'RUMAH ADAT',
    ),
    'BUD-TRN-1': _BudayaKategoriTarget(
      kodeTag: 'BUD-TRN-1',
      jenis: 'TRN',
      urutan: 1,
      kategoriLabel: 'TARIAN TRADISIONAL',
    ),
    'BUD-MSK-1': _BudayaKategoriTarget(
      kodeTag: 'BUD-MSK-1',
      jenis: 'MSK',
      urutan: 1,
      kategoriLabel: 'ALAT MUSIK DAN LAGU DAERAH',
    ),
  };

  static const String _bookmarkTableSql =
      '''CREATE TABLE IF NOT EXISTS bookmark (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT NOT NULL DEFAULT '',
      itemType TEXT,
      kodeTag TEXT,
      createdAt TEXT,
      UNIQUE(userEmail, kodeTag)
    )''';

  static const String _userTableSql = '''CREATE TABLE IF NOT EXISTS user (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nama TEXT,
      email TEXT UNIQUE,
      noHp TEXT,
      password TEXT
    )''';

  static const String _quizTableSql = '''CREATE TABLE IF NOT EXISTS quiz (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kategori TEXT,
      tema TEXT,
      soal TEXT UNIQUE,
      daftarJawaban TEXT,
      jawabanBenar INTEGER,
      gambar TEXT,
      penjelasan TEXT
    )''';

  static const String _sejarahTableSql = '''CREATE TABLE IF NOT EXISTS sejarah (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kodeTag TEXT UNIQUE,
      tanggalKey TEXT,
      urutan INTEGER,
      judul TEXT,
      subtitle TEXT,
      ringkasan TEXT,
      gambarUtama TEXT,
      alurPeristiwa TEXT
    )''';

  static const String _budayaTableSql = '''CREATE TABLE IF NOT EXISTS budaya (
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
      gambarKonteksBudaya TEXT
    )''';

  Future<void> _createTables(Database db) async {
    await db.execute(_userTableSql);
    await db.execute(_quizTableSql);
    await db.execute(_sejarahTableSql);
    await db.execute(_budayaTableSql);
    await db.execute(_bookmarkTableSql);
  }

  Future<void> _seedInitialData(Database db) async {
    // seed kuis
    final quizCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM quiz'),
    );
    if (quizCount == null || quizCount <= 2) {
      for (final q in defaultQuizList) {
        await db.insert('quiz', {
          'kategori': q.kategori,
          'tema': q.tema,
          'soal': q.soal,
          'daftarJawaban': jsonEncode(q.daftarJawaban),
          'jawabanBenar': q.jawabanBenar,
          'gambar': q.gambar,
          'penjelasan': q.penjelasan,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // seed sejarah
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
        });
      }
    }

    // seed budaya
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
        });
      }
    }
  }
}

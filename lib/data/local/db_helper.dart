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

  static const int _dbVersion = 11;

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

    // v6: bookmark dipisah per user, tabel dibangun ulang
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
        // bookmark menyimpan kodeTag, ikut disesuaikan
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

    // v7: kolom relatedItems dibuang lewat pembangunan ulang tabel
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

    // v8: asal daerah pada kedua arsip, dan field khas kategori pada budaya
    await _tambahKolom(db, 'sejarah', 'provinsi');
    await _tambahKolom(db, 'budaya', 'provinsi');
    await _tambahKolom(db, 'budaya', 'detailKategori');

    // v8: isi provinsi untuk data bawaan yang sudah terlanjur tersimpan
    await _isiProvinsiBawaan(db, 'budaya', _provinsiBudayaBawaan);
    await _isiProvinsiBawaan(db, 'sejarah', _provinsiSejarahBawaan);

    // v8: isi bawaan untuk kategori budaya baru
    await _sisipkanBudayaBaru(db);

    // v9: foto profil pengguna
    await _tambahKolom(db, 'user', 'fotoProfil');

    // v11: penanda sub-kategori tema kuis
    await _tambahKolom(db, 'quiz', 'subKategori');
    await _isiSubKategoriBawaan(db);
  }

  // Mengisi penanda sub-kategori tema kuis bawaan, hanya pada baris yang
  // penandanya masih kosong.
  Future<void> _isiSubKategoriBawaan(Database db) async {
    try {
      for (final entri in _subKategoriKuisBawaan.entries) {
        await db.update(
          'quiz',
          {'subKategori': entri.value},
          where: 'tema = ? AND (subKategori IS NULL OR subKategori = ?)',
          whereArgs: [entri.key, ''],
        );
      }
    } catch (_) {}
  }

  // Menyisipkan item bawaan yang kodeTag-nya belum ada di database.
  Future<void> _sisipkanBudayaBaru(Database db) async {
    try {
      final baris = await db.query('budaya', columns: ['kodeTag']);
      final sudahAda = baris
          .map((r) => r['kodeTag'] as String?)
          .whereType<String>()
          .toSet();

      for (final b in defaultBudayaList) {
        if (sudahAda.contains(b.kodeTag)) continue;
        await db.insert(
          'budaya',
          b.toKolom(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (_) {}
  }

  // Menambah satu kolom TEXT bila belum ada.
  Future<void> _tambahKolom(Database db, String tabel, String kolom) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info($tabel)');
      final sudahAda = info.any((col) => col['name'] == kolom);
      if (!sudahAda) {
        await db.execute('ALTER TABLE $tabel ADD COLUMN $kolom TEXT');
      }
    } catch (_) {}
  }

  // Mengisi kolom provinsi, hanya pada baris yang provinsinya masih kosong.
  Future<void> _isiProvinsiBawaan(
    Database db,
    String tabel,
    Map<String, String> pemetaan,
  ) async {
    try {
      for (final entry in pemetaan.entries) {
        await db.update(
          tabel,
          {'provinsi': entry.value},
          where: 'kodeTag = ? AND (provinsi IS NULL OR provinsi = ?)',
          whereArgs: [entry.key, ''],
        );
      }
    } catch (_) {}
  }

  static const Map<String, String> _provinsiBudayaBawaan = {
    'BUD-SNJT-1': 'DI Yogyakarta',
    'BUD-SRK-1-D': 'Jawa Tengah',
    'BUD-SNJT-2': 'Sulawesi Selatan',
    'BUD-TRN-1': 'Aceh',
    'BUD-RMH-1-D': 'Sulawesi Selatan',
    'BUD-MSK-1': 'Jawa Tengah',
  };

  static const Map<String, String> _provinsiSejarahBawaan = {
    'HIS-170845-1': 'DKI Jakarta',
    'HIS-150845-1': 'DKI Jakarta',
    'HIS-160845-1': 'Jawa Barat',
    'HIS-160845-2': 'DKI Jakarta',
    'HIS-200845-1': 'DKI Jakarta',
    'HIS-281028-1': 'DKI Jakarta',
  };

  // Penanda sub-kategori untuk tema kuis bawaan. Tema yang isinya menjangkau
  // banyak daerah tidak didaftarkan di sini dan masuk kelompok "Lainnya".
  static const Map<String, String> _subKategoriKuisBawaan = {
    'Cagar Budaya & Arsitektur': 'SIT',
    'Tradisi & Mahakarya Leluhur': 'UPC',
    'Kekayaan Sulawesi Selatan': 'Sulawesi Selatan',
  };

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
      password TEXT,
      fotoProfil TEXT
    )''';

  static const String _riwayatTableSql = '''CREATE TABLE IF NOT EXISTS riwayat (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT,
      jenis TEXT,
      nilai TEXT,
      dicatatPada INTEGER
    )''';

  static const String _quizTableSql = '''CREATE TABLE IF NOT EXISTS quiz (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      kategori TEXT,
      subKategori TEXT,
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
      alurPeristiwa TEXT,
      provinsi TEXT
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
      gambarKonteksBudaya TEXT,
      provinsi TEXT,
      detailKategori TEXT
    )''';

  Future<void> _createTables(Database db) async {
    await db.execute(_userTableSql);
    await db.execute(_quizTableSql);
    await db.execute(_sejarahTableSql);
    await db.execute(_budayaTableSql);
    await db.execute(_bookmarkTableSql);
    await db.execute(_riwayatTableSql);
  }

  Future<void> _seedInitialData(Database db) async {
    // seed kuis
    final quizCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM quiz'),
    );
    if (quizCount == null || quizCount <= 2) {
      for (final q in defaultQuizList) {
        await db.insert(
          'quiz',
          q.toMap()..remove('id'),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
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
          'provinsi': s.provinsi,
        });
      }
    }

    // seed budaya
    final budayaCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM budaya'),
    );
    if (budayaCount == 0) {
      for (final b in defaultBudayaList) {
        await db.insert('budaya', b.toKolom());
      }
    }
  }
}

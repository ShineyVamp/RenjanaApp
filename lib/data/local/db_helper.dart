import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/katalog_kategori.dart';
import 'seed/budaya_seed.dart';
import 'seed/demo_user_seed.dart';
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

  // Wajib dinaikkan bukan hanya saat skema berubah, tetapi juga setiap kali
  // isi berkas seed bertambah. Penyisipan konten bawaan menumpang pada
  // onUpgrade, yang hanya jalan bila angka ini lebih besar dari versi yang
  // tersimpan di perangkat.
  static const int _dbVersion = 23;

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
      onOpen: (db) async {
        await _migrateSchema(db);
        await DemoUserSeed.seedDemoUser(db);
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

    // v9: foto profil pengguna
    await _tambahKolom(db, 'user', 'fotoProfil');

    // v11: penanda sub-kategori tema kuis
    await _tambahKolom(db, 'quiz', 'subKategori');
    await _isiSubKategoriBawaan(db);

    // v14: kepemilikan data pindah dari email ke id akun
    await _siapkanKolomPemilik(db);
    await _isiPemilikDariEmail(db);
    await _pindahkanArsipDibaca(db);
    await _siapkanIndeksUnikUser(db);

    // v15: indeks riwayat kuis
    await _siapkanIndeksKuisRiwayat(db);

    // v16: rekap dan rekor kuis dipisah dari riwayatnya
    await _bangunRekapKuis(db);

    // v17: usulan konten dari pengguna, beserta nama pengusul pada arsipnya
    await _tambahKolom(db, 'sejarah', 'kontributor');
    await _tambahKolom(db, 'budaya', 'kontributor');
    await _siapkanIndeksUsulan(db);

    // v19: kolom periode, jenisPeristiwa, dan detailPeristiwa pada sejarah
    await _tambahKolom(db, 'sejarah', 'periode');
    await _tambahKolom(db, 'sejarah', 'jenisPeristiwa');
    await _tambahKolom(db, 'sejarah', 'detailPeristiwa');
    await _isiKategoriSejarahBawaan(db);

    // v20: format media (video & youtube) pada arsip sejarah dan budaya
    await _tambahKolom(db, 'sejarah', 'jenisMedia', tipe: "TEXT DEFAULT 'gambar'");
    await _tambahKolom(db, 'sejarah', 'mediaUrl', tipe: 'TEXT');
    await _tambahKolom(db, 'budaya', 'jenisMedia', tipe: "TEXT DEFAULT 'gambar'");
    await _tambahKolom(db, 'budaya', 'mediaUrl', tipe: 'TEXT');

    // v21: pembeku runtun (streak freeze) dan bank soal salah
    await _tambahKolom(db, 'kunjungan', 'beku', tipe: 'INTEGER DEFAULT 0');
    await db.execute(_runtunPembekuTableSql);
    await db.execute(_soalSalahTableSql);

    // v22: komunitas lokal (diskusi, jawaban, suara) dan moderasi laporan
    await db.execute(_diskusiTableSql);
    await db.execute(_jawabanTableSql);
    await db.execute(_suaraTableSql);
    await db.execute(_laporanTableSql);
    await _sisipkanDiskusiBawaan(db);

    // Penyisipan konten bawaan, selalu dijalankan terakhir agar seluruh kolom
    // yang dibutuhkan sudah ada. Ketiganya memeriksa isi database dulu,
    // sehingga aman dipanggil berulang.
    await _sisipkanKategoriBawaan(db);
    await _sisipkanBudayaBaru(db);
    await _sisipkanKuisBaru(db);
  }

  // Menyisipkan kategori bawaan yang kodenya belum ada. Nama, urutan, dan
  // daftar field yang sudah diubah admin tidak ditimpa.
  Future<void> _sisipkanKategoriBawaan(Database db) async {
    try {
      for (final ranah in ranahKategori) {
        for (final item in kategoriBawaan(ranah)) {
          await db.insert(
            'kategori',
            item.toKolom(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    } catch (_) {}
  }

  // Mengisi userId dari userEmail yang sudah tersimpan. Baris tanpa pemilik
  // atau yang emailnya tidak cocok akun mana pun dibiarkan kosong.
  Future<void> _isiPemilikDariEmail(Database db) async {
    for (final tabel in _tabelMilikAkun) {
      try {
        await db.execute(
          'UPDATE $tabel SET userId = ('
          'SELECT id FROM user WHERE LOWER(user.email) = LOWER($tabel.userEmail)'
          ') WHERE userId IS NULL',
        );
      } catch (_) {}
    }
  }

  // Riwayat arsip yang sudah ada dipindahkan ke tabel permanen, supaya capaian
  // pengguna lama tidak dimulai dari nol.
  Future<void> _pindahkanArsipDibaca(Database db) async {
    try {
      await db.execute(_arsipDibacaTableSql);
      await db.execute(
        'INSERT OR IGNORE INTO arsip_dibaca (userId, ref, dibacaPada) '
        'SELECT userId, nilai, dicatatPada FROM riwayat '
        "WHERE jenis = 'arsip' AND userId IS NOT NULL",
      );
    } catch (_) {}
  }

  // Menyusun rekap dan rekor dari riwayat yang sudah ada, sekali saja. Setelah
  // ini keduanya dipelihara oleh HasilKuisRepository setiap kuis disimpan.
  Future<void> _bangunRekapKuis(Database db) async {
    try {
      await db.execute(_kuisRekapTableSql);
      await db.execute(_kuisRekorTableSql);

      final sudah = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM kuis_rekap'),
      );
      if ((sudah ?? 0) > 0) return;

      await db.execute(
        'INSERT OR REPLACE INTO kuis_rekap '
        '(userId, percobaan, totalSoal, totalBenar) '
        'SELECT userId, COUNT(*), COALESCE(SUM(jumlahSoal), 0), '
        'COALESCE(SUM(benar), 0) FROM kuis_riwayat '
        'WHERE userId IS NOT NULL GROUP BY userId',
      );

      // peringkat gabungan: benar terbanyak dulu, lalu waktu tercepat
      await db.execute(
        'INSERT OR REPLACE INTO kuis_rekor '
        '(userId, tema, kategori, subKategori, jumlahSoal, benar, salah, '
        'detik, selesaiPada) '
        'SELECT userId, tema, kategori, subKategori, jumlahSoal, benar, '
        'salah, detik, selesaiPada FROM ('
        'SELECT *, MAX(benar * 100000 - detik) AS peringkat '
        'FROM kuis_riwayat '
        "WHERE userId IS NOT NULL AND tema <> '' AND jumlahSoal > 0 "
        'GROUP BY userId, LOWER(tema))',
      );
    } catch (_) {}
  }

  // Menyisipkan soal bawaan yang teksnya belum ada di database.
  Future<void> _sisipkanKuisBaru(Database db) async {
    try {
      final baris = await db.query('quiz', columns: ['soal']);
      final sudahAda = baris
          .map((r) => r['soal'] as String?)
          .whereType<String>()
          .toSet();

      for (final q in defaultQuizList) {
        if (sudahAda.contains(q.soal)) continue;
        await db.insert(
          'quiz',
          q.toMap()..remove('id'),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    } catch (_) {}
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

  // Menambah satu kolom bila belum ada.
  Future<void> _tambahKolom(
    Database db,
    String tabel,
    String kolom, {
    String tipe = 'TEXT',
  }) async {
    try {
      final namaKolom = kolom.trim().split(RegExp(r'\s+')).first;
      final info = await db.rawQuery('PRAGMA table_info($tabel)');
      final sudahAda = info.any((col) => col['name'] == namaKolom);
      if (!sudahAda) {
        if (kolom.trim().contains(' ')) {
          await db.execute('ALTER TABLE $tabel ADD COLUMN $kolom');
        } else {
          await db.execute('ALTER TABLE $tabel ADD COLUMN $kolom $tipe');
        }
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

  static const Map<String, ({String periode, String jenis, String detail})>
  _kategoriSejarahBawaan = {
    'HIS-170845-1': (
      periode: 'REV',
      jenis: 'NSK',
      detail:
          '{"penulis":"Ir. Soekarno & Drs. Moh. Hatta","tahun":"17 Agustus 1945","isiPokok":"Pernyataan kemerdekaan bangsa Indonesia dan pengalihan kekuasaan secara saksama.","tempatSimpan":"Monumen Nasional (Monas), Jakarta"}',
    ),
    'HIS-150845-1': (
      periode: 'REV',
      jenis: 'PRG',
      detail:
          '{"pihakTerlibat":["Kekaisaran Jepang","Pasukan Sekutu"],"lokasi":"Tokyo / Kawasan Pasifik","hasil":"Jepang menyerah tanpa syarat kepada Sekutu, menciptakan kekosongan kekuasaan (vacuum of power) di Indonesia.","korban":"Ratusan ribu korban perang di kawasan Asia Pasifik"}',
    ),
    'HIS-160845-1': (
      periode: 'REV',
      jenis: 'PRG',
      detail:
          '{"pihakTerlibat":["Golongan Muda (Sukarni, Chaerul Saleh, Wikana)","Golongan Tua (Ir. Soekarno, Drs. Moh. Hatta)"],"lokasi":"Rengasdengklok, Karawang, Jawa Barat","hasil":"Soekarno dan Hatta menyetujui percepatan pelaksanaan proklamasi kemerdekaan.","korban":"Tidak ada korban fisik"}',
    ),
    'HIS-160845-2': (
      periode: 'REV',
      jenis: 'NSK',
      detail:
          '{"penulis":"Soekarno, Moh. Hatta, Achmad Soebardjo","tahun":"16-17 Agustus 1945 dini hari","isiPokok":"Rumusan naskah proklamasi yang otentik dan disepakati bersama para tokoh pergerakan.","tempatSimpan":"Arsip Nasional Republik Indonesia (ANRI)"}',
    ),
    'HIS-200845-1': (
      periode: 'REV',
      jenis: 'ORG',
      detail:
          '{"pendiri":["Panitia Persiapan Kemerdekaan Indonesia (PPKI)"],"tahunBerdiri":"20-22 Agustus 1945","tujuan":"Memelihara keamanan bersama rakyat dan menjaga keselamatan negara yang baru lahir.","tokohPenting":["Kasman Singodimedjo","Chaeroel Saleh","Kaprawi","Sutjipto"]}',
    ),
    'HIS-281028-1': (
      periode: 'NAS',
      jenis: 'PRJ',
      detail:
          '{"tempat":"Gedung Indonesische Clubgebouw, Jl. Kramat Raya 106, Jakarta","penandatangan":["Soegondo Djojopoespito (Ketua)","R.M. Djoko Marsaid (Wakil)","Mohammad Yamin (Sekretaris)","Amir Sjarifoeddin (Bendahara)"],"isiPokok":"Ikrar persatuan satu tanah air, satu bangsa, dan menjunjung bahasa persatuan bahasa Indonesia."}',
    ),
  };

  Future<void> _isiKategoriSejarahBawaan(Database db) async {
    try {
      for (final entry in _kategoriSejarahBawaan.entries) {
        await db.update(
          'sejarah',
          {
            'periode': entry.value.periode,
            'jenisPeristiwa': entry.value.jenis,
            'detailPeristiwa': entry.value.detail,
          },
          where: 'kodeTag = ? AND (periode IS NULL OR periode = ?)',
          whereArgs: [entry.key, ''],
        );
      }
    } catch (_) {}
  }

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

  // Catatan permanen arsip yang pernah dibaca. Terpisah dari tabel `riwayat`
  // supaya menghapus daftar "terakhir dibuka" tidak ikut menghapus capaian.
  static const String _arsipDibacaTableSql =
      '''CREATE TABLE IF NOT EXISTS arsip_dibaca (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      ref TEXT,
      dibacaPada INTEGER,
      UNIQUE(userId, ref)
    )''';

  // Logo lencana yang disetel admin. Bukan milik satu akun, melainkan
  // pengaturan isi aplikasi; lencana tanpa baris di sini memakai ikon bawaan.
  // Usulan konten dari pengguna, menunggu ditinjau admin. Muatannya disimpan
  // sebagai JSON pada kolom `isi` supaya tiap jenis usulan bebas punya bentuk
  // isian sendiri tanpa menambah kolom.
  static const String _usulanTableSql = '''CREATE TABLE IF NOT EXISTS usulan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      jenis TEXT,
      maksud TEXT,
      targetKodeTag TEXT,
      provinsi TEXT,
      judul TEXT,
      isi TEXT,
      status TEXT,
      catatanAdmin TEXT,
      kodeTagHasil TEXT,
      dibuatPada INTEGER,
      diperbaruiPada INTEGER
    )''';

  // Katalog kategori yang bisa dikelola admin. Satu tabel menampung beberapa
  // katalog sekaligus, dibedakan kolom `ranah`. Kolom `field` berisi JSON
  // larik FieldKategori.
  static const String _kategoriTableSql =
      '''CREATE TABLE IF NOT EXISTS kategori (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ranah TEXT NOT NULL,
      kode TEXT NOT NULL,
      nama TEXT,
      urutan INTEGER,
      field TEXT,
      bawaan INTEGER,
      UNIQUE(ranah, kode)
    )''';

  static const String _lencanaIkonTableSql =
      '''CREATE TABLE IF NOT EXISTS lencana_ikon (
      kode TEXT PRIMARY KEY,
      gambar TEXT
    )''';

  // Satu baris per percobaan kuis yang diselesaikan.
  static const String _kuisRiwayatTableSql =
      '''CREATE TABLE IF NOT EXISTS kuis_riwayat (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT,
      kategori TEXT,
      subKategori TEXT,
      tema TEXT,
      jumlahSoal INTEGER,
      benar INTEGER,
      salah INTEGER,
      detik INTEGER,
      selesaiPada INTEGER
    )''';

  // Penjumlahan seluruh percobaan kuis satu akun. Dipisahkan dari
  // `kuis_riwayat` supaya angka totalnya tidak ikut hilang saat percobaan
  // lama dipangkas.
  static const String _kuisRekapTableSql =
      '''CREATE TABLE IF NOT EXISTS kuis_rekap (
      userId INTEGER PRIMARY KEY,
      percobaan INTEGER,
      totalSoal INTEGER,
      totalBenar INTEGER
    )''';

  // Percobaan terbaik per tema, disimpan terpisah agar rekor tidak pernah
  // terpangkas meski percobaan pembentuknya sudah lama.
  static const String _kuisRekorTableSql =
      '''CREATE TABLE IF NOT EXISTS kuis_rekor (
      userId INTEGER,
      tema TEXT,
      kategori TEXT,
      subKategori TEXT,
      jumlahSoal INTEGER,
      benar INTEGER,
      salah INTEGER,
      detik INTEGER,
      selesaiPada INTEGER,
      PRIMARY KEY (userId, tema)
    )''';

  // Satu baris per hari aktif, dipakai menghitung runtun.
  static const String _kunjunganTableSql = '''CREATE TABLE IF NOT EXISTS kunjungan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT,
      tanggal TEXT,
      beku INTEGER DEFAULT 0,
      UNIQUE(userEmail, tanggal)
    )''';

  static const String _runtunPembekuTableSql = '''CREATE TABLE IF NOT EXISTS runtun_pembeku (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      tanggal TEXT,
      alasan TEXT,
      UNIQUE(userId, tanggal)
    )''';

  static const String _soalSalahTableSql = '''CREATE TABLE IF NOT EXISTS soal_salah (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      quizId INTEGER,
      tanggal INTEGER,
      UNIQUE(userId, quizId)
    )''';

  // Lencana yang sudah terbuka beserta waktunya.
  static const String _lencanaTableSql = '''CREATE TABLE IF NOT EXISTS lencana (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT,
      kode TEXT,
      dibukaPada INTEGER,
      UNIQUE(userEmail, kode)
    )''';

  // Tingkat penuntasan tiap provinsi beserta jumlah arsipnya saat itu.
  static const String _progresWilayahTableSql =
      '''CREATE TABLE IF NOT EXISTS progres_wilayah (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userEmail TEXT,
      provinsi TEXT,
      tingkat TEXT,
      jumlahArsip INTEGER,
      diperbaruiPada INTEGER,
      UNIQUE(userEmail, provinsi)
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
      provinsi TEXT,
      kontributor TEXT,
      periode TEXT,
      jenisPeristiwa TEXT,
      detailPeristiwa TEXT,
      jenisMedia TEXT DEFAULT 'gambar',
      mediaUrl TEXT
    )''';

  static const String _diskusiTableSql = '''CREATE TABLE IF NOT EXISTS diskusi (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER,
      penulis TEXT,
      judul TEXT,
      isi TEXT,
      kategori TEXT,
      refArsip TEXT,
      dibuatPada INTEGER,
      diperbaruiPada INTEGER
    )''';

  static const String _jawabanTableSql = '''CREATE TABLE IF NOT EXISTS jawaban (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      diskusiId INTEGER,
      userId INTEGER,
      penulis TEXT,
      isi TEXT,
      dibuatPada INTEGER
    )''';

  static const String _suaraTableSql = '''CREATE TABLE IF NOT EXISTS suara (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      targetTipe TEXT,
      targetId INTEGER,
      userId INTEGER,
      nilai INTEGER,
      UNIQUE(targetTipe, targetId, userId)
    )''';

  static const String _laporanTableSql = '''CREATE TABLE IF NOT EXISTS laporan (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      targetTipe TEXT,
      targetId TEXT,
      kontenTeks TEXT,
      pelapor TEXT,
      alasan TEXT,
      status TEXT DEFAULT 'menunggu',
      dibuatPada INTEGER
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
      detailKategori TEXT,
      kontributor TEXT,
      jenisMedia TEXT DEFAULT 'gambar',
      mediaUrl TEXT
    )''';

  Future<void> _createTables(Database db) async {
    await db.execute(_userTableSql);
    await db.execute(_quizTableSql);
    await db.execute(_sejarahTableSql);
    await db.execute(_budayaTableSql);
    await db.execute(_bookmarkTableSql);
    await db.execute(_riwayatTableSql);
    await db.execute(_kuisRiwayatTableSql);
    await db.execute(_kuisRekapTableSql);
    await db.execute(_kuisRekorTableSql);
    await db.execute(_kunjunganTableSql);
    await db.execute(_runtunPembekuTableSql);
    await db.execute(_soalSalahTableSql);
    await db.execute(_lencanaTableSql);
    await db.execute(_progresWilayahTableSql);
    await db.execute(_arsipDibacaTableSql);
    await db.execute(_lencanaIkonTableSql);
    await db.execute(_usulanTableSql);
    await db.execute(_kategoriTableSql);
    await db.execute(_diskusiTableSql);
    await db.execute(_jawabanTableSql);
    await db.execute(_suaraTableSql);
    await db.execute(_laporanTableSql);
    await _siapkanKolomPemilik(db);
    await _siapkanIndeksUnikUser(db);
    await _siapkanIndeksKuisRiwayat(db);
    await _siapkanIndeksUsulan(db);
  }

  // Tabel yang isinya milik satu akun. Kolom userId ditambahkan lewat migrasi
  // karena tabel-tabel ini lahir lebih dulu dengan kunci userEmail.
  static const List<String> _tabelMilikAkun = [
    'bookmark',
    'riwayat',
    'kuis_riwayat',
    'kunjungan',
    'lencana',
    'progres_wilayah',
  ];

  Future<void> _siapkanKolomPemilik(Database db) async {
    for (final tabel in _tabelMilikAkun) {
      await _tambahKolom(db, tabel, 'userId', tipe: 'INTEGER');
    }
    await _tambahKolom(db, 'lencana', 'disematkan', tipe: 'INTEGER');
  }

  // Riwayat kuis dibaca per akun dan dikelompokkan per tema, jadi keduanya
  // diberi indeks agar tetap cepat saat percobaannya sudah menumpuk.
  Future<void> _siapkanIndeksKuisRiwayat(Database db) async {
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_kuis_riwayat_pemilik '
        'ON kuis_riwayat(userId, tema)',
      );
    } catch (_) {}
  }

  // Usulan dibaca per pemilik di halaman kontribusi dan per status di panel
  // admin, jadi keduanya diberi indeks.
  Future<void> _siapkanIndeksUsulan(Database db) async {
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_usulan_pemilik '
        'ON usulan(userId, status)',
      );
    } catch (_) {}
    try {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_usulan_status ON usulan(status)',
      );
    } catch (_) {}
  }

  // Username dan email dijaga unik tanpa membedakan huruf besar-kecil.
  // Indeks bisa dipasang belakangan, berbeda dari constraint pada CREATE TABLE.
  Future<void> _siapkanIndeksUnikUser(Database db) async {
    try {
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_nama '
        'ON user(nama COLLATE NOCASE)',
      );
    } catch (_) {}
    try {
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_email '
        'ON user(email COLLATE NOCASE)',
      );
    } catch (_) {}
  }

  Future<void> _seedInitialData(Database db) async {
    // seed katalog kategori
    await _sisipkanKategoriBawaan(db);

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
          'kontributor': s.kontributor,
          'periode': s.periode,
          'jenisPeristiwa': s.jenisPeristiwa,
          'detailPeristiwa': s.detailPeristiwaJson,
          'jenisMedia': s.jenisMedia,
          'mediaUrl': s.mediaUrl,
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

    await _sisipkanDiskusiBawaan(db);
    await DemoUserSeed.seedDemoUser(db);
  }

  Future<void> _sisipkanDiskusiBawaan(Database db) async {
    try {
      final hitung = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM diskusi'),
      );
      if (hitung == 0) {
        final kini = DateTime.now().millisecondsSinceEpoch;
        final id1 = await db.insert('diskusi', {
          'userId': 1,
          'penulis': 'Admin Renjana',
          'judul': 'Makna Filosofis Luk dan Pamor pada Keris Nusantara',
          'isi': 'Bagaimana pandangan kawan-kawan mengenai makna filosofis lekukan (luk) dan motif pamor pada sebilah keris pusaka? Apakah ada perbedaan signifikan antara keris Jawa dan Bali?',
          'kategori': 'Budaya',
          'refArsip': 'BUD-SNJT-1',
          'dibuatPada': kini - 86400000 * 2,
          'diperbaruiPada': kini - 86400000 * 2,
        });

        await db.insert('jawaban', {
          'diskusiId': id1,
          'userId': 2,
          'penulis': 'Budayawan Nusantara',
          'isi': 'Lekukan (luk) pada keris melambangkan dinamika kehidupan, sedangkan lurus melambangkan keteguhan iman dan fokus spiritual.',
          'dibuatPada': kini - 86400000,
        });

        await db.insert('diskusi', {
          'userId': 1,
          'penulis': 'Admin Renjana',
          'judul': 'Peristiwa Rengasdengklok: Peran Penting Pemuda Menjelang Proklamasi',
          'isi': 'Mari kita diskusikan bagaimana keberanian para pemuda di Rengasdengklok berhasil mempercepat momentum kemerdekaan Republik Indonesia.',
          'kategori': 'Sejarah',
          'refArsip': 'HIS-01',
          'dibuatPada': kini - 86400000,
          'diperbaruiPada': kini - 86400000,
        });
      }
    } catch (_) {}
  }
}

import 'package:sqflite/sqflite.dart';

import '../local/db_helper.dart';
import 'pemilik_akun.dart';
import '../models/hasil_kuis_model.dart';

// Rekapitulasi seluruh percobaan kuis satu akun.
class RingkasanKuis {
  final int percobaan;
  final int totalSoal;
  final int totalBenar;
  final int temaSempurna;

  const RingkasanKuis({
    this.percobaan = 0,
    this.totalSoal = 0,
    this.totalBenar = 0,
    this.temaSempurna = 0,
  });

  // Rata-rata ketepatan seluruh percobaan; jawaban salah ikut menurunkannya.
  int get persen =>
      totalSoal == 0 ? 0 : ((totalBenar * 100) / totalSoal).round();
}

// Catatan percobaan kuis milik akun yang sedang login, disimpan di tabel
// `kuis_riwayat` dan selalu disaring per id akun.
class HasilKuisRepository {
  final DbHelper _dbHelper;

  HasilKuisRepository({DbHelper? dbHelper})
    : _dbHelper = dbHelper ?? DbHelper();

  // Percobaan yang disimpan utuh untuk ditampilkan sebagai daftar. Lebih lama
  // dari ini dibuang, sebab angka totalnya sudah aman di `kuis_rekap` dan
  // capaian terbaiknya di `kuis_rekor`.
  static const int batasRiwayat = 200;

  int get _pemilik => idAkunAktif;

  // Satu percobaan masuk ke tiga tempat: daftar riwayat yang dipangkas,
  // penjumlahan total, dan rekor per tema.
  Future<void> simpan(HasilKuis hasil) async {
    final pemilik = _pemilik;
    if (pemilik <= 0 || hasil.jumlahSoal <= 0) return;

    final db = await _dbHelper.database;
    await db.insert('kuis_riwayat', hasil.toKolom(pemilik));
    await _tambahRekap(db, pemilik, hasil);
    await _perbaruiRekor(db, pemilik, hasil);
    await _pangkasRiwayat(db, pemilik);
  }

  Future<void> _tambahRekap(Database db, int pemilik, HasilKuis hasil) async {
    await db.rawInsert(
      'INSERT INTO kuis_rekap (userId, percobaan, totalSoal, totalBenar) '
      'VALUES (?, 1, ?, ?) '
      'ON CONFLICT(userId) DO UPDATE SET '
      'percobaan = percobaan + 1, '
      'totalSoal = totalSoal + excluded.totalSoal, '
      'totalBenar = totalBenar + excluded.totalBenar',
      [pemilik, hasil.jumlahSoal, hasil.benar],
    );
  }

  // Rekor diganti hanya bila percobaan barunya memang lebih baik.
  Future<void> _perbaruiRekor(Database db, int pemilik, HasilKuis hasil) async {
    if (!hasil.kuisTema) return;

    final lama = await rekorTema(hasil.tema);
    if (lama != null && !hasil.lebihBaikDari(lama)) return;

    await db.insert('kuis_rekor', {
      'userId': pemilik,
      'tema': hasil.tema.trim(),
      'kategori': hasil.kategori,
      'subKategori': hasil.subKategori,
      'jumlahSoal': hasil.jumlahSoal,
      'benar': hasil.benar,
      'salah': hasil.salah,
      'detik': hasil.detik,
      'selesaiPada': hasil.selesaiPada.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _pangkasRiwayat(Database db, int pemilik) async {
    await db.rawDelete(
      'DELETE FROM kuis_riwayat WHERE userId = ? AND id NOT IN ('
      'SELECT id FROM kuis_riwayat WHERE userId = ? '
      'ORDER BY selesaiPada DESC, id DESC LIMIT ?)',
      [pemilik, pemilik, batasRiwayat],
    );
  }

  // Percobaan terbaru di atas. [lewati] dipakai memuat halaman berikutnya
  // tanpa menarik seluruh isi tabel ke memori.
  Future<List<HasilKuis>> semua({int? batas, int lewati = 0}) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const [];

    final db = await _dbHelper.database;
    final baris = await db.query(
      'kuis_riwayat',
      where: 'userId = ?',
      whereArgs: [pemilik],
      orderBy: 'selesaiPada DESC, id DESC',
      limit: batas,
      offset: lewati > 0 ? lewati : null,
    );
    return baris.map(HasilKuis.dariKolom).toList();
  }

  // Percobaan terbaik untuk satu tema.
  Future<HasilKuis?> rekorTema(String tema) async {
    final kunci = tema.trim();
    if (kunci.isEmpty) return null;

    final pemilik = _pemilik;
    if (pemilik <= 0) return null;

    final db = await _dbHelper.database;
    final baris = await db.query(
      'kuis_rekor',
      where: 'userId = ? AND tema = ? COLLATE NOCASE',
      whereArgs: [pemilik, kunci],
      limit: 1,
    );
    if (baris.isEmpty) return null;
    return HasilKuis.dariKolom(baris.first);
  }

  // Rekor semua tema sekaligus, kuncinya nama tema huruf kecil.
  Future<Map<String, HasilKuis>> rekorPerTema() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const {};

    final db = await _dbHelper.database;
    final baris = await db.query(
      'kuis_rekor',
      where: 'userId = ?',
      whereArgs: [pemilik],
    );

    return {
      for (final r in baris)
        (r['tema'] as String? ?? '').toLowerCase(): HasilKuis.dariKolom(r),
    };
  }

  // Dipakai syarat tingkat "dikuasai" pada peta progres.
  Future<bool> pernahSempurna(String tema) async {
    final rekor = await rekorTema(tema);
    return rekor?.sempurna ?? false;
  }

  // Ketepatan keseluruhan, dibaca dari rekap yang dijaga saat menyimpan.
  // Angkanya tetap utuh meski percobaan lama sudah dipangkas.
  Future<RingkasanKuis> ringkasan() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const RingkasanKuis();

    final db = await _dbHelper.database;
    final rekap = await db.query(
      'kuis_rekap',
      where: 'userId = ?',
      whereArgs: [pemilik],
      limit: 1,
    );
    if (rekap.isEmpty) return const RingkasanKuis();

    final sempurna = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM kuis_rekor '
        'WHERE userId = ? AND salah = 0 AND jumlahSoal > 0',
        [pemilik],
      ),
    );

    int angka(String kolom) => (rekap.first[kolom] as num?)?.toInt() ?? 0;

    return RingkasanKuis(
      percobaan: angka('percobaan'),
      totalSoal: angka('totalSoal'),
      totalBenar: angka('totalBenar'),
      temaSempurna: sempurna ?? 0,
    );
  }

  Future<int> jumlahPercobaan() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final db = await _dbHelper.database;
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM kuis_riwayat WHERE userId = ?',
      [pemilik],
    );
    return (hasil.first['total'] as num?)?.toInt() ?? 0;
  }

  // Banyaknya kuis yang diselesaikan hari ini, untuk misi harian.
  Future<int> jumlahHariIni() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final sekarang = DateTime.now();
    final awalHari = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final db = await _dbHelper.database;
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM kuis_riwayat '
      'WHERE userId = ? AND selesaiPada >= ?',
      [pemilik, awalHari.millisecondsSinceEpoch],
    );
    return (hasil.first['total'] as num?)?.toInt() ?? 0;
  }
}

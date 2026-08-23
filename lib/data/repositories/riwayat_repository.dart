import '../local/db_helper.dart';
import 'pemilik_akun.dart';

// Riwayat pencarian dan arsip yang dibuka, milik akun yang sedang login.
// Disimpan di tabel `riwayat` dan selalu disaring per id akun.
class RiwayatRepository {
  final DbHelper _dbHelper;

  RiwayatRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  static const String jenisPencarian = 'pencarian';
  static const String jenisArsip = 'arsip';

  // Batas tampil di halaman Jelajah.
  static const int batasPencarian = 8;
  static const int batasDibuka = 6;

  // Batas simpan di database, dipakai hitungan aktivitas di halaman profil.
  static const int _simpanMaksPencarian = 30;
  static const int _simpanMaksArsip = 100;

  int get _pemilik => idAkunAktif;

  int _batasSimpan(String jenis) =>
      jenis == jenisPencarian ? _simpanMaksPencarian : _simpanMaksArsip;

  Future<List<String>> _ambil(String jenis, int? batas) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const [];

    final db = await _dbHelper.database;
    final baris = await db.query(
      'riwayat',
      columns: ['nilai'],
      where: 'userId = ? AND jenis = ?',
      whereArgs: [pemilik, jenis],
      orderBy: 'dicatatPada DESC, id DESC',
      limit: batas,
    );
    return baris.map((r) => r['nilai'] as String? ?? '').toList()
      ..removeWhere((n) => n.isEmpty);
  }

  // Mencatat satu entri: entri bernilai sama dibuang, entri baru disisipkan,
  // lalu sisa di luar batas simpan dipangkas.
  Future<void> _catat(String jenis, String nilai) async {
    final pemilik = _pemilik;
    final bersih = nilai.trim();
    if (pemilik <= 0 || bersih.isEmpty) return;

    final db = await _dbHelper.database;

    await db.delete(
      'riwayat',
      where: 'userId = ? AND jenis = ? AND nilai = ? COLLATE NOCASE',
      whereArgs: [pemilik, jenis, bersih],
    );
    await db.insert('riwayat', {
      'userId': pemilik,
      'jenis': jenis,
      'nilai': bersih,
      'dicatatPada': DateTime.now().millisecondsSinceEpoch,
    });

    await db.rawDelete(
      'DELETE FROM riwayat WHERE userId = ? AND jenis = ? AND id NOT IN ('
      'SELECT id FROM riwayat WHERE userId = ? AND jenis = ? '
      'ORDER BY dicatatPada DESC, id DESC LIMIT ?)',
      [pemilik, jenis, pemilik, jenis, _batasSimpan(jenis)],
    );
  }

  Future<void> _hapus(String jenis) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return;

    final db = await _dbHelper.database;
    await db.delete(
      'riwayat',
      where: 'userId = ? AND jenis = ?',
      whereArgs: [pemilik, jenis],
    );
  }

  // section riwayat pencarian

  Future<List<String>> pencarian({int? batas}) => _ambil(jenisPencarian, batas);

  Future<void> catatPencarian(String kataKunci) =>
      _catat(jenisPencarian, kataKunci);

  Future<void> hapusPencarian() => _hapus(jenisPencarian);

  // section arsip yang dibuka
  // Disimpan sebagai 'jenis|kodeTag', mis. 'budaya|BUD-RMH-1-D'.

  Future<List<String>> dibuka({int? batas}) => _ambil(jenisArsip, batas);

  Future<void> catatDibuka(String jenisArsipItem, String kodeTag) =>
      _catat(jenisArsip, '$jenisArsipItem|${kodeTag.trim()}');

  Future<void> hapusDibuka() => _hapus(jenisArsip);

  // Banyaknya arsip yang dibuka hari ini, untuk misi harian.
  Future<int> jumlahDibukaHariIni() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final sekarang = DateTime.now();
    final awalHari = DateTime(sekarang.year, sekarang.month, sekarang.day);

    final db = await _dbHelper.database;
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM riwayat '
      'WHERE userId = ? AND jenis = ? AND dicatatPada >= ?',
      [pemilik, jenisArsip, awalHari.millisecondsSinceEpoch],
    );
    return (hasil.first['total'] as num?)?.toInt() ?? 0;
  }
}

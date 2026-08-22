import '../../services/preference_handler.dart';
import '../local/db_helper.dart';

// Riwayat pencarian dan arsip yang dibuka, milik akun yang sedang login.
// Disimpan di tabel `riwayat` dan selalu disaring per userEmail.
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

  String get _emailAktif {
    try {
      return PreferenceHandler.userEmail.toLowerCase().trim();
    } catch (_) {
      return '';
    }
  }

  int _batasSimpan(String jenis) =>
      jenis == jenisPencarian ? _simpanMaksPencarian : _simpanMaksArsip;

  Future<List<String>> _ambil(String jenis, int? batas) async {
    final email = _emailAktif;
    if (email.isEmpty) return const [];

    final db = await _dbHelper.database;
    final baris = await db.query(
      'riwayat',
      columns: ['nilai'],
      where: 'userEmail = ? AND jenis = ?',
      whereArgs: [email, jenis],
      orderBy: 'dicatatPada DESC, id DESC',
      limit: batas,
    );
    return baris.map((r) => r['nilai'] as String? ?? '').toList()
      ..removeWhere((n) => n.isEmpty);
  }

  // Mencatat satu entri: entri bernilai sama dibuang, entri baru disisipkan,
  // lalu sisa di luar batas simpan dipangkas.
  Future<void> _catat(String jenis, String nilai) async {
    final email = _emailAktif;
    final bersih = nilai.trim();
    if (email.isEmpty || bersih.isEmpty) return;

    final db = await _dbHelper.database;

    await db.delete(
      'riwayat',
      where: 'userEmail = ? AND jenis = ? AND nilai = ? COLLATE NOCASE',
      whereArgs: [email, jenis, bersih],
    );
    await db.insert('riwayat', {
      'userEmail': email,
      'jenis': jenis,
      'nilai': bersih,
      'dicatatPada': DateTime.now().millisecondsSinceEpoch,
    });

    await db.rawDelete(
      'DELETE FROM riwayat WHERE userEmail = ? AND jenis = ? AND id NOT IN ('
      'SELECT id FROM riwayat WHERE userEmail = ? AND jenis = ? '
      'ORDER BY dicatatPada DESC, id DESC LIMIT ?)',
      [email, jenis, email, jenis, _batasSimpan(jenis)],
    );
  }

  Future<void> _hapus(String jenis) async {
    final email = _emailAktif;
    if (email.isEmpty) return;

    final db = await _dbHelper.database;
    await db.delete(
      'riwayat',
      where: 'userEmail = ? AND jenis = ?',
      whereArgs: [email, jenis],
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
}

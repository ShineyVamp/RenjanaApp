import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/user_session.dart';
import '../../../../data/local/db_helper.dart';
import 'riwayat_repository.dart';

// Catatan permanen arsip yang pernah dibaca, dasar hitungan capaian di
// halaman profil, lencana, dan peta progres.
//
// Terpisah dari tabel `riwayat` yang hanya menyimpan daftar "terakhir dibuka".
// Daftar itu boleh dikosongkan pengguna kapan saja, sedangkan catatan di sini
// tidak ikut terhapus.
class ArsipDibacaRepository {
  final DbHelper _dbHelper;
  final RiwayatRepository _riwayatRepository;

  ArsipDibacaRepository({
    DbHelper? dbHelper,
    RiwayatRepository? riwayatRepository,
  }) : _dbHelper = dbHelper ?? DbHelper(),
       _riwayatRepository = riwayatRepository ?? RiwayatRepository();

  int get _pemilik => idAkunAktif;

  static String buatRef(String jenis, String kodeTag) =>
      '$jenis|${kodeTag.trim()}';

  // Mencatat satu arsip sekaligus ke dua tempat: catatan permanen di sini dan
  // daftar terakhir dibuka di RiwayatRepository.
  Future<void> catat(String jenis, String kodeTag) async {
    final pemilik = _pemilik;
    final ref = buatRef(jenis, kodeTag);
    if (pemilik <= 0 || kodeTag.trim().isEmpty) return;

    final db = await _dbHelper.database;
    await db.insert('arsip_dibaca', {
      'userId': pemilik,
      'ref': ref,
      'dibacaPada': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await _riwayatRepository.catatDibuka(jenis, kodeTag);
  }

  // Seluruh arsip yang pernah dibaca, terbaru di atas.
  Future<List<String>> semua() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const [];

    final db = await _dbHelper.database;
    final baris = await db.query(
      'arsip_dibaca',
      columns: ['ref'],
      where: 'userId = ?',
      whereArgs: [pemilik],
      orderBy: 'dibacaPada DESC, id DESC',
    );
    return baris
        .map((r) => r['ref'] as String? ?? '')
        .where((r) => r.isNotEmpty)
        .toList();
  }

  Future<Set<String>> himpunan() async => (await semua()).toSet();

  Future<int> jumlah() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final db = await _dbHelper.database;
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM arsip_dibaca WHERE userId = ?',
      [pemilik],
    );
    return (hasil.first['total'] as num?)?.toInt() ?? 0;
  }
}

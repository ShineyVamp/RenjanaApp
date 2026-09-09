import '../../../../data/local/db_helper.dart';
import '../models/laporan_model.dart';

class LaporanRepository {
  final DbHelper _dbHelper;

  LaporanRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? DbHelper();

  Future<int> buatLaporan(LaporanModel laporan) async {
    final db = await _dbHelper.database;
    return await db.insert('laporan', laporan.toMap());
  }

  Future<List<LaporanModel>> getSemuaLaporan({String? status}) async {
    final db = await _dbHelper.database;
    final where = status != null && status.isNotEmpty && status != 'semua'
        ? 'status = ?'
        : null;
    final whereArgs = where != null ? [status] : null;

    final rows = await db.query(
      'laporan',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'dibuatPada DESC',
    );

    return rows.map((r) => LaporanModel.fromMap(r)).toList();
  }

  Future<int> hitungLaporanMenunggu() async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      "SELECT COUNT(*) as total FROM laporan WHERE status = 'menunggu'",
    );
    return (res.first['total'] as num?)?.toInt() ?? 0;
  }

  Future<int> perbaruiStatus(int id, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'laporan',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hapusLaporan(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('laporan', where: 'id = ?', whereArgs: [id]);
  }
}

import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/user_session.dart';
import '../../../../data/local/db_helper.dart';
import '../models/komunitas_model.dart';

class KomunitasRepository {
  final DbHelper _dbHelper;

  KomunitasRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? DbHelper();

  int get _pemilik => idAkunAktif;

  Future<List<DiskusiModel>> getDaftarDiskusi({
    String? kategori,
    String? refArsip,
    String? kataKunci,
  }) async {
    final db = await _dbHelper.database;
    final pemilik = _pemilik;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      whereClauses.add('kategori = ?');
      whereArgs.add(kategori);
    }

    if (refArsip != null && refArsip.isNotEmpty) {
      whereClauses.add('refArsip = ?');
      whereArgs.add(refArsip);
    }

    if (kataKunci != null && kataKunci.trim().isNotEmpty) {
      whereClauses.add('(judul LIKE ? OR isi LIKE ?)');
      final k = '%${kataKunci.trim()}%';
      whereArgs.addAll([k, k]);
    }

    final whereString =
        whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final rows = await db.query(
      'diskusi',
      where: whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'dibuatPada DESC',
    );

    final hasil = <DiskusiModel>[];
    for (final row in rows) {
      final dId = row['id'] as int;

      // Hitung jumlah jawaban
      final jwbRes = await db.rawQuery(
        'SELECT COUNT(*) as total FROM jawaban WHERE diskusiId = ?',
        [dId],
      );
      final totalJawaban =
          (jwbRes.first['total'] as num?)?.toInt() ?? 0;

      // Hitung total suara
      final suaraRes = await db.rawQuery(
        'SELECT COALESCE(SUM(nilai), 0) as total FROM suara WHERE targetTipe = ? AND targetId = ?',
        ['diskusi', dId],
      );
      final totalSuara =
          (suaraRes.first['total'] as num?)?.toInt() ?? 0;

      // Cek suara user aktif
      int suaraSaya = 0;
      if (pemilik > 0) {
        final sayaRes = await db.rawQuery(
          'SELECT nilai FROM suara WHERE targetTipe = ? AND targetId = ? AND userId = ?',
          ['diskusi', dId, pemilik],
        );
        if (sayaRes.isNotEmpty) {
          suaraSaya = (sayaRes.first['nilai'] as num?)?.toInt() ?? 0;
        }
      }

      hasil.add(
        DiskusiModel.fromMap(
          row,
          jumlahJawaban: totalJawaban,
          jumlahSuara: totalSuara,
          suaraSaya: suaraSaya,
        ),
      );
    }

    return hasil;
  }

  Future<DiskusiModel?> getDiskusiById(int id) async {
    final db = await _dbHelper.database;
    final pemilik = _pemilik;

    final rows = await db.query(
      'diskusi',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final jwbRes = await db.rawQuery(
      'SELECT COUNT(*) as total FROM jawaban WHERE diskusiId = ?',
      [id],
    );
    final totalJawaban = (jwbRes.first['total'] as num?)?.toInt() ?? 0;

    final suaraRes = await db.rawQuery(
      'SELECT COALESCE(SUM(nilai), 0) as total FROM suara WHERE targetTipe = ? AND targetId = ?',
      ['diskusi', id],
    );
    final totalSuara = (suaraRes.first['total'] as num?)?.toInt() ?? 0;

    int suaraSaya = 0;
    if (pemilik > 0) {
      final sayaRes = await db.rawQuery(
        'SELECT nilai FROM suara WHERE targetTipe = ? AND targetId = ? AND userId = ?',
        ['diskusi', id, pemilik],
      );
      if (sayaRes.isNotEmpty) {
        suaraSaya = (sayaRes.first['nilai'] as num?)?.toInt() ?? 0;
      }
    }

    return DiskusiModel.fromMap(
      row,
      jumlahJawaban: totalJawaban,
      jumlahSuara: totalSuara,
      suaraSaya: suaraSaya,
    );
  }

  Future<int> tambahDiskusi(DiskusiModel model) async {
    final db = await _dbHelper.database;
    return await db.insert('diskusi', model.toMap());
  }

  Future<int> hapusDiskusi(int id) async {
    final db = await _dbHelper.database;
    await db.delete('jawaban', where: 'diskusiId = ?', whereArgs: [id]);
    await db.delete(
      'suara',
      where: 'targetTipe = ? AND targetId = ?',
      whereArgs: ['diskusi', id],
    );
    return await db.delete('diskusi', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<JawabanModel>> getDaftarJawaban(int diskusiId) async {
    final db = await _dbHelper.database;
    final pemilik = _pemilik;

    final rows = await db.query(
      'jawaban',
      where: 'diskusiId = ?',
      whereArgs: [diskusiId],
      orderBy: 'dibuatPada ASC',
    );

    final hasil = <JawabanModel>[];
    for (final row in rows) {
      final jId = row['id'] as int;

      final suaraRes = await db.rawQuery(
        'SELECT COALESCE(SUM(nilai), 0) as total FROM suara WHERE targetTipe = ? AND targetId = ?',
        ['jawaban', jId],
      );
      final totalSuara = (suaraRes.first['total'] as num?)?.toInt() ?? 0;

      int suaraSaya = 0;
      if (pemilik > 0) {
        final sayaRes = await db.rawQuery(
          'SELECT nilai FROM suara WHERE targetTipe = ? AND targetId = ? AND userId = ?',
          ['jawaban', jId, pemilik],
        );
        if (sayaRes.isNotEmpty) {
          suaraSaya = (sayaRes.first['nilai'] as num?)?.toInt() ?? 0;
        }
      }

      hasil.add(
        JawabanModel.fromMap(
          row,
          jumlahSuara: totalSuara,
          suaraSaya: suaraSaya,
        ),
      );
    }

    return hasil;
  }

  Future<int> tambahJawaban(JawabanModel model) async {
    final db = await _dbHelper.database;
    return await db.insert('jawaban', model.toMap());
  }

  Future<DateTime?> getWaktuDiskusiTerakhir(int userId) async {
    if (userId <= 0) return null;
    final db = await _dbHelper.database;
    final rows = await db.query(
      'diskusi',
      columns: ['dibuatPada'],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dibuatPada DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final raw = rows.first['dibuatPada'] as String?;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<int> hapusJawaban(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'suara',
      where: 'targetTipe = ? AND targetId = ?',
      whereArgs: ['jawaban', id],
    );
    return await db.delete('jawaban', where: 'id = ?', whereArgs: [id]);
  }

  Future<JawabanModel?> getJawabanTerakhirUser(int userId, int diskusiId) async {
    if (userId <= 0) return null;
    final db = await _dbHelper.database;
    final rows = await db.query(
      'jawaban',
      where: 'userId = ? AND diskusiId = ?',
      whereArgs: [userId, diskusiId],
      orderBy: 'dibuatPada DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return JawabanModel.fromMap(rows.first);
  }

  Future<void> toggleSuara(String targetTipe, int targetId) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return;

    final db = await _dbHelper.database;
    final ada = await db.query(
      'suara',
      where: 'targetTipe = ? AND targetId = ? AND userId = ?',
      whereArgs: [targetTipe, targetId, pemilik],
    );

    if (ada.isNotEmpty) {
      // Unvote
      await db.delete(
        'suara',
        where: 'targetTipe = ? AND targetId = ? AND userId = ?',
        whereArgs: [targetTipe, targetId, pemilik],
      );
    } else {
      // Upvote +1
      await db.insert('suara', {
        'targetTipe': targetTipe,
        'targetId': targetId,
        'userId': pemilik,
        'nilai': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }
}

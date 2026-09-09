import 'package:sqflite/sqflite.dart';

import '../../../../core/storage/user_session.dart';
import '../../../../data/local/db_helper.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../capaian/data/models/lencana_model.dart';
import '../models/komunitas_model.dart';
import '../models/notifikasi_model.dart';

// repositori komunitas
class KomunitasRepository {
  final DbHelper _dbHelper;

  KomunitasRepository({DbHelper? dbHelper})
      : _dbHelper = dbHelper ?? DbHelper();

  int get _pemilik => idAkunAktif;

  // profil penulis komunitas
  Future<Map<String, dynamic>> _ambilProfilPenulis(
    Database db,
    int userId,
    String nama,
  ) async {
    String role = 'user';
    String? username;
    if (isAdminAccountName(nama)) {
      role = 'admin';
    }

    if (userId > 0) {
      final userRows = await db.query(
        'user',
        columns: ['role', 'username'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (userRows.isNotEmpty) {
        final r = userRows.first['role'] as String? ?? 'user';
        if (r == 'admin') role = 'admin';
        username = userRows.first['username'] as String?;
      }
    } else {
      final userRows = await db.query(
        'user',
        columns: ['role', 'username'],
        where: 'nama = ?',
        whereArgs: [nama],
        limit: 1,
      );
      if (userRows.isNotEmpty) {
        final r = userRows.first['role'] as String? ?? 'user';
        if (r == 'admin') role = 'admin';
        username = userRows.first['username'] as String?;
      }
    }
    username ??= nama.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    String gelar = 'Pelajar';
    final badgePilihan = <String>[];

    if (userId > 0) {
      final lencanaCountRes = await db.rawQuery(
        'SELECT COUNT(*) as total FROM lencana WHERE userId = ?',
        [userId],
      );
      final totalTerbuka =
          (lencanaCountRes.first['total'] as num?)?.toInt() ?? 0;
      gelar = gelarDariLencana(totalTerbuka).nama;

      final sematRows = await db.query(
        'lencana',
        columns: ['kode'],
        where: 'userId = ? AND disematkan = 1',
        whereArgs: [userId],
        orderBy: 'id ASC',
        limit: 3,
      );
      for (final r in sematRows) {
        final k = r['kode'] as String?;
        if (k != null && k.isNotEmpty) badgePilihan.add(k);
      }
    }

    return {
      'role': role,
      'username': username,
      'gelar': gelar,
      'badgePilihan': badgePilihan,
    };
  }

  // daftar diskusi
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
      final k = '%${kataKunci.trim()}%';
      whereClauses.add('(judul LIKE ? OR isi LIKE ?)');
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

      // hitung jumlah jawaban
      final jwbRes = await db.rawQuery(
        'SELECT COUNT(*) as total FROM jawaban WHERE diskusiId = ?',
        [dId],
      );
      final totalJawaban = (jwbRes.first['total'] as num?)?.toInt() ?? 0;

      // hitung total suara
      final suaraRes = await db.rawQuery(
        'SELECT COALESCE(SUM(nilai), 0) as total FROM suara WHERE targetTipe = ? AND targetId = ?',
        ['diskusi', dId],
      );
      final totalSuara = (suaraRes.first['total'] as num?)?.toInt() ?? 0;

      // cek suara user aktif
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

      final profil = await _ambilProfilPenulis(
        db,
        row['userId'] as int? ?? 0,
        row['penulis'] as String? ?? '',
      );

      hasil.add(
        DiskusiModel.fromMap(
          row,
          jumlahJawaban: totalJawaban,
          jumlahSuara: totalSuara,
          suaraSaya: suaraSaya,
          role: profil['role'] as String? ?? 'user',
          username: profil['username'] as String?,
          gelar: profil['gelar'] as String? ?? 'Pelajar',
          badgePilihan: profil['badgePilihan'] as List<String>? ?? const [],
        ),
      );
    }

    return hasil;
  }

  // ambil diskusi by id
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

    final profil = await _ambilProfilPenulis(
      db,
      row['userId'] as int? ?? 0,
      row['penulis'] as String? ?? '',
    );

    return DiskusiModel.fromMap(
      row,
      jumlahJawaban: totalJawaban,
      jumlahSuara: totalSuara,
      suaraSaya: suaraSaya,
      role: profil['role'] as String? ?? 'user',
      username: profil['username'] as String?,
      gelar: profil['gelar'] as String? ?? 'Pelajar',
      badgePilihan: profil['badgePilihan'] as List<String>? ?? const [],
    );
  }

  // tambah diskusi
  Future<int> tambahDiskusi(DiskusiModel model) async {
    final db = await _dbHelper.database;
    return await db.insert('diskusi', model.toMap());
  }

  // hapus diskusi
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

  // daftar jawaban komentar utama
  Future<List<JawabanModel>> getDaftarJawaban(int diskusiId) async {
    final db = await _dbHelper.database;
    final pemilik = _pemilik;

    final rows = await db.query(
      'jawaban',
      where: 'diskusiId = ? AND (indukId IS NULL OR indukId = 0)',
      whereArgs: [diskusiId],
      orderBy: 'dibuatPada ASC',
    );

    final hasil = <JawabanModel>[];
    for (final row in rows) {
      final jId = row['id'] as int;

      // hitung balasan anak
      final balasanRes = await db.rawQuery(
        'SELECT COUNT(*) as total FROM jawaban WHERE indukId = ?',
        [jId],
      );
      final totalBalasan = (balasanRes.first['total'] as num?)?.toInt() ?? 0;

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

      final profil = await _ambilProfilPenulis(
        db,
        row['userId'] as int? ?? 0,
        row['penulis'] as String? ?? '',
      );

      hasil.add(
        JawabanModel.fromMap(
          row,
          jumlahSuara: totalSuara,
          suaraSaya: suaraSaya,
          jumlahBalasan: totalBalasan,
          role: profil['role'] as String? ?? 'user',
          username: profil['username'] as String?,
          gelar: profil['gelar'] as String? ?? 'Pelajar',
          badgePilihan: profil['badgePilihan'] as List<String>? ?? const [],
        ),
      );
    }

    return hasil;
  }

  // daftar balasan komentar tertentu
  Future<List<JawabanModel>> getDaftarBalasan(int indukId) async {
    final db = await _dbHelper.database;
    final pemilik = _pemilik;

    final rows = await db.query(
      'jawaban',
      where: 'indukId = ?',
      whereArgs: [indukId],
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

      final profil = await _ambilProfilPenulis(
        db,
        row['userId'] as int? ?? 0,
        row['penulis'] as String? ?? '',
      );

      hasil.add(
        JawabanModel.fromMap(
          row,
          jumlahSuara: totalSuara,
          suaraSaya: suaraSaya,
          role: profil['role'] as String? ?? 'user',
          username: profil['username'] as String?,
          gelar: profil['gelar'] as String? ?? 'Pelajar',
          badgePilihan: profil['badgePilihan'] as List<String>? ?? const [],
        ),
      );
    }

    return hasil;
  }

  // ambil jawaban by id
  Future<JawabanModel?> getJawabanById(int id) async {
    final db = await _dbHelper.database;
    final pemilik = _pemilik;

    final rows = await db.query(
      'jawaban',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.first;
    final balasanRes = await db.rawQuery(
      'SELECT COUNT(*) as total FROM jawaban WHERE indukId = ?',
      [id],
    );
    final totalBalasan = (balasanRes.first['total'] as num?)?.toInt() ?? 0;

    final suaraRes = await db.rawQuery(
      'SELECT COALESCE(SUM(nilai), 0) as total FROM suara WHERE targetTipe = ? AND targetId = ?',
      ['jawaban', id],
    );
    final totalSuara = (suaraRes.first['total'] as num?)?.toInt() ?? 0;

    int suaraSaya = 0;
    if (pemilik > 0) {
      final sayaRes = await db.rawQuery(
        'SELECT nilai FROM suara WHERE targetTipe = ? AND targetId = ? AND userId = ?',
        ['jawaban', id, pemilik],
      );
      if (sayaRes.isNotEmpty) {
        suaraSaya = (sayaRes.first['nilai'] as num?)?.toInt() ?? 0;
      }
    }

    final profil = await _ambilProfilPenulis(
      db,
      row['userId'] as int? ?? 0,
      row['penulis'] as String? ?? '',
    );

    return JawabanModel.fromMap(
      row,
      jumlahSuara: totalSuara,
      suaraSaya: suaraSaya,
      jumlahBalasan: totalBalasan,
      role: profil['role'] as String? ?? 'user',
      username: profil['username'] as String?,
      gelar: profil['gelar'] as String? ?? 'Pelajar',
      badgePilihan: profil['badgePilihan'] as List<String>? ?? const [],
    );
  }

  // tambah jawaban atau balasan
  Future<int> tambahJawaban(JawabanModel model) async {
    final db = await _dbHelper.database;
    final id = await db.insert('jawaban', model.toMap());
    if (id > 0) {
      await _buatNotifikasiTerkait(db, model, id);
    }
    return id;
  }

  // pemicu notifikasi balasan dan mention
  Future<void> _buatNotifikasiTerkait(
    Database db,
    JawabanModel jawaban,
    int jawabanId,
  ) async {
    try {
      final diskusiRows = await db.query(
        'diskusi',
        columns: ['judul', 'penulis', 'userId'],
        where: 'id = ?',
        whereArgs: [jawaban.diskusiId],
        limit: 1,
      );
      if (diskusiRows.isEmpty) return;

      final diskusiRow = diskusiRows.first;
      final judulDiskusi = diskusiRow['judul'] as String? ?? '';
      final diskusiPenulis = diskusiRow['penulis'] as String? ?? '';
      final diskusiUserId = diskusiRow['userId'] as int? ?? 0;

      final senderPenulis = jawaban.penulis;
      final senderUserId = jawaban.userId;
      final kini = DateTime.now().millisecondsSinceEpoch;

      String senderUsername =
          senderPenulis.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      if (senderUserId > 0) {
        final uRows = await db.query(
          'user',
          columns: ['username'],
          where: 'id = ?',
          whereArgs: [senderUserId],
          limit: 1,
        );
        if (uRows.isNotEmpty && uRows.first['username'] != null) {
          senderUsername = uRows.first['username'] as String;
        }
      }

      // 1. notifikasi balasan
      if (jawaban.indukId != null && jawaban.indukId! > 0) {
        final parentRows = await db.query(
          'jawaban',
          columns: ['penulis', 'userId'],
          where: 'id = ?',
          whereArgs: [jawaban.indukId],
          limit: 1,
        );
        if (parentRows.isNotEmpty) {
          final parentPenulis = parentRows.first['penulis'] as String? ?? '';
          final parentUserId = parentRows.first['userId'] as int? ?? 0;

          if (parentPenulis.toLowerCase() != senderPenulis.toLowerCase() &&
              parentPenulis.toLowerCase() != senderUsername.toLowerCase()) {
            await _sisipkanNotifikasi(
              db,
              userId: parentUserId,
              targetNama: parentPenulis,
              pengirimId: senderUserId,
              pengirimNama: senderPenulis,
              pengirimUsername: senderUsername,
              tipe: 'balas',
              diskusiId: jawaban.diskusiId,
              jawabanId: jawabanId,
              indukJawabanId: jawaban.indukId,
              judulDiskusi: judulDiskusi,
              cuplikanTeks: jawaban.isi,
              dibuatPada: kini,
            );
          }
        }
      } else {
        if (diskusiPenulis.toLowerCase() != senderPenulis.toLowerCase() &&
            diskusiPenulis.toLowerCase() != senderUsername.toLowerCase()) {
          await _sisipkanNotifikasi(
            db,
            userId: diskusiUserId,
            targetNama: diskusiPenulis,
            pengirimId: senderUserId,
            pengirimNama: senderPenulis,
            pengirimUsername: senderUsername,
            tipe: 'balas',
            diskusiId: jawaban.diskusiId,
            jawabanId: jawabanId,
            indukJawabanId: null,
            judulDiskusi: judulDiskusi,
            cuplikanTeks: jawaban.isi,
            dibuatPada: kini,
          );
        }
      }

      // 2. notifikasi tag / mention
      final mentionRegex = RegExp(r'@([a-zA-Z0-9_.-]+)');
      final matches = mentionRegex.allMatches(jawaban.isi);
      final mentionSet = <String>{};
      for (final m in matches) {
        final tag = m.group(1);
        if (tag != null && tag.isNotEmpty) {
          mentionSet.add(tag.toLowerCase());
        }
      }

      for (final tagUser in mentionSet) {
        if (tagUser == senderUsername.toLowerCase() ||
            tagUser == senderPenulis.toLowerCase()) {
          continue;
        }

        final targetRows = await db.query(
          'user',
          columns: ['id', 'nama', 'username'],
          where: 'LOWER(username) = ? OR LOWER(nama) = ?',
          whereArgs: [tagUser, tagUser],
          limit: 1,
        );

        if (targetRows.isNotEmpty) {
          final tId = targetRows.first['id'] as int? ?? 0;
          final tNama = targetRows.first['nama'] as String? ?? tagUser;
          final tUser = targetRows.first['username'] as String? ?? tagUser;

          await _sisipkanNotifikasi(
            db,
            userId: tId,
            targetNama: tNama,
            targetUsername: tUser,
            pengirimId: senderUserId,
            pengirimNama: senderPenulis,
            pengirimUsername: senderUsername,
            tipe: 'tag',
            diskusiId: jawaban.diskusiId,
            jawabanId: jawabanId,
            indukJawabanId: jawaban.indukId,
            judulDiskusi: judulDiskusi,
            cuplikanTeks: jawaban.isi,
            dibuatPada: kini,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _sisipkanNotifikasi(
    Database db, {
    required int userId,
    required String targetNama,
    String? targetUsername,
    int? pengirimId,
    required String pengirimNama,
    required String pengirimUsername,
    required String tipe,
    required int diskusiId,
    int? jawabanId,
    int? indukJawabanId,
    required String judulDiskusi,
    required String cuplikanTeks,
    required int dibuatPada,
  }) async {
    final tUsername = targetUsername ??
        targetNama.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    await db.insert('notifikasi_komunitas', {
      'userId': userId,
      'userNama': targetNama,
      'userUsername': tUsername,
      'pengirimId': pengirimId,
      'pengirimNama': pengirimNama,
      'pengirimUsername': pengirimUsername,
      'tipe': tipe,
      'diskusiId': diskusiId,
      'jawabanId': jawabanId,
      'indukJawabanId': indukJawabanId,
      'judulDiskusi': judulDiskusi,
      'cuplikanTeks': cuplikanTeks,
      'sudahDibaca': 0,
      'dibuatPada': dibuatPada,
    });
  }

  // cek waktu diskusi terakhir
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
    final raw = rows.first['dibuatPada'];
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    } else if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  // hapus jawaban dan anak balasannya
  Future<int> hapusJawaban(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'suara',
      where: 'targetTipe = ? AND targetId = ?',
      whereArgs: ['jawaban', id],
    );
    // hapus semua balasan anak
    await db.delete('jawaban', where: 'indukId = ?', whereArgs: [id]);
    return await db.delete('jawaban', where: 'id = ?', whereArgs: [id]);
  }

  // cek jawaban terakhir user
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

  // toggle suara
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
      await db.delete(
        'suara',
        where: 'targetTipe = ? AND targetId = ? AND userId = ?',
        whereArgs: [targetTipe, targetId, pemilik],
      );
    } else {
      await db.insert('suara', {
        'targetTipe': targetTipe,
        'targetId': targetId,
        'userId': pemilik,
        'nilai': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // cari pengguna untuk mention
  Future<List<Map<String, String>>> cariPenggunaTag({
    String kataKunci = '',
    List<String> namaPrioritas = const [],
  }) async {
    final db = await _dbHelper.database;
    final hasil = <Map<String, String>>[];
    final usernamesTerdaftar = <String>{};

    // dari tabel user
    try {
      final users = await db.query(
        'user',
        columns: ['nama', 'username', 'role'],
        where: kataKunci.isNotEmpty
            ? 'username LIKE ? OR nama LIKE ?'
            : null,
        whereArgs: kataKunci.isNotEmpty
            ? ['%$kataKunci%', '%$kataKunci%']
            : null,
        limit: 20,
      );

      for (final u in users) {
        final nama = (u['nama'] as String?)?.trim() ?? '';
        final rawUser = (u['username'] as String?)?.trim();
        final username = (rawUser != null && rawUser.isNotEmpty)
            ? rawUser
            : nama.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

        if (username.isNotEmpty &&
            !usernamesTerdaftar.contains(username.toLowerCase())) {
          usernamesTerdaftar.add(username.toLowerCase());
          hasil.add({
            'nama': nama.isNotEmpty ? nama : username,
            'username': username,
            'role': u['role'] as String? ?? 'user',
          });
        }
      }
    } catch (_) {}

    // nama prioritas dari diskusi atau thread
    for (final nama in namaPrioritas) {
      final n = nama.trim();
      final uSlug = n.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      if (uSlug.isNotEmpty && !usernamesTerdaftar.contains(uSlug)) {
        if (kataKunci.isEmpty ||
            uSlug.contains(kataKunci.toLowerCase()) ||
            n.toLowerCase().contains(kataKunci.toLowerCase())) {
          usernamesTerdaftar.add(uSlug);
          hasil.add({
            'nama': n,
            'username': uSlug,
            'role': isAdminAccountName(n) || isAdminAccountName(uSlug)
                ? 'admin'
                : 'user',
          });
        }
      }
    }

    return hasil;
  }

  // ambil seluruh daftar nama dan username pengguna untuk regex mention
  Future<List<String>> getSemuaNamaPengguna() async {
    final db = await _dbHelper.database;
    final hasil = <String>{};
    try {
      final users = await db.query('user', columns: ['nama', 'username']);
      for (final u in users) {
        final n = (u['nama'] as String?)?.trim();
        final un = (u['username'] as String?)?.trim();
        if (n != null && n.isNotEmpty) hasil.add(n);
        if (un != null && un.isNotEmpty) hasil.add(un);
      }
      final disk = await db.query('diskusi', columns: ['penulis']);
      for (final d in disk) {
        final p = (d['penulis'] as String?)?.trim();
        if (p != null && p.isNotEmpty) hasil.add(p);
      }
      final jwb = await db.query('jawaban', columns: ['penulis']);
      for (final j in jwb) {
        final p = (j['penulis'] as String?)?.trim();
        if (p != null && p.isNotEmpty) hasil.add(p);
      }
    } catch (_) {}
    return hasil.toList();
  }

  // ambil daftar notifikasi komunitas
  Future<List<NotifikasiKomunitasModel>> getDaftarNotifikasi({
    required String targetIdentifier,
    int? targetUserId,
    String? filterTipe,
    bool hanyaBelumDibaca = false,
  }) async {
    final db = await _dbHelper.database;
    final bersih = targetIdentifier.trim().toLowerCase();

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (targetUserId != null && targetUserId > 0) {
      whereClauses.add(
        '(userId = ? OR LOWER(userUsername) = ? OR LOWER(userNama) = ?)',
      );
      whereArgs.addAll([targetUserId, bersih, bersih]);
    } else {
      whereClauses.add('(LOWER(userUsername) = ? OR LOWER(userNama) = ?)');
      whereArgs.addAll([bersih, bersih]);
    }

    if (filterTipe != null &&
        filterTipe.isNotEmpty &&
        filterTipe.toLowerCase() != 'semua') {
      whereClauses.add('tipe = ?');
      whereArgs.add(filterTipe.toLowerCase());
    }

    if (hanyaBelumDibaca) {
      whereClauses.add('sudahDibaca = 0');
    }

    final rows = await db.query(
      'notifikasi_komunitas',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'dibuatPada DESC',
      limit: 100,
    );

    return rows.map((r) => NotifikasiKomunitasModel.fromMap(r)).toList();
  }

  // hitung jumlah notifikasi belum dibaca
  Future<int> getJumlahNotifikasiBelumDibaca({
    required String targetIdentifier,
    int? targetUserId,
  }) async {
    final db = await _dbHelper.database;
    final bersih = targetIdentifier.trim().toLowerCase();

    String whereSql;
    List<dynamic> whereArgs;

    if (targetUserId != null && targetUserId > 0) {
      whereSql =
          '(userId = ? OR LOWER(userUsername) = ? OR LOWER(userNama) = ?) AND sudahDibaca = 0';
      whereArgs = [targetUserId, bersih, bersih];
    } else {
      whereSql =
          '(LOWER(userUsername) = ? OR LOWER(userNama) = ?) AND sudahDibaca = 0';
      whereArgs = [bersih, bersih];
    }

    final res = await db.rawQuery(
      'SELECT COUNT(*) as total FROM notifikasi_komunitas WHERE $whereSql',
      whereArgs,
    );
    return (res.first['total'] as num?)?.toInt() ?? 0;
  }

  // tandai satu notifikasi telah dibaca
  Future<void> tandaiNotifikasiDibaca(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'notifikasi_komunitas',
      {'sudahDibaca': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // tandai semua notifikasi telah dibaca
  Future<void> tandaiSemuaNotifikasiDibaca({
    required String targetIdentifier,
    int? targetUserId,
  }) async {
    final db = await _dbHelper.database;
    final bersih = targetIdentifier.trim().toLowerCase();

    String whereSql;
    List<dynamic> whereArgs;

    if (targetUserId != null && targetUserId > 0) {
      whereSql =
          '(userId = ? OR LOWER(userUsername) = ? OR LOWER(userNama) = ?)';
      whereArgs = [targetUserId, bersih, bersih];
    } else {
      whereSql = '(LOWER(userUsername) = ? OR LOWER(userNama) = ?)';
      whereArgs = [bersih, bersih];
    }

    await db.update(
      'notifikasi_komunitas',
      {'sudahDibaca': 1},
      where: whereSql,
      whereArgs: whereArgs,
    );
  }

  // hapus notifikasi
  Future<void> hapusNotifikasi(int id) async {
    final db = await _dbHelper.database;
    await db.delete('notifikasi_komunitas', where: 'id = ?', whereArgs: [id]);
  }
}


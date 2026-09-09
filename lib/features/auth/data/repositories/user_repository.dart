import '../../../../data/local/db_helper.dart';
import '../models/user_model.dart';

// Hasil penyuntingan profil: berhasil, atau gagal beserta alasannya.
class HasilSuntingProfil {
  final UserSQLModel? user;
  final String? galat;

  const HasilSuntingProfil.berhasil(this.user) : galat = null;
  const HasilSuntingProfil.gagal(this.galat) : user = null;

  bool get sukses => user != null;
}

class UserRepository {
  final DbHelper _dbHelper;

  UserRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  Future<bool> userRegister(UserSQLModel user) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert('user', user.toMap());
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  Future<UserSQLModel?> loginUser(String email, String password) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      return UserSQLModel.fromMap(results.first);
    }
    return null;
  }

  Future<UserSQLModel?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserSQLModel.fromMap(results.first);
  }

  Future<UserSQLModel?> getUserById(int id) async {
    if (id <= 0) return null;
    final db = await _dbHelper.database;
    final results = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserSQLModel.fromMap(results.first);
  }

  // Username dan email harus unik tanpa membedakan huruf besar-kecil.
  // [kecualiId] diisi saat menyunting, agar akun tidak bentrok dengan dirinya.
  Future<bool> _sudahDipakai(
    String kolom,
    String nilai, {
    int? kecualiId,
  }) async {
    final bersih = nilai.trim();
    if (bersih.isEmpty) return false;

    final db = await _dbHelper.database;
    final hasil = await db.query(
      'user',
      columns: ['id'],
      where: kecualiId == null
          ? '$kolom = ? COLLATE NOCASE'
          : '$kolom = ? COLLATE NOCASE AND id <> ?',
      whereArgs: kecualiId == null ? [bersih] : [bersih, kecualiId],
      limit: 1,
    );
    return hasil.isNotEmpty;
  }

  Future<bool> usernameDipakai(String nama, {int? kecualiId}) =>
      _sudahDipakai('nama', nama, kecualiId: kecualiId);

  Future<bool> emailDipakai(String email, {int? kecualiId}) =>
      _sudahDipakai('email', email, kecualiId: kecualiId);

  // [path] null berarti foto dilepas dan kembali ke placeholder inisial.
  Future<int> perbaruiFotoProfil(String email, String? path) async {
    final db = await _dbHelper.database;
    return await db.update(
      'user',
      {'fotoProfil': path},
      where: 'email = ?',
      whereArgs: [email.trim()],
    );
  }

  // Menyunting profil berdasarkan id. Data milik akun disimpan dengan kunci
  // id, jadi mengganti username maupun email tidak memutus capaian apa pun.
  Future<HasilSuntingProfil> perbaruiProfil({
    required int id,
    required String nama,
    required String email,
    required String noHp,
    String? fotoProfil,
    bool hapusFoto = false,
  }) async {
    if (id <= 0) return const HasilSuntingProfil.gagal('Sesi tidak ditemukan.');

    final namaBersih = nama.trim();
    final emailBersih = email.trim();
    if (namaBersih.isEmpty) {
      return const HasilSuntingProfil.gagal('Username tidak boleh kosong.');
    }
    if (emailBersih.isEmpty) {
      return const HasilSuntingProfil.gagal('Email tidak boleh kosong.');
    }

    if (await usernameDipakai(namaBersih, kecualiId: id)) {
      return const HasilSuntingProfil.gagal(
        'Username itu sudah dipakai akun lain.',
      );
    }
    if (await emailDipakai(emailBersih, kecualiId: id)) {
      return const HasilSuntingProfil.gagal(
        'Email itu sudah terdaftar pada akun lain.',
      );
    }

    final db = await _dbHelper.database;
    try {
      await db.update(
        'user',
        {
          'nama': namaBersih,
          'email': emailBersih,
          'noHp': noHp.trim(),
          if (hapusFoto || fotoProfil != null) 'fotoProfil': fotoProfil,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {
      return const HasilSuntingProfil.gagal('Gagal menyimpan perubahan.');
    }

    final terbaru = await getUserById(id);
    if (terbaru == null) {
      return const HasilSuntingProfil.gagal('Akun tidak ditemukan lagi.');
    }
    return HasilSuntingProfil.berhasil(terbaru);
  }
}

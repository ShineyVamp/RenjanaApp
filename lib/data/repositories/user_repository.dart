import '../local/db_helper.dart';
import '../models/user_model.dart';

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
}

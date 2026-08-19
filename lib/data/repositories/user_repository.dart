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

  Future<List<UserSQLModel>> getAllUsers() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query('user');
    return results.map((map) => UserSQLModel.fromMap(map)).toList();
  }

  Future<bool> updateUser(UserSQLModel user) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'user',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete('user', where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}

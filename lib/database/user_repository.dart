import 'package:renjana/database/db_helper.dart';
import 'package:renjana/models/user_model.dart';

class UserRepository {
  Future<bool> userRegister(UserSQLModel pengguna) async {
    final db = await DbHelper().database;

    try {
      await db.insert('user', pengguna.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserSQLModel?> loginUser(String email, String password) async {
    final db = await DbHelper().database;

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

  Future<List<UserSQLModel>> getAllUser() async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> results = await db.query('user');
    return results.map((map) => UserSQLModel.fromMap(map)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await DbHelper().database;
    await db.delete('user', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> updateUser(UserSQLModel pengguna) async {
    final db = await DbHelper().database;

    try {
      int count = await db.update(
        'user',
        pengguna.toMap(),
        where: 'id = ?',
        whereArgs: [pengguna.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}

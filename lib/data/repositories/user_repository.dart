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
}

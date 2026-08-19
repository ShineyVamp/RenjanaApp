import '../local/db_helper.dart';
import '../models/content_model.dart';

class ContentRepository {
  final DbHelper _dbHelper;

  ContentRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  Future<bool> tambahContent(ContentSQLModel content) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert('content', content.toMap());
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<ContentSQLModel>> getAllContents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'content',
      orderBy: 'id DESC',
    );
    return results.map((map) => ContentSQLModel.fromMap(map)).toList();
  }

  Future<List<ContentSQLModel>> getContentsByType(String tipe) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'content',
      where: 'tipe = ?',
      whereArgs: [tipe],
      orderBy: 'id DESC',
    );
    return results.map((map) => ContentSQLModel.fromMap(map)).toList();
  }

  Future<bool> updateContent(ContentSQLModel content) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'content',
        content.toMap(),
        where: 'id = ?',
        whereArgs: [content.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteContent(int id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'content',
        where: 'id = ?',
        whereArgs: [id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}

import '../local/db_helper.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final DbHelper _dbHelper;

  QuizRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  Future<bool> tambahQuiz(QuizSQLModel quiz) async {
    final db = await _dbHelper.database;
    try {
      final id = await db.insert('quiz', quiz.toMap());
      return id > 0;
    } catch (e) {
      return false;
    }
  }

  Future<List<QuizSQLModel>> getAllQuizzes() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'quiz',
      orderBy: 'id DESC',
    );
    return results.map((map) => QuizSQLModel.fromMap(map)).toList();
  }

  Future<List<QuizSQLModel>> getQuizByKategori(String kategori) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'quiz',
      where: 'kategori = ?',
      whereArgs: [kategori],
      orderBy: 'id DESC',
    );
    return results.map((map) => QuizSQLModel.fromMap(map)).toList();
  }

  Future<List<QuizSQLModel>> getQuizByTema(String tema) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'quiz',
      where: 'tema = ?',
      whereArgs: [tema],
      orderBy: 'id DESC',
    );
    return results.map((map) => QuizSQLModel.fromMap(map)).toList();
  }

  Future<bool> updateQuiz(QuizSQLModel quiz) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.update(
        'quiz',
        quiz.toMap(),
        where: 'id = ?',
        whereArgs: [quiz.id],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteQuiz(int id) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete('quiz', where: 'id = ?', whereArgs: [id]);
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}

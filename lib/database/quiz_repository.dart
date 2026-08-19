import 'package:renjana/database/db_helper.dart';
import 'package:renjana/models/quiz_model.dart';

class QuizRepository {
  Future<bool> tambahQuiz(QuizSQLModel quiz) async {
    final db = await DbHelper().database;

    try {
      await db.insert('quiz', quiz.toMap());
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<List<QuizSQLModel>> getQuizKategori(String kategori) async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> hasil = await db.query(
      'quiz',
      where: 'kategori = ?',
      whereArgs: [kategori],
    );
    return hasil.map((map) => QuizSQLModel.fromMap(map)).toList();
  }

  Future<bool> updateQuiz(QuizSQLModel quiz) async {
    final db = await DbHelper().database;

    try {
      await db.update(
        'quiz',
        quiz.toMap(),
        where: 'id = ?',
        whereArgs: [quiz.id],
      );
    } catch (e) {
      return false;
    }
    return false;
  }

  Future<List<QuizSQLModel>> getQuizTema(String tema) async {
    final db = await DbHelper().database;
    final List<Map<String, dynamic>> hasil = await db.query(
      'quiz',
      where: 'tema = ?',
      whereArgs: [tema],
    );
    return hasil.map((map) => QuizSQLModel.fromMap(map)).toList();
  }
}

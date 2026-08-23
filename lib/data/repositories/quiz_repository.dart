import 'package:sqflite/sqflite.dart';

import '../local/db_helper.dart';
import '../models/quiz_model.dart';
import 'pemilik_akun.dart';

class QuizRepository {
  final DbHelper _dbHelper;

  QuizRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  int get _pemilik => idAkunAktif;

  Future<void> catatSoalSalah(int quizId) async {
    final pemilik = _pemilik;
    if (pemilik <= 0 || quizId <= 0) return;

    final db = await _dbHelper.database;
    try {
      await db.insert('soal_salah', {
        'userId': pemilik,
        'quizId': quizId,
        'tanggal': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (_) {}
  }

  Future<void> hapusSoalSalah(int quizId) async {
    final pemilik = _pemilik;
    if (pemilik <= 0 || quizId <= 0) return;

    final db = await _dbHelper.database;
    try {
      await db.delete(
        'soal_salah',
        where: 'userId = ? AND quizId = ?',
        whereArgs: [pemilik, quizId],
      );
    } catch (_) {}
  }

  Future<int> getJumlahSoalSalah() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final db = await _dbHelper.database;
    try {
      final res = await db.rawQuery(
        'SELECT COUNT(*) as total FROM soal_salah WHERE userId = ?',
        [pemilik],
      );
      if (res.isNotEmpty && res.first['total'] != null) {
        return (res.first['total'] as num).toInt();
      }
    } catch (_) {}
    return 0;
  }

  Future<List<QuizSQLModel>> getSoalSalahList() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const [];

    final db = await _dbHelper.database;
    try {
      final List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT q.* FROM quiz q INNER JOIN soal_salah s ON q.id = s.quizId '
        'WHERE s.userId = ? ORDER BY s.tanggal DESC',
        [pemilik],
      );
      return results.map((map) => QuizSQLModel.fromMap(map)).toList();
    } catch (_) {
      return const [];
    }
  }

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

  Future<List<QuizSQLModel>> getQuizByKategori(String kategori) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'quiz',
      where: 'UPPER(kategori) = ?',
      whereArgs: [kategori.toUpperCase()],
      orderBy: 'id DESC',
    );
    return results.map((map) => QuizSQLModel.fromMap(map)).toList();
  }

  Future<List<QuizSQLModel>> getRandomQuizzesByCategory(
    String kategori,
    int limit,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      'quiz',
      where: 'UPPER(kategori) = ?',
      whereArgs: [kategori.toUpperCase()],
      orderBy: 'RANDOM()',
      limit: limit,
    );
    return results.map((map) => QuizSQLModel.fromMap(map)).toList();
  }

  Future<int> getQuizCountByKategori(String kategori) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM quiz WHERE UPPER(kategori) = ?',
      [kategori.toUpperCase()],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toInt();
    }
    return 0;
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

  Future<bool> deleteQuizzesByTema(String tema) async {
    final db = await _dbHelper.database;
    try {
      final count = await db.delete(
        'quiz',
        where: 'tema = ?',
        whereArgs: [tema],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateThemeInfo({
    required String oldTema,
    required String newTema,
    required String newKategori,
    required String newSubKategori,
    String? newCoverImage,
  }) async {
    final db = await _dbHelper.database;
    try {
      final Map<String, dynamic> values = {
        'tema': newTema,
        'kategori': newKategori,
        'subKategori': newSubKategori,
      };
      if (newCoverImage != null) {
        values['gambar'] = newCoverImage;
      }
      final count = await db.update(
        'quiz',
        values,
        where: 'tema = ?',
        whereArgs: [oldTema],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import '../../../../data/local/seed/quiz_seed.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final FirebaseFirestore _firestore;

  static List<QuizSQLModel>? _cachedQuizzes;
  static Set<int>? _cachedSoalSalah;
  static String? _cachedUser;

  QuizRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // section identitas pengguna
  String get _userUid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final fUser = FirebaseAuth.instance.currentUser;
    if (fUser != null && fUser.uid.isNotEmpty) return fUser.uid;
    final intId = idAkunAktif;
    if (intId > 0) return 'user_$intId';
    return 'guest';
  }

  // section koleksi soal salah
  CollectionReference<Map<String, dynamic>> _koleksiSoalSalah() {
    return _firestore
        .collection('users')
        .doc(_userUid)
        .collection('soal_salah');
  }

  // section catat soal salah
  Future<void> catatSoalSalah(int quizId) async {
    final uid = _userUid;
    if (uid == 'guest' || quizId <= 0) return;

    if (_cachedUser == uid) {
      _cachedSoalSalah?.add(quizId);
    }

    try {
      await _koleksiSoalSalah().doc(quizId.toString()).set({
        'quizId': quizId,
        'tanggal': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  // section hapus soal salah
  Future<void> hapusSoalSalah(int quizId) async {
    final uid = _userUid;
    if (uid == 'guest' || quizId <= 0) return;

    if (_cachedUser == uid) {
      _cachedSoalSalah?.remove(quizId);
    }

    try {
      await _koleksiSoalSalah().doc(quizId.toString()).delete();
    } catch (_) {}
  }

  // section jumlah soal salah
  Future<int> getJumlahSoalSalah() async {
    final list = await _ambilSoalSalahIds();
    return list.length;
  }

  // section ambil id soal salah
  Future<Set<int>> _ambilSoalSalahIds() async {
    final uid = _userUid;
    if (uid == 'guest') return const {};

    if (_cachedSoalSalah != null && _cachedUser == uid) {
      return _cachedSoalSalah!;
    }

    try {
      final snap = await _koleksiSoalSalah().get();
      final ids = <int>{};
      for (final doc in snap.docs) {
        final qid = (doc.data()['quizId'] as num?)?.toInt() ?? int.tryParse(doc.id);
        if (qid != null && qid > 0) ids.add(qid);
      }
      _cachedSoalSalah = ids;
      _cachedUser = uid;
      return ids;
    } catch (_) {
      return _cachedSoalSalah ?? const {};
    }
  }

  // section daftar soal salah
  Future<List<QuizSQLModel>> getSoalSalahList() async {
    final ids = await _ambilSoalSalahIds();
    if (ids.isEmpty) return const [];

    final semua = await getAllQuizzes();
    return semua.where((q) => q.id != null && ids.contains(q.id)).toList();
  }

  // section tambah kuis
  Future<bool> tambahQuiz(QuizSQLModel quiz) async {
    try {
      final ref = _firestore.collection('quiz').doc();
      final idBaru = quiz.id ?? ref.id.hashCode.abs();
      quiz.id = idBaru;
      await ref.set(quiz.toFirestore()..['id'] = idBaru);
      _cachedQuizzes?.insert(0, quiz);
      return true;
    } catch (_) {
      return false;
    }
  }

  // section ambil semua kuis
  Future<List<QuizSQLModel>> getAllQuizzes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedQuizzes != null && _cachedQuizzes!.isNotEmpty) {
      return _cachedQuizzes!;
    }

    try {
      final snap = await _firestore.collection('quiz').get();
      if (snap.docs.isNotEmpty) {
        final list = snap.docs.map((doc) {
          final data = doc.data();
          if (data['id'] == null) {
            data['id'] = int.tryParse(doc.id) ?? doc.id.hashCode.abs();
          }
          return QuizSQLModel.fromMap(data);
        }).toList();
        list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
        _cachedQuizzes = list;
        return list;
      }
    } catch (_) {}

    _cachedQuizzes = List<QuizSQLModel>.from(defaultQuizList);
    return _cachedQuizzes!;
  }

  // ambil kuis berdasarkan tema
  Future<List<QuizSQLModel>> getQuizByTema(String tema) async {
    final semua = await getAllQuizzes();
    return semua.where((q) => q.tema == tema).toList();
  }

  // ambil kuis berdasarkan kategori
  Future<List<QuizSQLModel>> getQuizByKategori(String kategori) async {
    final semua = await getAllQuizzes();
    return semua
        .where((q) => q.kategori.toUpperCase() == kategori.toUpperCase())
        .toList();
  }

  // ambil kuis acak per kategori
  Future<List<QuizSQLModel>> getRandomQuizzesByCategory(
    String kategori,
    int limit,
  ) async {
    final list = await getQuizByKategori(kategori);
    final acak = List<QuizSQLModel>.from(list)..shuffle();
    return acak.take(limit).toList();
  }

  // jumlah kuis per kategori
  Future<int> getQuizCountByKategori(String kategori) async {
    final list = await getQuizByKategori(kategori);
    return list.length;
  }

  // perbarui kuis
  Future<bool> updateQuiz(QuizSQLModel quiz) async {
    try {
      if (quiz.id != null) {
        await _firestore
            .collection('quiz')
            .doc(quiz.id.toString())
            .set(quiz.toMap(), SetOptions(merge: true));

        if (_cachedQuizzes != null) {
          final idx = _cachedQuizzes!.indexWhere((q) => q.id == quiz.id);
          if (idx != -1) _cachedQuizzes![idx] = quiz;
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // hapus kuis
  Future<bool> deleteQuiz(int id) async {
    try {
      await _firestore.collection('quiz').doc(id.toString()).delete();
      _cachedQuizzes?.removeWhere((q) => q.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // hapus kuis berdasarkan tema
  Future<bool> deleteQuizzesByTema(String tema) async {
    try {
      final snap = await _firestore
          .collection('quiz')
          .where('tema', isEqualTo: tema)
          .get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _cachedQuizzes?.removeWhere((q) => q.tema == tema);
      return true;
    } catch (_) {
      return false;
    }
  }

  // perbarui info tema
  Future<bool> updateThemeInfo({
    required String oldTema,
    required String newTema,
    required String newKategori,
    required String newSubKategori,
    String? newCoverImage,
  }) async {
    try {
      final snap = await _firestore
          .collection('quiz')
          .where('tema', isEqualTo: oldTema)
          .get();
      final batch = _firestore.batch();
      final Map<String, dynamic> values = {
        'tema': newTema,
        'kategori': newKategori,
        'subKategori': newSubKategori,
      };
      if (newCoverImage != null) {
        values['gambar'] = newCoverImage;
      }
      for (final doc in snap.docs) {
        batch.update(doc.reference, values);
      }
      await batch.commit();

      if (_cachedQuizzes != null) {
        for (var i = 0; i < _cachedQuizzes!.length; i++) {
          final q = _cachedQuizzes![i];
          if (q.tema == oldTema) {
            _cachedQuizzes![i] = QuizSQLModel(
              id: q.id,
              kategori: newKategori,
              subKategori: newSubKategori,
              tema: newTema,
              soal: q.soal,
              daftarJawaban: q.daftarJawaban,
              jawabanBenar: q.jawabanBenar,
              gambar: newCoverImage ?? q.gambar,
              penjelasan: q.penjelasan,
            );
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // bersihkan cache
  static void bersihkanCache() {
    _cachedQuizzes = null;
    _cachedSoalSalah = null;
    _cachedUser = null;
  }
}

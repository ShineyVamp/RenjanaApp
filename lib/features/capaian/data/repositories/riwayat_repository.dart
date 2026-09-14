import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';

class RiwayatRepository {
  final FirebaseFirestore _firestore;

  static List<String>? _cachedPencarian;
  static List<String>? _cachedDibuka;
  static String? _cachedUser;

  RiwayatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  static const String jenisPencarian = 'pencarian';
  static const String jenisArsip = 'arsip';

  static const int batasPencarian = 8;
  static const int batasDibuka = 6;

  static const int _simpanMaksPencarian = 30;
  static const int _simpanMaksArsip = 100;

  // identitas pengguna
  String get _userUid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final fUser = FirebaseAuth.instance.currentUser;
    if (fUser != null && fUser.uid.isNotEmpty) return fUser.uid;
    final intId = idAkunAktif;
    if (intId > 0) return 'user_$intId';
    return 'guest';
  }

  // koleksi riwayat
  CollectionReference<Map<String, dynamic>> _koleksi() {
    return _firestore.collection('users').doc(_userUid).collection('riwayat');
  }

  // ambil riwayat
  Future<List<String>> _ambil(String jenis, int? batas) async {
    final uid = _userUid;
    if (uid == 'guest') return const [];

    if (_cachedUser == uid) {
      if (jenis == jenisPencarian && _cachedPencarian != null) {
        return batas != null && _cachedPencarian!.length > batas
            ? _cachedPencarian!.sublist(0, batas)
            : _cachedPencarian!;
      }
      if (jenis == jenisArsip && _cachedDibuka != null) {
        return batas != null && _cachedDibuka!.length > batas
            ? _cachedDibuka!.sublist(0, batas)
            : _cachedDibuka!;
      }
    }

    try {
      final snapshot = await _koleksi()
          .where('jenis', isEqualTo: jenis)
          .get()
          .timeout(const Duration(seconds: 10));

      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final waktuA = (a.data()['dicatatPada'] as num?)?.toInt() ?? 0;
        final waktuB = (b.data()['dicatatPada'] as num?)?.toInt() ?? 0;
        return waktuB.compareTo(waktuA);
      });

      final maxSimpan = jenis == jenisPencarian
          ? _simpanMaksPencarian
          : _simpanMaksArsip;
      final docsLimited = docs.length > maxSimpan
          ? docs.sublist(0, maxSimpan)
          : docs;

      final list = docsLimited
          .map((d) => d.data()['nilai'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList();

      _cachedUser = uid;
      if (jenis == jenisPencarian) {
        _cachedPencarian = list;
      } else {
        _cachedDibuka = list;
      }

      return batas != null && list.length > batas
          ? list.sublist(0, batas)
          : list;
    } catch (_) {
      if (_cachedUser != uid) return const [];
      final fallback = jenis == jenisPencarian
          ? _cachedPencarian
          : _cachedDibuka;
      return fallback ?? const [];
    }
  }

  // catat riwayat
  Future<void> _catat(String jenis, String nilai) async {
    final uid = _userUid;
    final bersih = nilai.trim();
    if (uid == 'guest' || bersih.isEmpty) return;

    // update cache
    if (_cachedUser != uid) {
      _cachedPencarian = null;
      _cachedDibuka = null;
      _cachedUser = uid;
    }
    final targetCache = jenis == jenisPencarian
        ? (_cachedPencarian ??= [])
        : (_cachedDibuka ??= []);
    targetCache.removeWhere(
      (item) => item.toLowerCase() == bersih.toLowerCase(),
    );
    targetCache.insert(0, bersih);
    final maxSimpan = jenis == jenisPencarian
        ? _simpanMaksPencarian
        : _simpanMaksArsip;
    if (targetCache.length > maxSimpan) {
      targetCache.removeRange(maxSimpan, targetCache.length);
    }

    // simpan ke firestore
    try {
      final docId =
          '${jenis}_${bersih.replaceAll('/', '_').replaceAll('|', '_').replaceAll(' ', '_')}';
      await _koleksi().doc(docId).set({
        'jenis': jenis,
        'nilai': bersih,
        'dicatatPada': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (_) {}
  }

  // hapus riwayat
  Future<void> _hapus(String jenis) async {
    final uid = _userUid;
    if (uid == 'guest') return;

    if (jenis == jenisPencarian) {
      _cachedPencarian = [];
    } else {
      _cachedDibuka = [];
    }

    try {
      final snapshot = await _koleksi().where('jenis', isEqualTo: jenis).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {}
  }

  // riwayat pencarian
  Future<List<String>> pencarian({int? batas}) => _ambil(jenisPencarian, batas);
  Future<void> catatPencarian(String kataKunci) =>
      _catat(jenisPencarian, kataKunci);
  Future<void> hapusPencarian() => _hapus(jenisPencarian);

  // arsip dibuka
  Future<List<String>> dibuka({int? batas}) => _ambil(jenisArsip, batas);
  Future<void> catatDibuka(String jenisArsipItem, String kodeTag) =>
      _catat(jenisArsip, '$jenisArsipItem|${kodeTag.trim()}');
  Future<void> hapusDibuka() => _hapus(jenisArsip);

  // jumlah dibuka hari ini
  Future<int> jumlahDibukaHariIni() async {
    final uid = _userUid;
    if (uid == 'guest') return 0;

    final sekarang = DateTime.now();
    final awalHari = DateTime(
      sekarang.year,
      sekarang.month,
      sekarang.day,
    ).millisecondsSinceEpoch;

    try {
      final snapshot = await _koleksi()
          .where('jenis', isEqualTo: jenisArsip)
          .where('dicatatPada', isGreaterThanOrEqualTo: awalHari)
          .get();
      return snapshot.docs.length;
    } catch (_) {
      return 0;
    }
  }

  // bersihkan cache
  static void bersihkanCache() {
    _cachedPencarian = null;
    _cachedDibuka = null;
    _cachedUser = null;
  }
}

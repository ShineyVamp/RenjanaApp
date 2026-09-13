import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import 'riwayat_repository.dart';

class ArsipDibacaRepository {
  final FirebaseFirestore _firestore;
  final RiwayatRepository _riwayatRepository;

  static Set<String>? _cachedRefs;
  static String? _cachedUser;

  ArsipDibacaRepository({
    FirebaseFirestore? firestore,
    RiwayatRepository? riwayatRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _riwayatRepository = riwayatRepository ?? RiwayatRepository();

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

  static String buatRef(String jenis, String kodeTag) =>
      '$jenis|${kodeTag.trim()}';

  // koleksi arsip dibaca
  CollectionReference<Map<String, dynamic>> _koleksi() {
    return _firestore
        .collection('users')
        .doc(_userUid)
        .collection('arsip_dibaca');
  }

  // catat arsip dibaca
  Future<void> catat(String jenis, String kodeTag) async {
    final uid = _userUid;
    final ref = buatRef(jenis, kodeTag);
    if (uid == 'guest' || kodeTag.trim().isEmpty) return;

    final docId = ref.replaceAll('/', '_').replaceAll('|', '_');
    try {
      await _koleksi().doc(docId).set({
        'ref': ref,
        'jenis': jenis,
        'kodeTag': kodeTag.trim(),
        'dibacaPada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _cachedRefs?.add(ref);
    } catch (_) {}

    await _riwayatRepository.catatDibuka(jenis, kodeTag);
  }

  // ambil semua arsip dibaca
  Future<List<String>> semua() async {
    final uid = _userUid;
    if (uid == 'guest') return const [];

    if (_cachedRefs != null && _cachedUser == uid) {
      return _cachedRefs!.toList();
    }

    try {
      final snapshot = await _koleksi()
          .orderBy('dibacaPada', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      final list = snapshot.docs
          .map((doc) => doc.data()['ref'] as String? ?? '')
          .where((r) => r.isNotEmpty)
          .toList();

      _cachedRefs = list.toSet();
      _cachedUser = uid;
      return list;
    } catch (_) {
      if (_cachedUser != uid) return const [];
      return _cachedRefs?.toList() ?? const [];
    }
  }

  // himpunan arsip dibaca
  Future<Set<String>> himpunan() async => (await semua()).toSet();

  // cek status sudah dibaca
  Future<bool> sudahDibaca(String jenis, String kodeTag) async {
    final set = await himpunan();
    return set.contains(buatRef(jenis, kodeTag));
  }

  // jumlah arsip dibaca
  Future<int> jumlah() async => (await semua()).length;

  // bersihkan cache
  static void bersihkanCache() {
    _cachedRefs = null;
    _cachedUser = null;
  }
}

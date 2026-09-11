import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/storage/preference_handler.dart';
import '../models/hasil_kuis_model.dart';

// rekapitulasi seluruh percobaan kuis satu akun
class RingkasanKuis {
  final int percobaan;
  final int totalSoal;
  final int totalBenar;
  final int temaSempurna;

  const RingkasanKuis({
    this.percobaan = 0,
    this.totalSoal = 0,
    this.totalBenar = 0,
    this.temaSempurna = 0,
  });

  int get persen =>
      totalSoal == 0 ? 0 : ((totalBenar * 100) / totalSoal).round();
}

class HasilKuisRepository {
  final FirebaseFirestore _firestore;

  static RingkasanKuis? _cacheRingkasan;
  static Map<String, HasilKuis>? _cacheRekor;
  static List<HasilKuis>? _cacheRiwayat;

  HasilKuisRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String get _uid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final user = PreferenceHandler.user;
    if (user?.uid != null && user!.uid!.isNotEmpty) return user.uid!;
    final id = PreferenceHandler.userId;
    if (id > 0) return 'user_$id';
    return 'guest';
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _riwayatCol =>
      _userDoc.collection('kuis_riwayat');

  CollectionReference<Map<String, dynamic>> get _rekorCol =>
      _userDoc.collection('kuis_rekor');

  static void bersihkanCache() {
    _cacheRingkasan = null;
    _cacheRekor = null;
    _cacheRiwayat = null;
  }

  // simpan hasil kuis
  Future<void> simpan(HasilKuis hasil) async {
    if (hasil.jumlahSoal <= 0) return;

    final data = hasil.toKolom(0)..remove('userId');
    data['selesaiPada'] = hasil.selesaiPada.millisecondsSinceEpoch;

    try {
      await _riwayatCol.add(data);

      await _userDoc.collection('kuis_rekap').doc('rekap').set({
        'percobaan': FieldValue.increment(1),
        'totalSoal': FieldValue.increment(hasil.jumlahSoal),
        'totalBenar': FieldValue.increment(hasil.benar),
      }, SetOptions(merge: true));

      if (hasil.kuisTema && hasil.tema.trim().isNotEmpty) {
        final kunci = hasil.tema.trim().toLowerCase();
        final lama = await rekorTema(hasil.tema);
        if (lama == null || hasil.lebihBaikDari(lama)) {
          await _rekorCol.doc(kunci).set({
            'tema': hasil.tema.trim(),
            'kategori': hasil.kategori,
            'subKategori': hasil.subKategori,
            'jumlahSoal': hasil.jumlahSoal,
            'benar': hasil.benar,
            'salah': hasil.salah,
            'detik': hasil.detik,
            'selesaiPada': hasil.selesaiPada.millisecondsSinceEpoch,
          }, SetOptions(merge: true));
        }
      }

      bersihkanCache();
    } catch (_) {}
  }

  // ambil semua riwayat
  Future<List<HasilKuis>> semua({int? batas, int lewati = 0}) async {
    if (_cacheRiwayat != null && lewati == 0 && batas == null) {
      return _cacheRiwayat!;
    }

    try {
      Query<Map<String, dynamic>> q =
          _riwayatCol.orderBy('selesaiPada', descending: true);
      if (batas != null) q = q.limit(batas);

      final snap = await q.get();
      final list = snap.docs.map((d) {
        final m = d.data();
        m['id'] = d.id.hashCode.abs();
        return HasilKuis.dariKolom(m);
      }).toList();

      if (lewati == 0 && batas == null) {
        _cacheRiwayat = list;
      }
      return list;
    } catch (_) {
      return const [];
    }
  }

  // rekor tema
  Future<HasilKuis?> rekorTema(String tema) async {
    final kunci = tema.trim().toLowerCase();
    if (kunci.isEmpty) return null;

    if (_cacheRekor != null && _cacheRekor!.containsKey(kunci)) {
      return _cacheRekor![kunci];
    }

    try {
      final doc = await _rekorCol.doc(kunci).get();
      if (!doc.exists || doc.data() == null) return null;
      final m = doc.data()!;
      m['id'] = doc.id.hashCode.abs();
      final r = HasilKuis.dariKolom(m);
      _cacheRekor ??= {};
      _cacheRekor![kunci] = r;
      return r;
    } catch (_) {
      return null;
    }
  }

  // rekor per tema
  Future<Map<String, HasilKuis>> rekorPerTema() async {
    if (_cacheRekor != null) return _cacheRekor!;

    try {
      final snap = await _rekorCol.get();
      final Map<String, HasilKuis> map = {};
      for (final doc in snap.docs) {
        final m = doc.data();
        m['id'] = doc.id.hashCode.abs();
        map[doc.id.toLowerCase()] = HasilKuis.dariKolom(m);
      }
      _cacheRekor = map;
      return map;
    } catch (_) {
      return const {};
    }
  }

  Future<bool> pernahSempurna(String tema) async {
    final rekor = await rekorTema(tema);
    return rekor?.sempurna ?? false;
  }

  // ringkasan kuis
  Future<RingkasanKuis> ringkasan() async {
    if (_cacheRingkasan != null) return _cacheRingkasan!;

    try {
      final doc = await _userDoc.collection('kuis_rekap').doc('rekap').get();
      final rekorMap = await rekorPerTema();
      final sempurna = rekorMap.values.where((r) => r.sempurna).length;

      if (!doc.exists || doc.data() == null) {
        final r = RingkasanKuis(temaSempurna: sempurna);
        _cacheRingkasan = r;
        return r;
      }

      final data = doc.data()!;
      final r = RingkasanKuis(
        percobaan: (data['percobaan'] as num?)?.toInt() ?? 0,
        totalSoal: (data['totalSoal'] as num?)?.toInt() ?? 0,
        totalBenar: (data['totalBenar'] as num?)?.toInt() ?? 0,
        temaSempurna: sempurna,
      );
      _cacheRingkasan = r;
      return r;
    } catch (_) {
      return const RingkasanKuis();
    }
  }

  // jumlah percobaan
  Future<int> jumlahPercobaan() async {
    final r = await ringkasan();
    return r.percobaan;
  }

  // jumlah kuis hari ini
  Future<int> jumlahHariIni() async {
    final sekarang = DateTime.now();
    final awalHari = DateTime(sekarang.year, sekarang.month, sekarang.day);

    try {
      final snap = await _riwayatCol
          .where('selesaiPada', isGreaterThanOrEqualTo: awalHari.millisecondsSinceEpoch)
          .get();
      return snap.docs.length;
    } catch (_) {
      return 0;
    }
  }
}

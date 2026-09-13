import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/storage/preference_handler.dart';
import 'riwayat_repository.dart';

// ringkasan kebiasaan harian satu akun
class RingkasanRuntun {
  final int berjalan;
  final int terpanjang;
  final int totalHari;
  final bool hadirHariIni;
  final int pembekuTersedia;
  final bool runtunDibekukan;

  const RingkasanRuntun({
    this.berjalan = 0,
    this.terpanjang = 0,
    this.totalHari = 0,
    this.hadirHariIni = false,
    this.pembekuTersedia = 2,
    this.runtunDibekukan = false,
  });
}

// satu tugas kecil hari ini
class MisiHarian {
  final String kode;
  final String nama;
  final String keterangan;
  final int target;
  final int tercapai;

  const MisiHarian({
    required this.kode,
    required this.nama,
    required this.keterangan,
    required this.target,
    required this.tercapai,
  });

  bool get selesai => tercapai >= target;
}

class RuntunRepository {
  final FirebaseFirestore _firestore;
  final RiwayatRepository _riwayatRepository;

  static Set<String>? _cachedKunjungan;
  static Set<String>? _cachedBeku;
  static RingkasanRuntun? _cacheRingkasan;
  static String? _cachedUser;

  RuntunRepository({
    FirebaseFirestore? firestore,
    RiwayatRepository? riwayatRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _riwayatRepository = riwayatRepository ?? RiwayatRepository();

  static const int targetArsipHarian = 1;

  String get _uid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final user = PreferenceHandler.user;
    if (user?.uid != null && user!.uid!.isNotEmpty) return user.uid!;
    final id = PreferenceHandler.userId;
    if (id > 0) return 'user_$id';
    return 'guest';
  }

  DocumentReference<Map<String, dynamic>> get _runtunDoc =>
      _firestore.collection('users').doc(_uid).collection('runtun').doc('info');

  static String _kunci(DateTime tanggal) {
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final hari = tanggal.day.toString().padLeft(2, '0');
    return '${tanggal.year}-$bulan-$hari';
  }

  static void bersihkanCache() {
    _cachedKunjungan = null;
    _cachedBeku = null;
    _cacheRingkasan = null;
    _cachedUser = null;
  }

  // catat kunjungan hari ini
  Future<void> catatKunjunganHariIni() async {
    final uid = _uid;
    if (uid == 'guest') return;

    if (_cachedUser != uid) {
      _cachedKunjungan = null;
      _cachedBeku = null;
      _cacheRingkasan = null;
      _cachedUser = uid;
    }

    final hariIni = _kunci(DateTime.now());
    _cachedKunjungan ??= {};
    if (_cachedKunjungan!.contains(hariIni)) return;

    _cachedKunjungan!.add(hariIni);
    _cacheRingkasan = null;

    try {
      await _runtunDoc.set({
        'kunjungan': FieldValue.arrayUnion([hariIni]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _muatDataRuntun() async {
    final uid = _uid;
    if (uid == 'guest') return;

    if (_cachedUser != uid) {
      _cachedKunjungan = null;
      _cachedBeku = null;
      _cacheRingkasan = null;
      _cachedUser = uid;
    }

    if (_cachedKunjungan != null && _cachedBeku != null) return;

    try {
      final doc = await _runtunDoc.get().timeout(const Duration(seconds: 10));
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawKunjungan = data['kunjungan'];
        if (rawKunjungan is List) {
          _cachedKunjungan = rawKunjungan.map((e) => e.toString()).toSet();
        } else {
          _cachedKunjungan = {};
        }

        final rawBeku = data['pembeku'];
        if (rawBeku is List) {
          _cachedBeku = rawBeku.map((e) => e.toString()).toSet();
        } else {
          _cachedBeku = {};
        }
        return;
      }
    } catch (_) {}

    _cachedKunjungan ??= {};
    _cachedBeku ??= {};
  }

  Future<Set<String>> _tanggalKunjungan() async {
    await _muatDataRuntun();
    return _cachedKunjungan ?? <String>{};
  }

  Future<Set<String>> _tanggalBeku() async {
    await _muatDataRuntun();
    return _cachedBeku ?? <String>{};
  }

  Future<bool> gunakanPembeku(DateTime tanggal, {String alasan = 'Pembeku Runtun'}) async {
    final kunciTanggal = _kunci(tanggal);
    _cachedBeku ??= {};
    _cachedBeku!.add(kunciTanggal);
    _cacheRingkasan = null;

    try {
      await _runtunDoc.set({
        'pembeku': FieldValue.arrayUnion([kunciTanggal]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ringkasan runtun
  Future<RingkasanRuntun> ringkasan() async {
    final uid = _uid;
    if (uid == 'guest') return const RingkasanRuntun();

    if (_cachedUser != uid) {
      _cachedKunjungan = null;
      _cachedBeku = null;
      _cacheRingkasan = null;
      _cachedUser = uid;
    }

    if (_cacheRingkasan != null) return _cacheRingkasan!;

    final tanggal = await _tanggalKunjungan();
    final beku = await _tanggalBeku();
    final gabungan = <String>{...tanggal, ...beku};

    if (gabungan.isEmpty) {
      const kosong = RingkasanRuntun();
      _cacheRingkasan = kosong;
      _cachedUser = uid;
      return kosong;
    }

    final hariIni = DateTime.now();
    final awal = DateTime(hariIni.year, hariIni.month, hariIni.day);
    final hadirHariIni = gabungan.contains(_kunci(awal));

    var mulai = awal;
    var runtunDibekukan = false;

    if (!hadirHariIni) {
      final kemarin = awal.subtract(const Duration(days: 1));
      if (!gabungan.contains(_kunci(kemarin))) {
        if (beku.length < 2) {
          await gunakanPembeku(kemarin, alasan: 'Pembeku Otomatis');
          gabungan.add(_kunci(kemarin));
          runtunDibekukan = true;
          mulai = kemarin;
        } else {
          final res = RingkasanRuntun(
            terpanjang: _runtunTerpanjang(gabungan),
            totalHari: gabungan.length,
            pembekuTersedia: (2 - beku.length).clamp(0, 2),
          );
          _cacheRingkasan = res;
          _cachedUser = uid;
          return res;
        }
      } else {
        mulai = kemarin;
      }
    }

    var berjalan = 0;
    var cursor = mulai;
    while (gabungan.contains(_kunci(cursor))) {
      berjalan++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final sisaPembeku = (2 - beku.length).clamp(0, 2);

    final res = RingkasanRuntun(
      berjalan: berjalan,
      terpanjang: _runtunTerpanjang(gabungan),
      totalHari: gabungan.length,
      hadirHariIni: hadirHariIni,
      pembekuTersedia: sisaPembeku,
      runtunDibekukan: runtunDibekukan,
    );
    _cacheRingkasan = res;
    _cachedUser = uid;
    return res;
  }

  int _runtunTerpanjang(Set<String> tanggal) {
    final urut = tanggal.toList()..sort();
    var terpanjang = 0;
    var berjalan = 0;
    DateTime? sebelumnya;

    for (final teks in urut) {
      final hari = DateTime.tryParse(teks);
      if (hari == null) continue;

      if (sebelumnya != null && hari.difference(sebelumnya).inDays == 1) {
        berjalan++;
      } else {
        berjalan = 1;
      }
      if (berjalan > terpanjang) terpanjang = berjalan;
      sebelumnya = hari;
    }
    return terpanjang;
  }

  // misi hari ini
  Future<List<MisiHarian>> misiHariIni() async {
    final arsip = await _riwayatRepository.jumlahDibukaHariIni();
    final ringkas = await ringkasan();

    return [
      MisiHarian(
        kode: 'hadir',
        nama: 'Datang hari ini',
        keterangan: 'Buka Renjana untuk menjaga runtun',
        target: 1,
        tercapai: ringkas.hadirHariIni ? 1 : 0,
      ),
      MisiHarian(
        kode: 'arsip',
        nama: 'Baca satu arsip',
        keterangan: 'Buka satu halaman sejarah atau budaya',
        target: targetArsipHarian,
        tercapai: arsip,
      ),
    ];
  }
}

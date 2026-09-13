import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/lencana_model.dart';
import 'package:renjana/features/wilayah/data/static/data_wilayah_nusantara.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/features/jelajah/data/repositories/jelajah_repository.dart';
import 'package:renjana/features/kontribusi/data/repositories/usulan_repository.dart';
import '../../../../core/services/cloudinary_service.dart';
import 'arsip_dibaca_repository.dart';
import 'runtun_repository.dart';

// section model status lencana
class StatusLencana {
  final Lencana lencana;
  final int tercapai;
  final int target;
  final bool terbuka;

  // status terbuka
  final bool baru;

  // status sematan profil
  final bool disematkan;

  // tautan logo kustom
  final String gambar;

  const StatusLencana({
    required this.lencana,
    required this.tercapai,
    required this.target,
    required this.terbuka,
    this.baru = false,
    this.disematkan = false,
    this.gambar = '',
  });

  double get rasio =>
      target <= 0 ? 0 : (tercapai / target).clamp(0.0, 1.0).toDouble();
}

class LencanaRepository {
  final FirebaseFirestore _firestore;
  final JelajahRepository _jelajahRepository;
  final ArsipDibacaRepository _arsipDibacaRepository;
  final RuntunRepository _runtunRepository;
  final UsulanRepository _usulanRepository;

  static Map<String, String>? _cachedLogo;
  static Map<String, bool>? _cachedTerbuka;
  static String? _cachedUser;

  LencanaRepository({
    FirebaseFirestore? firestore,
    JelajahRepository? jelajahRepository,
    ArsipDibacaRepository? arsipDibacaRepository,
    RuntunRepository? runtunRepository,
    UsulanRepository? usulanRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _jelajahRepository = jelajahRepository ?? JelajahRepository(),
        _arsipDibacaRepository =
            arsipDibacaRepository ?? ArsipDibacaRepository(),
        _runtunRepository = runtunRepository ?? RuntunRepository(),
        _usulanRepository = usulanRepository ?? UsulanRepository();

  static const int batasSematan = 3;

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

  // koleksi lencana pengguna
  CollectionReference<Map<String, dynamic>> _koleksiPengguna() {
    return _firestore
        .collection('users')
        .doc(_userUid)
        .collection('lencana');
  }

  // logo lencana
  Future<Map<String, String>> logo() async {
    if (_cachedLogo != null) return _cachedLogo!;

    try {
      final snap = await _firestore
          .collection('lencana_ikon')
          .get()
          .timeout(const Duration(seconds: 10));
      final map = <String, String>{};
      for (final doc in snap.docs) {
        final g = doc.data()['gambar'] as String? ?? '';
        if (g.isNotEmpty) map[doc.id] = g;
      }
      _cachedLogo = map;
      return map;
    } catch (e) {
      debugPrint('[LencanaRepository] Gagal memuat logo lencana: $e');
      return _cachedLogo ?? const {};
    }
  }

  // set logo lencana
  Future<void> setLogo(String kode, String? gambar) async {
    String? finalGambar = gambar?.trim();
    if (finalGambar != null &&
        finalGambar.isNotEmpty &&
        !finalGambar.startsWith('http')) {
      final url = await CloudinaryService().uploadFilePath(
        finalGambar,
        subFolder: 'lencana',
      );
      if (url != null) finalGambar = url;
    }

    _cachedLogo?[kode] = finalGambar ?? '';
    try {
      if (finalGambar == null || finalGambar.isEmpty) {
        await _firestore
            .collection('lencana_ikon')
            .doc(kode)
            .delete()
            .timeout(const Duration(seconds: 10));
      } else {
        await _firestore
            .collection('lencana_ikon')
            .doc(kode)
            .set({'gambar': finalGambar}, SetOptions(merge: true))
            .timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint('[LencanaRepository] Gagal menyimpan logo lencana: $e');
      rethrow;
    }
  }

  // kode lencana terbuka
  Future<Map<String, bool>> _kodeTerbuka() async {
    final uid = _userUid;
    if (uid == 'guest') return const {};

    if (_cachedTerbuka != null && _cachedUser == uid) {
      return _cachedTerbuka!;
    }

    try {
      final snap = await _koleksiPengguna().get();
      final map = <String, bool>{};
      for (final doc in snap.docs) {
        final d = doc.data();
        final k = (d['kode'] as String?) ?? doc.id;
        final disematkan = d['disematkan'] == true || d['disematkan'] == 1;
        if (k.isNotEmpty) map[k] = disematkan;
      }
      _cachedTerbuka = map;
      _cachedUser = uid;
      return map;
    } catch (_) {
      if (_cachedUser != uid) return const {};
      return _cachedTerbuka ?? const {};
    }
  }

  // sematkan lencana
  Future<bool> setSematan(String kode, bool disematkan) async {
    final uid = _userUid;
    if (uid == 'guest') return false;

    final terbuka = await _kodeTerbuka();
    if (disematkan) {
      final terpasang = terbuka.values.where((v) => v).length;
      if (terpasang >= batasSematan) return false;
    }

    _cachedTerbuka?[kode] = disematkan;
    _cachedStatus = null;

    try {
      await _koleksiPengguna().doc(kode).set({
        'kode': kode,
        'disematkan': disematkan,
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  // buka lencana
  Future<void> _buka(Iterable<String> kode) async {
    final uid = _userUid;
    if (uid == 'guest') return;

    final batch = _firestore.batch();
    for (final k in kode) {
      _cachedTerbuka?[k] = false;
      final docRef = _koleksiPengguna().doc(k);
      batch.set(docRef, {
        'kode': k,
        'disematkan': false,
        'dibukaPada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    try {
      await batch.commit();
    } catch (_) {}
  }

  static String _kategoriArsip(HasilJelajah item) =>
      item.jenis == JenisArsip.budaya
      ? (item.budaya?.jenis.trim().toUpperCase() ?? '')
      : '';

  static String _periodeArsip(HasilJelajah item) =>
      item.jenis == JenisArsip.sejarah
      ? (item.sejarah?.periode?.trim().toUpperCase() ?? '')
      : '';

  static String _pulauArsip(HasilJelajah item) =>
      pulauDariProvinsi(item.asalProvinsi)?.id ?? '';

  static List<StatusLencana>? _cachedStatus;
  static DateTime? _terakhirEvaluasi;
  static String? _cachedStatusUser;

  // section evaluasi kemajuan lencana
  Future<List<StatusLencana>> evaluasi({bool forceRefresh = false}) async {
    final uid = _userUid;
    if (!forceRefresh &&
        _cachedStatus != null &&
        _terakhirEvaluasi != null &&
        _cachedStatusUser == uid) {
      if (DateTime.now().difference(_terakhirEvaluasi!).inMinutes < 5) {
        return _cachedStatus!;
      }
    }

    final semuaArsip = await _jelajahRepository.semuaArsip();
    final refs = await _arsipDibacaRepository.semua();
    final dibuka = await _jelajahRepository.ambilDariRiwayat(refs);
    final runtun = await _runtunRepository.ringkasan();
    final sudahTerbuka = await _kodeTerbuka();
    final usulanTerbit = await _usulanRepository.jumlahDisetujui();
    final petaLogo = await logo();

    // agregasi arsip per kategori, periode, dan pulau
    final totalKategori = <String, int>{};
    final totalPeriode = <String, int>{};
    final totalPulau = <String, int>{};
    for (final item in semuaArsip) {
      final kat = _kategoriArsip(item);
      if (kat.isNotEmpty) {
        totalKategori[kat] = (totalKategori[kat] ?? 0) + 1;
      }
      final prd = _periodeArsip(item);
      if (prd.isNotEmpty) {
        totalPeriode[prd] = (totalPeriode[prd] ?? 0) + 1;
      }
      final pulau = _pulauArsip(item);
      if (pulau.isNotEmpty) {
        totalPulau[pulau] = (totalPulau[pulau] ?? 0) + 1;
      }
    }

    final bacaKategori = <String, int>{};
    final bacaPeriode = <String, int>{};
    final bacaPulau = <String, int>{};
    for (final item in dibuka) {
      final kat = _kategoriArsip(item);
      if (kat.isNotEmpty) {
        bacaKategori[kat] = (bacaKategori[kat] ?? 0) + 1;
      }
      final prd = _periodeArsip(item);
      if (prd.isNotEmpty) {
        bacaPeriode[prd] = (bacaPeriode[prd] ?? 0) + 1;
      }
      final pulau = _pulauArsip(item);
      if (pulau.isNotEmpty) {
        bacaPulau[pulau] = (bacaPulau[pulau] ?? 0) + 1;
      }
    }

    final hasil = <StatusLencana>[];
    final baruTerbuka = <String>{};

    for (final lencana in lencanaKatalog) {
      int tercapai;
      int target;

      switch (lencana.syarat) {
        case JenisSyarat.arsipKategori:
          target = totalKategori[lencana.acuan] ?? 0;
          tercapai = bacaKategori[lencana.acuan] ?? 0;
          break;
        case JenisSyarat.arsipPeriode:
          target = totalPeriode[lencana.acuan] ?? 0;
          tercapai = bacaPeriode[lencana.acuan] ?? 0;
          break;
        case JenisSyarat.arsipPulau:
          target = totalPulau[lencana.acuan] ?? 0;
          tercapai = bacaPulau[lencana.acuan] ?? 0;
          break;
        case JenisSyarat.runtun:
          target = lencana.ambang;
          tercapai = runtun.terpanjang;
          break;
        case JenisSyarat.jumlahArsip:
          target = lencana.ambang;
          tercapai = dibuka.length;
          break;
        case JenisSyarat.usulanDisetujui:
          target = lencana.ambang;
          tercapai = usulanTerbit;
          break;
      }

      // validasi ketersediaan target
      final memenuhi = target > 0 && tercapai >= target;
      final sudah = sudahTerbuka.containsKey(lencana.kode);
      if (memenuhi && !sudah) baruTerbuka.add(lencana.kode);

      hasil.add(
        StatusLencana(
          lencana: lencana,
          tercapai: tercapai > target ? target : tercapai,
          target: target,
          terbuka: sudah || memenuhi,
          baru: memenuhi && !sudah,
          disematkan: sudahTerbuka[lencana.kode] ?? false,
          gambar: petaLogo[lencana.kode] ?? '',
        ),
      );
    }

    if (baruTerbuka.isNotEmpty) await _buka(baruTerbuka);
    _cachedStatus = hasil;
    _cachedStatusUser = uid;
    _terakhirEvaluasi = DateTime.now();
    return hasil;
  }

  Future<int> jumlahTerbuka() async {
    final status = await evaluasi();
    return status.where((s) => s.terbuka).length;
  }

  // bersihkan cache lencana pengguna
  static void bersihkanCache() {
    _cachedStatus = null;
    _cachedStatusUser = null;
    _terakhirEvaluasi = null;
    _cachedTerbuka = null;
    _cachedUser = null;
  }
}

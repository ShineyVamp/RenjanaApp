import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../static/data_wilayah_nusantara.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/features/jelajah/data/repositories/jelajah_repository.dart';

// section ringkasan pulau
class RingkasanPulau {
  final int total;
  final Map<String, int> perProvinsi;

  const RingkasanPulau({required this.total, required this.perProvinsi});

  int jumlah(String namaProvinsi) => perProvinsi[namaProvinsi] ?? 0;
}

// section repositori wilayah
class WilayahRepository {
  final FirebaseFirestore _firestore;
  final JelajahRepository _jelajahRepository;

  static List<GugusPulau>? _cachedPulau;
  static Map<String, Provinsi>? _cachedProvinsi;

  WilayahRepository({
    FirebaseFirestore? firestore,
    JelajahRepository? jelajahRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _jelajahRepository = jelajahRepository ?? JelajahRepository();

  // section cache
  static void bersihkanCache() {
    _cachedPulau = null;
    _cachedProvinsi = null;
  }

  // section muat data wilayah firestore
  Future<List<GugusPulau>> getAllPulau({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedPulau != null && _cachedPulau!.isNotEmpty) {
      return _cachedPulau!;
    }

    try {
      final snap = await _firestore
          .collection('wilayah_pulau')
          .get()
          .timeout(const Duration(seconds: 10));
      if (snap.docs.isNotEmpty) {
        final list = snap.docs.map((doc) => GugusPulau.fromMap(doc.data())).toList();
        _cachedPulau = list;
        return list;
      }
    } catch (_) {}

    _cachedPulau = List<GugusPulau>.from(gugusPulauList);
    return _cachedPulau!;
  }

  Future<List<Provinsi>> getAllProvinsi({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProvinsi != null && _cachedProvinsi!.isNotEmpty) {
      return _cachedProvinsi!.values.toList();
    }
    final pulauList = await getAllPulau(forceRefresh: forceRefresh);
    final map = <String, Provinsi>{};
    for (final p in pulauList) {
      for (final prov in p.provinsi) {
        map[prov.nama.toLowerCase()] = prov;
      }
    }
    _cachedProvinsi = map;
    return map.values.toList();
  }

  // section cari provinsi
  Future<Provinsi?> getProvinsi(String namaProvinsi) async {
    final semua = await getAllProvinsi();
    final target = namaProvinsi.trim().toLowerCase();
    for (final prov in semua) {
      if (prov.nama.trim().toLowerCase() == target) return prov;
    }
    return null;
  }

  // section perbarui gambar provinsi
  Future<void> updateGambarProvinsi(String namaProvinsi, String gambarUrl) async {
    final targetDoc = namaProvinsi.trim();
    await _firestore.collection('wilayah_provinsi').doc(targetDoc).set({
      'gambar': gambarUrl,
    }, SetOptions(merge: true));

    final pulau = pulauDariProvinsi(namaProvinsi);
    if (pulau != null) {
      try {
        final docRef = _firestore.collection('wilayah_pulau').doc(pulau.id);
        final snap = await docRef.get().timeout(const Duration(seconds: 8));
        if (snap.exists) {
          final data = snap.data() ?? {};
          final listProv = List<dynamic>.from(data['provinsi'] ?? []);
          for (var i = 0; i < listProv.length; i++) {
            if (listProv[i] is Map &&
                (listProv[i]['nama'] as String?)?.trim().toLowerCase() ==
                    namaProvinsi.trim().toLowerCase()) {
              listProv[i]['gambar'] = gambarUrl;
            }
          }
          await docRef.update({'provinsi': listProv});
        }
      } catch (_) {}
    }

    bersihkanCache();
  }

  // section arsip per provinsi
  Future<Map<String, List<HasilJelajah>>> _kelompokPerProvinsi() async {
    final hasil = <String, List<HasilJelajah>>{};
    for (final item in await _jelajahRepository.semuaArsip()) {
      final asal = item.asalProvinsi?.trim();
      if (asal == null || asal.isEmpty) continue;
      hasil.putIfAbsent(asal.toLowerCase(), () => []).add(item);
    }
    return hasil;
  }

  Future<Map<String, List<HasilJelajah>>> arsipPerProvinsi() =>
      _kelompokPerProvinsi();

  Future<List<HasilJelajah>> arsipProvinsi(String namaProvinsi) async {
    final kelompok = await _kelompokPerProvinsi();
    final daftar = kelompok[namaProvinsi.trim().toLowerCase()] ?? const [];
    return List<HasilJelajah>.from(daftar)
      ..sort((a, b) => a.judul.toLowerCase().compareTo(b.judul.toLowerCase()));
  }

  Future<int> jumlahArsipProvinsi(String namaProvinsi) async {
    final kelompok = await _kelompokPerProvinsi();
    return kelompok[namaProvinsi.trim().toLowerCase()]?.length ?? 0;
  }

  Future<RingkasanPulau> ringkasanPulau(GugusPulau pulau) async {
    final kelompok = await _kelompokPerProvinsi();

    var total = 0;
    final perProvinsi = <String, int>{};
    for (final provinsi in pulau.provinsi) {
      final jumlah = kelompok[provinsi.nama.toLowerCase()]?.length ?? 0;
      perProvinsi[provinsi.nama] = jumlah;
      total += jumlah;
    }
    return RingkasanPulau(total: total, perProvinsi: perProvinsi);
  }

  Future<List<HasilJelajah>> arsipPulau(GugusPulau pulau) async {
    final kelompok = await _kelompokPerProvinsi();
    return [
      for (final provinsi in pulau.provinsi)
        ...?kelompok[provinsi.nama.toLowerCase()],
    ];
  }

  // section acak arsip provinsi
  Future<List<HasilJelajah>> arsipAcakProvinsi(
    String namaProvinsi, {
    int jumlah = 5,
    String? kecualiKodeTag,
  }) async {
    final daftar = await arsipProvinsi(namaProvinsi);
    final kolam = daftar
        .where((item) => item.kodeTag != kecualiKodeTag)
        .toList();
    if (kolam.isEmpty) return const [];

    kolam.shuffle(Random());
    return kolam.take(jumlah).toList();
  }
}

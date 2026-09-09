import 'dart:math';

import '../../../../core/constants/wilayah_nusantara.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/features/jelajah/data/repositories/jelajah_repository.dart';

// Ringkasan arsip satu pulau: totalnya dan rinciannya per provinsi.
class RingkasanPulau {
  final int total;
  final Map<String, int> perProvinsi; // kunci = nama provinsi apa adanya

  const RingkasanPulau({required this.total, required this.perProvinsi});

  int jumlah(String namaProvinsi) => perProvinsi[namaProvinsi] ?? 0;
}

// Menghubungkan arsip dengan daerah asalnya.
class WilayahRepository {
  final JelajahRepository _jelajahRepository;

  WilayahRepository({JelajahRepository? jelajahRepository})
    : _jelajahRepository = jelajahRepository ?? JelajahRepository();

  // Seluruh arsip dikelompokkan per provinsi, dibaca sekali lalu dibagi di
  // memori.
  Future<Map<String, List<HasilJelajah>>> _kelompokPerProvinsi() async {
    final hasil = <String, List<HasilJelajah>>{};
    for (final item in await _jelajahRepository.semuaArsip()) {
      final asal = item.asalProvinsi?.trim();
      if (asal == null || asal.isEmpty) continue;
      hasil.putIfAbsent(asal.toLowerCase(), () => []).add(item);
    }
    return hasil;
  }

  // Peta arsip per provinsi, kuncinya nama provinsi huruf kecil. Dipakai
  // pemanggil yang butuh seluruh provinsi sekaligus.
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

  // Rekomendasi acak dari satu provinsi, untuk bagian bawah halaman detail.
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

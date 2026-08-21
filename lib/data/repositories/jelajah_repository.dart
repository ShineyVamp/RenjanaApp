import '../models/hasil_jelajah_model.dart';
import 'budaya_repository.dart';
import 'sejarah_repository.dart';

// Pencarian gabungan sejarah + budaya untuk halaman Jelajah.
class JelajahRepository {
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;

  JelajahRepository({
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
  }) : _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository();

  Future<List<HasilJelajah>> _semuaArsip() async {
    final sejarah = await _sejarahRepository.getAllSejarah();
    final budaya = await _budayaRepository.getAllBudaya();
    return [
      ...sejarah.map(HasilJelajah.dariSejarah),
      ...budaya.map(HasilJelajah.dariBudaya),
    ];
  }

  // Cocok bila kata kunci muncul di judul, subjudul/tagline, ID tag, atau
  // isi ringkasan/deskripsi. Judul yang cocok diprioritaskan di urutan atas.
  Future<List<HasilJelajah>> cari(String kataKunci) async {
    final kunci = kataKunci.trim().toLowerCase();
    if (kunci.isEmpty) return [];

    final cocok = <HasilJelajah>[];
    for (final item in await _semuaArsip()) {
      final isi = item.jenis == JenisArsip.sejarah
          ? item.sejarah!.ringkasan
          : item.budaya!.deskripsi;

      final ladang = [
        item.judul,
        item.sub,
        item.kodeTag,
        item.meta,
        isi,
      ].join(' ').toLowerCase();

      if (ladang.contains(kunci)) cocok.add(item);
    }

    cocok.sort((a, b) {
      final aJudul = a.judul.toLowerCase().contains(kunci) ? 0 : 1;
      final bJudul = b.judul.toLowerCase().contains(kunci) ? 0 : 1;
      if (aJudul != bJudul) return aJudul.compareTo(bJudul);
      return a.judul.toLowerCase().compareTo(b.judul.toLowerCase());
    });
    return cocok;
  }

  // Mengubah daftar ref riwayat ('jenis|kodeTag') jadi arsip yang masih ada,
  // urutannya mengikuti urutan riwayat.
  Future<List<HasilJelajah>> ambilDariRiwayat(
    List<String> refs, {
    int? batas,
  }) async {
    if (refs.isEmpty) return [];

    final indeks = {
      for (final item in await _semuaArsip()) item.refRiwayat: item,
    };
    final hasil = <HasilJelajah>[];
    for (final ref in refs) {
      final item = indeks[ref];
      if (item != null) hasil.add(item);
      if (batas != null && hasil.length >= batas) break;
    }
    return hasil;
  }
}

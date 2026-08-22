import '../../core/constants/wilayah_nusantara.dart';
import '../models/hasil_jelajah_model.dart';
import 'budaya_repository.dart';
import 'sejarah_repository.dart';

// Pencarian gabungan sejarah, budaya, dan wilayah untuk halaman Jelajah.
class JelajahRepository {
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;

  JelajahRepository({
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
  }) : _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository();

  // Seluruh arsip sejarah dan budaya, tanpa wilayah. Dipakai juga
  // WilayahRepository untuk menghitung arsip per daerah.
  Future<List<HasilJelajah>> semuaArsip() async {
    final sejarah = await _sejarahRepository.getAllSejarah();
    final budaya = await _budayaRepository.getAllBudaya();
    return [
      ...sejarah.map(HasilJelajah.dariSejarah),
      ...budaya.map(HasilJelajah.dariBudaya),
    ];
  }

  // Tujuh pulau dan 38 provinsi sebagai baris hasil pencarian.
  List<HasilJelajah> semuaWilayah() => [
    ...gugusPulauList.map(HasilJelajah.dariPulau),
    ...semuaProvinsi.map(HasilJelajah.dariProvinsi),
  ];

  // Mencari pada judul, subjudul, ID tag, kategori, dan isi tambahan tiap
  // jenis. Kecocokan judul diletakkan di urutan atas.
  Future<List<HasilJelajah>> cari(String kataKunci) async {
    final kunci = kataKunci.trim().toLowerCase();
    if (kunci.isEmpty) return [];

    final sumber = [...await semuaArsip(), ...semuaWilayah()];
    final cocok = <HasilJelajah>[];

    for (final item in sumber) {
      final ladang = [
        item.judul,
        item.sub,
        item.kodeTag,
        item.meta,
        item.isiPencarian,
      ].join(' ').toLowerCase();

      if (ladang.contains(kunci)) cocok.add(item);
    }

    cocok.sort((a, b) {
      final aJudul = a.judul.toLowerCase().contains(kunci) ? 0 : 1;
      final bJudul = b.judul.toLowerCase().contains(kunci) ? 0 : 1;
      if (aJudul != bJudul) return aJudul.compareTo(bJudul);

      // wilayah didahulukan atas arsip
      final aWilayah = a.isWilayah ? 0 : 1;
      final bWilayah = b.isWilayah ? 0 : 1;
      if (aWilayah != bWilayah) return aWilayah.compareTo(bWilayah);

      return a.judul.toLowerCase().compareTo(b.judul.toLowerCase());
    });
    return cocok;
  }

  // Mengubah daftar ref riwayat ('jenis|kodeTag') jadi arsip yang masih ada,
  // urut sesuai urutan riwayat.
  Future<List<HasilJelajah>> ambilDariRiwayat(
    List<String> refs, {
    int? batas,
  }) async {
    if (refs.isEmpty) return [];

    final indeks = {
      for (final item in await semuaArsip()) item.refRiwayat: item,
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

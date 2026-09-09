import '../../../core/constants/budaya_kategori.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';

// Alat bantu bersama halaman daftar arsip daerah: pengelompokan per kategori
// dan penyaringan kata kunci.

const String kunciSejarah = 'SEJARAH';
const String kunciSemua = 'SEMUA';

// Sejarah jadi satu kelompok sendiri, budaya dipisah per kode kategori.
String kunciKategoriArsip(HasilJelajah item) => item.jenis == JenisArsip.budaya
    ? (item.budaya?.jenis.trim().toUpperCase() ?? kunciSejarah)
    : kunciSejarah;

String labelKategoriArsip(String kunci) =>
    kunci == kunciSejarah ? 'Sejarah' : namaKategori(kunci);

// Urutannya: sejarah dulu, lalu kategori budaya sesuai urutan katalog.
List<String> urutkanKunciKategori(Iterable<String> kunci) {
  final tersedia = kunci.toSet();
  return [
    if (tersedia.contains(kunciSejarah)) kunciSejarah,
    for (final k in budayaKategoriList)
      if (tersedia.contains(k.kode)) k.kode,
  ];
}

Map<String, List<HasilJelajah>> kelompokkanPerKategori(
  List<HasilJelajah> items,
) {
  final hasil = <String, List<HasilJelajah>>{};
  for (final item in items) {
    hasil.putIfAbsent(kunciKategoriArsip(item), () => []).add(item);
  }
  return hasil;
}

List<HasilJelajah> saringArsip(List<HasilJelajah> items, String kataKunci) {
  final kunci = kataKunci.trim().toLowerCase();
  if (kunci.isEmpty) return items;

  return items.where((item) {
    final ladang = [
      item.judul,
      item.sub,
      item.kodeTag,
      item.meta,
      item.isiPencarian,
    ].join(' ').toLowerCase();
    return ladang.contains(kunci);
  }).toList();
}

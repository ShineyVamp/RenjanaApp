import '../../../core/constants/budaya_kategori.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';

// section pengelompokan kategori arsip wilayah
const String kunciSejarah = 'SEJARAH';
const String kunciSemua = 'SEMUA';

String kunciKategoriArsip(HasilJelajah item) => item.jenis == JenisArsip.budaya
    ? (item.budaya?.jenis.trim().toUpperCase() ?? kunciSejarah)
    : kunciSejarah;

String labelKategoriArsip(String kunci) =>
    kunci == kunciSejarah ? 'Sejarah' : namaKategori(kunci);

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

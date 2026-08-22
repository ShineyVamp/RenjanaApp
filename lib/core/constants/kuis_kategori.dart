// Kosakata untuk kolom `kategori` dan `subKategori` pada tabel quiz.
//
// Isi `subKategori` per kategori:
//   BUDAYA     -> kode kategori budaya, mis. 'KLN'
//   KEDAERAHAN -> nama provinsi, mis. 'Sulawesi Selatan'
//   SEJARAH    -> selalu kosong
//
// Nilai inilah yang dipakai halaman kategori kuis untuk mengelompokkan kartu
// tema. Pulau diturunkan dari provinsi lewat `pulauDariProvinsi`.
import 'budaya_kategori.dart';
import 'wilayah_nusantara.dart';

const String kategoriSejarah = 'SEJARAH';
const String kategoriBudaya = 'BUDAYA';
const String kategoriKedaerahan = 'KEDAERAHAN';

const List<String> kuisKategoriList = [
  kategoriSejarah,
  kategoriBudaya,
  kategoriKedaerahan,
];

// Label kelompok untuk tema yang penandanya kosong atau tidak dikenali.
const String subKategoriLainnya = 'Lainnya';

// Satu pilihan pada dropdown admin sekaligus satu kelompok di halaman kategori.
// `induk` hanya terisi untuk kedaerahan, berisi nama pulau provinsi tersebut.
class OpsiSubKategori {
  final String nilai;
  final String label;
  final String induk;

  const OpsiSubKategori({
    required this.nilai,
    required this.label,
    this.induk = '',
  });
}

bool kategoriPunyaSubKategori(String kategori) {
  final k = kategori.trim().toUpperCase();
  return k == kategoriBudaya || k == kategoriKedaerahan;
}

List<OpsiSubKategori> opsiSubKategori(String kategori) {
  switch (kategori.trim().toUpperCase()) {
    case kategoriBudaya:
      return budayaKategoriList
          .map((k) => OpsiSubKategori(nilai: k.kode, label: k.nama))
          .toList();
    case kategoriKedaerahan:
      return [
        for (final pulau in gugusPulauList)
          for (final provinsi in pulau.provinsi)
            OpsiSubKategori(
              nilai: provinsi.nama,
              label: provinsi.nama,
              induk: pulau.nama,
            ),
      ];
    default:
      return const [];
  }
}

OpsiSubKategori? opsiSubKategoriDariNilai(String kategori, String? nilai) {
  final cari = nilai?.trim() ?? '';
  if (cari.isEmpty) return null;
  for (final opsi in opsiSubKategori(kategori)) {
    if (opsi.nilai.toLowerCase() == cari.toLowerCase()) return opsi;
  }
  return null;
}

// Judul kelompok pada halaman kategori, mis. 'Kuliner Tradisional'.
String labelSubKategori(String kategori, String? nilai) =>
    opsiSubKategoriDariNilai(kategori, nilai)?.label ?? subKategoriLainnya;

// Nama penyaring di atas daftar kelompok: kategori budaya untuk BUDAYA,
// nama pulau untuk KEDAERAHAN.
String indukSubKategori(String kategori, String? nilai) {
  final opsi = opsiSubKategoriDariNilai(kategori, nilai);
  if (opsi == null) return subKategoriLainnya;
  return opsi.induk.isEmpty ? opsi.label : opsi.induk;
}

// Daftar penyaring untuk satu kategori, urut sesuai katalog dan tanpa kembar.
List<String> daftarIndukSubKategori(String kategori) {
  final hasil = <String>[];
  for (final opsi in opsiSubKategori(kategori)) {
    final induk = opsi.induk.isEmpty ? opsi.label : opsi.induk;
    if (!hasil.contains(induk)) hasil.add(induk);
  }
  return hasil;
}

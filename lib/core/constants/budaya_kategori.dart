/// Katalog kategori budaya. Ini satu-satunya sumber kebenaran kategori:
/// data seed, form admin, dan daftar "Koleksi Budaya" di beranda semuanya
/// mengacu ke daftar ini supaya tidak ada kategori liar.
class BudayaKategori {
  final String kode; // dipakai pada kolom `jenis` dan ID tag
  final String nama; // nama tampilan

  const BudayaKategori({required this.kode, required this.nama});

  /// Nilai untuk kolom `kategoriLabel` (selalu huruf kapital).
  String get label => nama.toUpperCase();
}

const List<BudayaKategori> budayaKategoriList = [
  BudayaKategori(kode: 'RMH', nama: 'Rumah Adat'),
  BudayaKategori(kode: 'TRN', nama: 'Tarian Tradisional'),
  BudayaKategori(kode: 'PKN', nama: 'Pakaian Adat'),
  BudayaKategori(kode: 'UPC', nama: 'Upacara dan Tradisi Adat'),
  BudayaKategori(kode: 'MSK', nama: 'Alat Musik dan Lagu Daerah'),
  BudayaKategori(kode: 'SNJT', nama: 'Senjata Tradisional'),
  BudayaKategori(kode: 'SRK', nama: 'Seni Rupa dan Kriya'),
  BudayaKategori(kode: 'BHS', nama: 'Bahasa dan Sastra Daerah'),
];

/// Suffix ID tag untuk item yang sekaligus merupakan tempat wisata.
/// Contoh: `BUD-RMH-1-D` (D = Destinasi).
const String kodeDestinasiSuffix = '-D';

BudayaKategori? kategoriByKode(String kode) {
  final target = kode.trim().toUpperCase();
  for (final k in budayaKategoriList) {
    if (k.kode == target) return k;
  }
  return null;
}

/// Nama kategori untuk sebuah kode `jenis`; mengembalikan kode itu sendiri
/// bila tidak dikenali (data lama yang belum termigrasi).
String namaKategori(String kode) => kategoriByKode(kode)?.nama ?? kode;

/// Menyusun ID tag standar: `BUD-<JENIS>-<urutan>` + `-D` bila destinasi.
String buatKodeTagBudaya({
  required String jenis,
  required int urutan,
  bool isDestinasi = false,
}) {
  final base = 'BUD-${jenis.trim().toUpperCase()}-$urutan';
  return isDestinasi ? '$base$kodeDestinasiSuffix' : base;
}

// Katalog kategori budaya, dipakai beranda, halaman kategori, dan form admin.
class BudayaKategori {
  final String kode;
  final String nama;

  const BudayaKategori({required this.kode, required this.nama});

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

// penanda item yang juga tempat wisata
const String kodeDestinasiSuffix = '-D';

BudayaKategori? kategoriByKode(String kode) {
  final target = kode.trim().toUpperCase();
  for (final k in budayaKategoriList) {
    if (k.kode == target) return k;
  }
  return null;
}

String namaKategori(String kode) => kategoriByKode(kode)?.nama ?? kode;

// ID tag budaya: BUD-<kategori>-<urutan>, plus -D bila destinasi.
String buatKodeTagBudaya({
  required String jenis,
  required int urutan,
  bool isDestinasi = false,
}) {
  final base = 'BUD-${jenis.trim().toUpperCase()}-$urutan';
  return isDestinasi ? '$base$kodeDestinasiSuffix' : base;
}

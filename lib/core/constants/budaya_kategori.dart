import 'katalog_kategori.dart';

export 'katalog_kategori.dart';

typedef BudayaKategori = KategoriItem;

// daftar kategori budaya
List<KategoriItem> get budayaKategoriList => KatalogKategori.ranah(ranahBudaya);

// penanda destinasi wisata
const String kodeDestinasiSuffix = '-D';

// helper kategori budaya
KategoriItem? kategoriByKode(String kode) {
  final target = kode.trim().toUpperCase();
  for (final k in budayaKategoriList) {
    if (k.kode == target) return k;
  }
  return null;
}

String namaKategori(String kode) => kategoriByKode(kode)?.nama ?? kode;

List<FieldKategori> fieldKategori(String kode) =>
    kategoriByKode(kode)?.field ?? const [];

// pembentuk kode tag budaya
String buatKodeTagBudaya({
  required String jenis,
  required int urutan,
  bool isDestinasi = false,
}) {
  final base = 'BUD-${jenis.trim().toUpperCase()}-$urutan';
  return isDestinasi ? '$base$kodeDestinasiSuffix' : base;
}

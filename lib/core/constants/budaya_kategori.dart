// Pintasan ke ranah budaya pada katalog kategori, beserta penyusun ID tag
// arsip budaya.
//
// Tipe FieldKategori, TipeField, dan KategoriItem ikut diteruskan dari
// katalog_kategori.dart supaya pemakainya cukup mengimpor berkas ini.
import 'katalog_kategori.dart';

export 'katalog_kategori.dart';

typedef BudayaKategori = KategoriItem;

// Isi katalog terbaru, ikut berubah begitu admin menyunting kategori.
List<KategoriItem> get budayaKategoriList => KatalogKategori.ranah(ranahBudaya);

// penanda item yang juga tempat wisata
const String kodeDestinasiSuffix = '-D';

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

// ID tag budaya: BUD-<kategori>-<urutan>, plus -D bila destinasi.
String buatKodeTagBudaya({
  required String jenis,
  required int urutan,
  bool isDestinasi = false,
}) {
  final base = 'BUD-${jenis.trim().toUpperCase()}-$urutan';
  return isDestinasi ? '$base$kodeDestinasiSuffix' : base;
}

import 'budaya_model.dart';
import 'sejarah_model.dart';

enum JenisArsip { sejarah, budaya }

// Satu baris hasil di halaman Jelajah. Menyatukan sejarah dan budaya supaya
// keduanya bisa tampil dalam satu daftar.
class HasilJelajah {
  final JenisArsip jenis;
  final String kodeTag;
  final String judul;
  final String sub;
  final String meta;
  final String gambar;
  final bool isDestinasi;

  // Sumber aslinya, dipakai saat membuka halaman detail.
  final SejarahModel? sejarah;
  final BudayaModel? budaya;

  const HasilJelajah({
    required this.jenis,
    required this.kodeTag,
    required this.judul,
    required this.sub,
    required this.meta,
    required this.gambar,
    this.isDestinasi = false,
    this.sejarah,
    this.budaya,
  });

  factory HasilJelajah.dariSejarah(SejarahModel item) => HasilJelajah(
    jenis: JenisArsip.sejarah,
    kodeTag: item.kodeTag,
    judul: item.judul,
    sub: item.subtitle,
    meta: 'SEJARAH',
    gambar: item.gambarUtama,
    sejarah: item,
  );

  factory HasilJelajah.dariBudaya(BudayaModel item) => HasilJelajah(
    jenis: JenisArsip.budaya,
    kodeTag: item.kodeTag,
    judul: item.judul,
    sub: item.tagline,
    meta: item.kategoriLabel,
    gambar: item.gambarUtama,
    isDestinasi: item.isDestinasi,
    budaya: item,
  );

  // Kunci penyimpanan riwayat, mis. 'budaya|BUD-RMH-1-D'.
  String get refRiwayat => '${jenis.name}|$kodeTag';
}

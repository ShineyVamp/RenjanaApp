import '../../../../core/constants/wilayah_nusantara.dart';
import '../../../budaya/data/models/budaya_model.dart';
import '../../../sejarah/data/models/sejarah_model.dart';

enum JenisArsip { sejarah, budaya, pulau, provinsi }

// Satu baris hasil di halaman Jelajah, mewakili arsip (sejarah, budaya)
// maupun wilayah (pulau, provinsi).
class HasilJelajah {
  final JenisArsip jenis;
  final String kodeTag;
  final String judul;
  final String sub;
  final String meta;
  final String gambar;
  final bool isDestinasi;

  // Provinsi asal, hanya terisi untuk arsip sejarah dan budaya.
  final String? asalProvinsi;

  // Sumber aslinya, dipakai saat membuka halaman tujuan. Hanya satu yang
  // terisi, sesuai [jenis].
  final SejarahModel? sejarah;
  final BudayaModel? budaya;
  final GugusPulau? pulau;
  final Provinsi? wilayah;

  const HasilJelajah({
    required this.jenis,
    required this.kodeTag,
    required this.judul,
    required this.sub,
    required this.meta,
    required this.gambar,
    this.isDestinasi = false,
    this.asalProvinsi,
    this.sejarah,
    this.budaya,
    this.pulau,
    this.wilayah,
  });

  factory HasilJelajah.dariSejarah(SejarahModel item) => HasilJelajah(
    jenis: JenisArsip.sejarah,
    kodeTag: item.kodeTag,
    judul: item.judul,
    sub: item.subtitle,
    meta: 'SEJARAH',
    gambar: item.gambarUtama,
    asalProvinsi: item.provinsi,
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
    asalProvinsi: item.provinsi,
    budaya: item,
  );

  factory HasilJelajah.dariPulau(GugusPulau item) => HasilJelajah(
    jenis: JenisArsip.pulau,
    kodeTag: 'PULAU',
    judul: item.nama,
    sub: '${item.provinsi.length} provinsi',
    meta: 'GUGUS PULAU',
    gambar: item.gambar,
    pulau: item,
  );

  factory HasilJelajah.dariProvinsi(Provinsi item) => HasilJelajah(
    jenis: JenisArsip.provinsi,
    kodeTag: 'PROVINSI',
    judul: item.nama,
    sub: item.julukan.isNotEmpty ? item.julukan : item.ibukota,
    meta: pulauDariProvinsi(item.nama)?.nama.toUpperCase() ?? 'PROVINSI',
    gambar: gambarProvinsi(item),
    wilayah: item,
  );

  bool get isWilayah =>
      jenis == JenisArsip.pulau || jenis == JenisArsip.provinsi;

  // Teks tambahan yang ikut dicari, berbeda tiap jenis.
  String get isiPencarian {
    switch (jenis) {
      case JenisArsip.sejarah:
        return '${sejarah?.ringkasan ?? ''} ${asalProvinsi ?? ''}';
      case JenisArsip.budaya:
        return '${budaya?.deskripsi ?? ''} ${asalProvinsi ?? ''}';
      case JenisArsip.pulau:
        return '${pulau?.deskripsi ?? ''} '
            '${pulau?.provinsi.map((p) => p.nama).join(' ') ?? ''}';
      case JenisArsip.provinsi:
        return '${wilayah?.deskripsi ?? ''} ${wilayah?.ibukota ?? ''} '
            '${wilayah?.julukan ?? ''}';
    }
  }

  // Kunci penyimpanan riwayat, mis. 'budaya|BUD-RMH-1-D'. Hanya dipakai
  // arsip; wilayah tidak dicatat ke riwayat.
  String get refRiwayat => '${jenis.name}|$kodeTag';
}

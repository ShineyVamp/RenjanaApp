import 'package:renjana/features/wilayah/data/static/data_wilayah_nusantara.dart';
import '../../../budaya/data/models/budaya_model.dart';
import '../../../sejarah/data/models/sejarah_model.dart';

enum JenisArsip { sejarah, budaya, pulau, provinsi }

// model hasil pencarian jelajah
class HasilJelajah {
  final JenisArsip jenis;
  final String kodeTag;
  final String judul;
  final String sub;
  final String meta;
  final String gambar;
  final bool isDestinasi;
  final String? asalProvinsi;
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
    sub: item.tagline.isNotEmpty ? item.tagline : item.deskripsi,
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

  // referensi kunci riwayat pencarian
  String get refRiwayat => '${jenis.name}|$kodeTag';
}

import '../../core/constants/budaya_kategori.dart';

class BudayaModel {
  final int? id;
  final String kodeTag; // BUD-SNJT-1
  final String jenis; // kode kategori: SNJT, TRN, RMH, dst.
  final int urutan;
  final String judul;
  final String kategoriLabel; // 'SENJATA TRADISIONAL'
  final String tagline;
  final String deskripsi;
  final String gambarUtama;
  final String? maknaSpiritual;
  final String? gambarMaknaSpiritual;
  final String? konteksBudaya;
  final String? gambarKonteksBudaya;

  const BudayaModel({
    this.id,
    required this.kodeTag,
    required this.jenis,
    required this.urutan,
    required this.judul,
    required this.kategoriLabel,
    required this.tagline,
    required this.deskripsi,
    required this.gambarUtama,
    this.maknaSpiritual,
    this.gambarMaknaSpiritual,
    this.konteksBudaya,
    this.gambarKonteksBudaya,
  });

  // Item juga tempat wisata, ditandai suffix -D (mis. BUD-RMH-1-D).
  bool get isDestinasi =>
      kodeTag.trim().toUpperCase().endsWith(kodeDestinasiSuffix);

  // Nama kategori untuk ditampilkan.
  String get namaKategoriBudaya => namaKategori(jenis);
}

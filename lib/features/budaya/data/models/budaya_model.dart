import 'dart:convert';

import '../../../../core/constants/budaya_kategori.dart';

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

  // Nama provinsi asal, mengikuti penulisan di wilayah_nusantara.dart.
  final String? provinsi;

  // Username pengusul, terisi bila arsip ini berasal dari usulan pengguna.
  final String? kontributor;

  // Isi field khas kategori. Kuncinya mengikuti FieldKategori.kunci pada
  // kategori item ini; nilainya String untuk teks, List<String> untuk daftar.
  final Map<String, dynamic> detailKategori;

  // Format media: 'gambar' (default), 'video', 'youtube'
  final String jenisMedia;

  // URL / Path video atau link YouTube (bila jenisMedia != 'gambar')
  final String? mediaUrl;

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
    this.provinsi,
    this.detailKategori = const {},
    this.kontributor,
    this.jenisMedia = 'gambar',
    this.mediaUrl,
  });

  bool get isVideo => jenisMedia == 'video';
  bool get isYoutube => jenisMedia == 'youtube';
  bool get hasVideoMedia => isVideo || isYoutube;

  // Item juga tempat wisata, ditandai suffix -D (mis. BUD-RMH-1-D).
  bool get isDestinasi =>
      kodeTag.trim().toUpperCase().endsWith(kodeDestinasiSuffix);

  // Nama kategori untuk ditampilkan.
  String get namaKategoriBudaya => namaKategori(jenis);

  // section pembacaan detailKategori

  String teksDetail(String kunci) {
    final nilai = detailKategori[kunci];
    if (nilai is String) return nilai.trim();
    if (nilai is List) return nilai.join(', ');
    return '';
  }

  List<String> daftarDetail(String kunci) {
    final nilai = detailKategori[kunci];
    if (nilai is List) {
      return nilai
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (nilai is String && nilai.trim().isNotEmpty) return [nilai.trim()];
    return const [];
  }

  bool adaDetail(String kunci) => detailKategori[kunci] is List
      ? daftarDetail(kunci).isNotEmpty
      : teksDetail(kunci).isNotEmpty;

  // section serialisasi kolom detailKategori

  String get detailKategoriJson =>
      detailKategori.isEmpty ? '' : jsonEncode(detailKategori);

  // Peta kolom tabel budaya, dipakai seed, migrasi, dan repository.
  // Kolom `id` tidak ikut, diatur SQLite.
  Map<String, Object?> toKolom() => {
    'kodeTag': kodeTag,
    'jenis': jenis,
    'urutan': urutan,
    'judul': judul,
    'kategoriLabel': kategoriLabel,
    'tagline': tagline,
    'deskripsi': deskripsi,
    'gambarUtama': gambarUtama,
    'maknaSpiritual': maknaSpiritual,
    'gambarMaknaSpiritual': gambarMaknaSpiritual,
    'konteksBudaya': konteksBudaya,
    'gambarKonteksBudaya': gambarKonteksBudaya,
    'provinsi': provinsi,
    'detailKategori': detailKategoriJson,
    'kontributor': kontributor,
    'jenisMedia': jenisMedia,
    'mediaUrl': mediaUrl,
  };

  // Membaca kolom detailKategori; nilai null, kosong, atau rusak jadi {}.
  static Map<String, dynamic> detailDariJson(Object? mentah) {
    if (mentah == null) return const {};
    final teks = mentah.toString().trim();
    if (teks.isEmpty) return const {};
    try {
      final hasil = jsonDecode(teks);
      if (hasil is Map<String, dynamic>) return hasil;
    } catch (_) {}
    return const {};
  }
}

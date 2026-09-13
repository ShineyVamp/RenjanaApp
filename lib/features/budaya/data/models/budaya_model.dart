import 'dart:convert';

import '../../../../core/constants/budaya_kategori.dart';

class BudayaModel {
  final int? id;
  final String kodeTag;
  final String jenis;
  final int urutan;
  final String judul;
  final String kategoriLabel;
  final String tagline;
  final String deskripsi;
  final String gambarUtama;
  final String? maknaSpiritual;
  final String? gambarMaknaSpiritual;
  final String? konteksBudaya;
  final String? gambarKonteksBudaya;

  // provinsi asal
  final String? provinsi;

  // kontributor pengusul
  final String? kontributor;

  // rincian field khas kategori
  final Map<String, dynamic> detailKategori;

  // format media
  final String jenisMedia;

  // url atau path media
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

  // penanda destinasi wisata
  bool get isDestinasi =>
      kodeTag.trim().toUpperCase().endsWith(kodeDestinasiSuffix);

  // label nama kategori
  String get namaKategoriBudaya => namaKategori(jenis);

  // section pembacaan detail kategori

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

  // section serialisasi kolom detail kategori

  String get detailKategoriJson =>
      detailKategori.isEmpty ? '' : jsonEncode(detailKategori);

  // peta kolom sqlite
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

  // serialisasi firestore
  Map<String, dynamic> toFirestore() => {
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
    'detailKategori': detailKategori,
    'kontributor': kontributor,
    'jenisMedia': jenisMedia,
    'mediaUrl': mediaUrl,
  };

  factory BudayaModel.fromFirestore(Map<String, dynamic> map, [String? docId]) {
    final detail = map['detailKategori'];
    Map<String, dynamic> parsedDetail = {};
    if (detail is Map<String, dynamic>) {
      parsedDetail = detail;
    } else if (detail is Map) {
      parsedDetail = Map<String, dynamic>.from(detail);
    } else if (detail != null) {
      parsedDetail = detailDariJson(detail);
    }

    return BudayaModel(
      kodeTag: (map['kodeTag'] as String?)?.isNotEmpty == true
          ? map['kodeTag'] as String
          : (docId ?? 'BUD-SNJT-1'),
      jenis: map['jenis'] as String? ?? 'SNJT',
      urutan: (map['urutan'] as num?)?.toInt() ?? 1,
      judul: map['judul'] as String? ?? '',
      kategoriLabel: map['kategoriLabel'] as String? ?? 'SENJATA TRADISIONAL',
      tagline: map['tagline'] as String? ?? '',
      deskripsi: map['deskripsi'] as String? ?? '',
      gambarUtama: map['gambarUtama'] as String? ?? '',
      maknaSpiritual: map['maknaSpiritual'] as String?,
      gambarMaknaSpiritual: map['gambarMaknaSpiritual'] as String?,
      konteksBudaya: map['konteksBudaya'] as String?,
      gambarKonteksBudaya: map['gambarKonteksBudaya'] as String?,
      provinsi: map['provinsi'] as String?,
      detailKategori: parsedDetail,
      kontributor: map['kontributor'] as String?,
      jenisMedia: map['jenisMedia'] as String? ?? 'gambar',
      mediaUrl: map['mediaUrl'] as String?,
    );
  }

  // membaca kolom detailkategori
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

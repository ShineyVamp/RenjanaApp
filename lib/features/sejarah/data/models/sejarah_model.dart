import 'dart:convert';
import '../../../../core/constants/katalog_kategori.dart';

class TimelineItemModel {
  final String date;
  final String title;
  final String desc;
  final String? imgPath;
  final bool hasImage;

  const TimelineItemModel({
    required this.date,
    required this.title,
    required this.desc,
    this.imgPath,
    this.hasImage = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'title': title,
      'desc': desc,
      'imgPath': imgPath,
      'hasImage': hasImage,
    };
  }

  factory TimelineItemModel.fromMap(Map<String, dynamic> map) {
    return TimelineItemModel(
      date: map['date'] as String? ?? '',
      title: map['title'] as String? ?? '',
      desc: map['desc'] as String? ?? '',
      imgPath: map['imgPath'] as String?,
      hasImage: map['hasImage'] == true,
    );
  }
}

class SejarahModel {
  final int? id;
  final String kodeTag; // HIS-150845-1
  final String tanggalKey; // ddMMyy, mis. 150845
  final int urutan; // 1 = sorotan harian utama
  final String judul;
  final String subtitle;
  final String ringkasan;
  final String gambarUtama;
  final List<TimelineItemModel> alurPeristiwa;

  // Nama provinsi asal, mengikuti penulisan di data_wilayah_nusantara.dart.
  final String? provinsi;

  // Username pengusul, terisi bila arsip ini berasal dari usulan pengguna.
  final String? kontributor;

  // Periode zaman sejarah (kode: PRS, HND, ISL, KLN, NAS, REV, ORL, ORB, REF)
  final String? periode;

  // Jenis peristiwa sejarah (kode: PRG, PRJ, TKH, ORG, NSK, STS)
  final String? jenisPeristiwa;

  // Detail data peristiwa dinamis
  final Map<String, dynamic> detailPeristiwa;

  // Format media: 'gambar' (default), 'video', 'youtube'
  final String jenisMedia;

  // URL / Path video atau link YouTube (bila jenisMedia != 'gambar')
  final String? mediaUrl;

  const SejarahModel({
    this.id,
    required this.kodeTag,
    required this.tanggalKey,
    required this.urutan,
    required this.judul,
    required this.subtitle,
    required this.ringkasan,
    required this.gambarUtama,
    this.alurPeristiwa = const [],
    this.provinsi,
    this.kontributor,
    this.periode,
    this.jenisPeristiwa,
    this.detailPeristiwa = const {},
    this.jenisMedia = 'gambar',
    this.mediaUrl,
  });

  bool get isVideo => jenisMedia == 'video';
  bool get isYoutube => jenisMedia == 'youtube';
  bool get hasVideoMedia => isVideo || isYoutube;

  // Nama periode untuk ditampilkan
  String get namaPeriodeLabel => namaPeriode(periode ?? '');

  // Nama jenis peristiwa untuk ditampilkan
  String get namaPeristiwaLabel => namaPeristiwa(jenisPeristiwa ?? '');

  // Helper pembacaan detailPeristiwa
  String teksDetail(String kunci) {
    final nilai = detailPeristiwa[kunci];
    if (nilai is String) return nilai.trim();
    if (nilai is List) return nilai.join(', ');
    return '';
  }

  List<String> daftarDetail(String kunci) {
    final nilai = detailPeristiwa[kunci];
    if (nilai is List) {
      return nilai
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (nilai is String && nilai.trim().isNotEmpty) return [nilai.trim()];
    return const [];
  }

  bool adaDetail(String kunci) => detailPeristiwa[kunci] is List
      ? daftarDetail(kunci).isNotEmpty
      : teksDetail(kunci).isNotEmpty;

  String get detailPeristiwaJson =>
      detailPeristiwa.isEmpty ? '' : jsonEncode(detailPeristiwa);

  // serialisasi firestore
  Map<String, dynamic> toFirestore() => {
    'kodeTag': kodeTag,
    'tanggalKey': tanggalKey,
    'urutan': urutan,
    'judul': judul,
    'subtitle': subtitle,
    'ringkasan': ringkasan,
    'gambarUtama': gambarUtama,
    'alurPeristiwa': alurPeristiwa.map((i) => i.toMap()).toList(),
    'provinsi': provinsi,
    'kontributor': kontributor,
    'periode': periode,
    'jenisPeristiwa': jenisPeristiwa,
    'detailPeristiwa': detailPeristiwa,
    'jenisMedia': jenisMedia,
    'mediaUrl': mediaUrl,
  };

  factory SejarahModel.fromFirestore(Map<String, dynamic> map, [String? docId]) {
    List<TimelineItemModel> alur = [];
    final rawAlur = map['alurPeristiwa'];
    if (rawAlur is List) {
      for (final item in rawAlur) {
        if (item is Map<String, dynamic>) {
          alur.add(TimelineItemModel.fromMap(item));
        } else if (item is Map) {
          alur.add(TimelineItemModel.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    } else if (rawAlur is String && rawAlur.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawAlur);
        if (decoded is List) {
          alur = decoded
              .map((i) => TimelineItemModel.fromMap(i as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }

    final rawDetail = map['detailPeristiwa'];
    Map<String, dynamic> parsedDetail = {};
    if (rawDetail is Map<String, dynamic>) {
      parsedDetail = rawDetail;
    } else if (rawDetail is Map) {
      parsedDetail = Map<String, dynamic>.from(rawDetail);
    } else if (rawDetail != null) {
      parsedDetail = detailDariJson(rawDetail);
    }

    return SejarahModel(
      kodeTag: (map['kodeTag'] as String?)?.isNotEmpty == true
          ? map['kodeTag'] as String
          : (docId ?? 'HIS-01'),
      kontributor: map['kontributor'] as String?,
      tanggalKey: map['tanggalKey'] as String? ?? '170845',
      urutan: (map['urutan'] as num?)?.toInt() ?? 1,
      judul: map['judul'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      ringkasan: map['ringkasan'] as String? ?? '',
      gambarUtama:
          map['gambarUtama'] as String? ?? 'assets/images/1308history.png',
      alurPeristiwa: alur,
      provinsi: map['provinsi'] as String?,
      periode: map['periode'] as String?,
      jenisPeristiwa: map['jenisPeristiwa'] as String?,
      detailPeristiwa: parsedDetail,
      jenisMedia: map['jenisMedia'] as String? ?? 'gambar',
      mediaUrl: map['mediaUrl'] as String?,
    );
  }

  // membaca kolom detailperistiwa
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


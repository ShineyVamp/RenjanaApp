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

  // Nama provinsi asal, mengikuti penulisan di wilayah_nusantara.dart.
  final String? provinsi;

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
  });
}

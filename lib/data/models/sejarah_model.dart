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
  final String kodeTag; // Format: HIS-150845-1
  final String tanggalKey; // Format: 150845 (ddMMyy)
  final int urutan; // 1 = highlight harian utama
  final String judul;
  final String subtitle;
  final String ringkasan;
  final String gambarUtama; // Wajib (untuk card home & header detail)
  final List<TimelineItemModel> alurPeristiwa;

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
  });
}

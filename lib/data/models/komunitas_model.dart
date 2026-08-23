// Model diskusi pada forum komunitas lokal.
class DiskusiModel {
  final int? id;
  final int userId;
  final String penulis;
  final String judul;
  final String isi;
  final String kategori; // 'Umum', 'Sejarah', 'Budaya', 'Kedaerahan'
  final String? refArsip; // kodeTag arsip yang ditautkan, mis. 'HIS-01' atau 'BUD-SNJT-1'
  final DateTime dibuatPada;
  final DateTime diperbaruiPada;
  final int jumlahJawaban;
  final int jumlahSuara;
  final int suaraSaya; // 1 = upvote, 0 = netral

  const DiskusiModel({
    this.id,
    required this.userId,
    required this.penulis,
    required this.judul,
    required this.isi,
    this.kategori = 'Umum',
    this.refArsip,
    required this.dibuatPada,
    required this.diperbaruiPada,
    this.jumlahJawaban = 0,
    this.jumlahSuara = 0,
    this.suaraSaya = 0,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'penulis': penulis,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'refArsip': refArsip,
    'dibuatPada': dibuatPada.millisecondsSinceEpoch,
    'diperbaruiPada': diperbaruiPada.millisecondsSinceEpoch,
  };

  factory DiskusiModel.fromMap(
    Map<String, dynamic> map, {
    int jumlahJawaban = 0,
    int jumlahSuara = 0,
    int suaraSaya = 0,
  }) {
    return DiskusiModel(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      penulis: map['penulis'] as String? ?? 'Pengguna',
      judul: map['judul'] as String? ?? '',
      isi: map['isi'] as String? ?? '',
      kategori: map['kategori'] as String? ?? 'Umum',
      refArsip: map['refArsip'] as String?,
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuatPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      diperbaruiPada: DateTime.fromMillisecondsSinceEpoch(
        map['diperbaruiPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      jumlahJawaban: jumlahJawaban,
      jumlahSuara: jumlahSuara,
      suaraSaya: suaraSaya,
    );
  }
}

// Model tanggapan/jawaban pada suatu diskusi.
class JawabanModel {
  final int? id;
  final int diskusiId;
  final int userId;
  final String penulis;
  final String isi;
  final DateTime dibuatPada;
  final int jumlahSuara;
  final int suaraSaya;

  const JawabanModel({
    this.id,
    required this.diskusiId,
    required this.userId,
    required this.penulis,
    required this.isi,
    required this.dibuatPada,
    this.jumlahSuara = 0,
    this.suaraSaya = 0,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'diskusiId': diskusiId,
    'userId': userId,
    'penulis': penulis,
    'isi': isi,
    'dibuatPada': dibuatPada.millisecondsSinceEpoch,
  };

  factory JawabanModel.fromMap(
    Map<String, dynamic> map, {
    int jumlahSuara = 0,
    int suaraSaya = 0,
  }) {
    return JawabanModel(
      id: map['id'] as int?,
      diskusiId: map['diskusiId'] as int? ?? 0,
      userId: map['userId'] as int? ?? 0,
      penulis: map['penulis'] as String? ?? 'Pengguna',
      isi: map['isi'] as String? ?? '',
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuatPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      jumlahSuara: jumlahSuara,
      suaraSaya: suaraSaya,
    );
  }
}

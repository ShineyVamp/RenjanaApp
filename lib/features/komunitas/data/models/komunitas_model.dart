// model diskusi
class DiskusiModel {
  final int? id;
  final int userId;
  final String penulis;
  final String? username;
  final String judul;
  final String isi;
  final String kategori;
  final String? refArsip;
  final DateTime dibuatPada;
  final DateTime diperbaruiPada;
  final int jumlahJawaban;
  final int jumlahSuara;
  final int suaraSaya;
  final String role;
  final String gelar;
  final List<String> badgePilihan;

  const DiskusiModel({
    this.id,
    required this.userId,
    required this.penulis,
    this.username,
    required this.judul,
    required this.isi,
    this.kategori = 'Umum',
    this.refArsip,
    required this.dibuatPada,
    required this.diperbaruiPada,
    this.jumlahJawaban = 0,
    this.jumlahSuara = 0,
    this.suaraSaya = 0,
    this.role = 'user',
    this.gelar = 'Pelajar',
    this.badgePilihan = const [],
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
    String role = 'user',
    String? username,
    String gelar = 'Pelajar',
    List<String> badgePilihan = const [],
  }) {
    return DiskusiModel(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      penulis: map['penulis'] as String? ?? 'Pengguna',
      username: username ?? (map['username'] as String?),
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
      role: role,
      gelar: gelar,
      badgePilihan: badgePilihan,
    );
  }
}

// model jawaban dan balasan
class JawabanModel {
  final int? id;
  final int diskusiId;
  final int? indukId;
  final String? balasKe;
  final int userId;
  final String penulis;
  final String? username;
  final String isi;
  final DateTime dibuatPada;
  final int jumlahSuara;
  final int suaraSaya;
  final int jumlahBalasan;
  final String role;
  final String gelar;
  final List<String> badgePilihan;

  const JawabanModel({
    this.id,
    required this.diskusiId,
    this.indukId,
    this.balasKe,
    required this.userId,
    required this.penulis,
    this.username,
    required this.isi,
    required this.dibuatPada,
    this.jumlahSuara = 0,
    this.suaraSaya = 0,
    this.jumlahBalasan = 0,
    this.role = 'user',
    this.gelar = 'Pelajar',
    this.badgePilihan = const [],
  });

  bool get isBalasan => indukId != null && indukId! > 0;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'diskusiId': diskusiId,
    'indukId': indukId,
    'balasKe': balasKe,
    'userId': userId,
    'penulis': penulis,
    'isi': isi,
    'dibuatPada': dibuatPada.millisecondsSinceEpoch,
  };

  factory JawabanModel.fromMap(
    Map<String, dynamic> map, {
    int jumlahSuara = 0,
    int suaraSaya = 0,
    int jumlahBalasan = 0,
    String role = 'user',
    String? username,
    String gelar = 'Pelajar',
    List<String> badgePilihan = const [],
  }) {
    return JawabanModel(
      id: map['id'] as int?,
      diskusiId: map['diskusiId'] as int? ?? 0,
      indukId: map['indukId'] as int?,
      balasKe: map['balasKe'] as String?,
      userId: map['userId'] as int? ?? 0,
      penulis: map['penulis'] as String? ?? 'Pengguna',
      username: username ?? (map['username'] as String?),
      isi: map['isi'] as String? ?? '',
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuatPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      jumlahSuara: jumlahSuara,
      suaraSaya: suaraSaya,
      jumlahBalasan: jumlahBalasan,
      role: role,
      gelar: gelar,
      badgePilihan: badgePilihan,
    );
  }
}


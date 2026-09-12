// model diskusi
class DiskusiModel {
  final int? id;
  final int userId;
  final String penulis;
  final String? username;
  final String? fotoProfil;
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
    this.fotoProfil,
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

  DiskusiModel copyWith({
    int? jumlahSuara,
    int? suaraSaya,
    int? jumlahJawaban,
  }) {
    return DiskusiModel(
      id: id,
      userId: userId,
      penulis: penulis,
      username: username,
      fotoProfil: fotoProfil,
      judul: judul,
      isi: isi,
      kategori: kategori,
      refArsip: refArsip,
      dibuatPada: dibuatPada,
      diperbaruiPada: diperbaruiPada,
      jumlahJawaban: jumlahJawaban ?? this.jumlahJawaban,
      jumlahSuara: jumlahSuara ?? this.jumlahSuara,
      suaraSaya: suaraSaya ?? this.suaraSaya,
      role: role,
      gelar: gelar,
      badgePilihan: badgePilihan,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'userId': userId,
    'penulis': penulis,
    if (username != null) 'username': username,
    if (fotoProfil != null) 'fotoProfil': fotoProfil,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'refArsip': refArsip,
    'jumlahSuara': jumlahSuara,
    'jumlahJawaban': jumlahJawaban,
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
    String? fotoProfil,
    String gelar = 'Pelajar',
    List<String> badgePilihan = const [],
  }) {
    final suara = jumlahSuara != 0
        ? jumlahSuara
        : (map['jumlahSuara'] as num?)?.toInt() ?? 0;
    final jawaban = jumlahJawaban != 0
        ? jumlahJawaban
        : (map['jumlahJawaban'] as num?)?.toInt() ?? 0;
    final suaraAktif = suaraSaya != 0
        ? suaraSaya
        : (map['suaraSaya'] as num?)?.toInt() ?? 0;

    return DiskusiModel(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      penulis: map['penulis'] as String? ?? 'Pengguna',
      username: username ?? (map['username'] as String?),
      fotoProfil: fotoProfil ?? (map['fotoProfil'] as String?),
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
      jumlahJawaban: jawaban,
      jumlahSuara: suara,
      suaraSaya: suaraAktif,
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
  final String? fotoProfil;
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
    this.fotoProfil,
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

  JawabanModel copyWith({
    int? jumlahSuara,
    int? suaraSaya,
    int? jumlahBalasan,
  }) {
    return JawabanModel(
      id: id,
      diskusiId: diskusiId,
      indukId: indukId,
      balasKe: balasKe,
      userId: userId,
      penulis: penulis,
      username: username,
      fotoProfil: fotoProfil,
      isi: isi,
      dibuatPada: dibuatPada,
      jumlahSuara: jumlahSuara ?? this.jumlahSuara,
      suaraSaya: suaraSaya ?? this.suaraSaya,
      jumlahBalasan: jumlahBalasan ?? this.jumlahBalasan,
      role: role,
      gelar: gelar,
      badgePilihan: badgePilihan,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'diskusiId': diskusiId,
    'indukId': indukId,
    'balasKe': balasKe,
    'userId': userId,
    'penulis': penulis,
    if (username != null) 'username': username,
    if (fotoProfil != null) 'fotoProfil': fotoProfil,
    'isi': isi,
    'jumlahSuara': jumlahSuara,
    'jumlahBalasan': jumlahBalasan,
    'dibuatPada': dibuatPada.millisecondsSinceEpoch,
  };

  factory JawabanModel.fromMap(
    Map<String, dynamic> map, {
    int jumlahSuara = 0,
    int suaraSaya = 0,
    int jumlahBalasan = 0,
    String role = 'user',
    String? username,
    String? fotoProfil,
    String gelar = 'Pelajar',
    List<String> badgePilihan = const [],
  }) {
    final suara = jumlahSuara != 0
        ? jumlahSuara
        : (map['jumlahSuara'] as num?)?.toInt() ?? 0;
    final suaraAktif = suaraSaya != 0
        ? suaraSaya
        : (map['suaraSaya'] as num?)?.toInt() ?? 0;
    final totalBalasan = jumlahBalasan != 0
        ? jumlahBalasan
        : (map['jumlahBalasan'] as num?)?.toInt() ?? 0;

    return JawabanModel(
      id: map['id'] as int?,
      diskusiId: map['diskusiId'] as int? ?? 0,
      indukId: map['indukId'] as int?,
      balasKe: map['balasKe'] as String?,
      userId: map['userId'] as int? ?? 0,
      penulis: map['penulis'] as String? ?? 'Pengguna',
      username: username ?? (map['username'] as String?),
      fotoProfil: fotoProfil ?? (map['fotoProfil'] as String?),
      isi: map['isi'] as String? ?? '',
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuatPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      jumlahSuara: suara,
      suaraSaya: suaraAktif,
      jumlahBalasan: totalBalasan,
      role: role,
      gelar: gelar,
      badgePilihan: badgePilihan,
    );
  }
}

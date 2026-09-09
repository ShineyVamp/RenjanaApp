// model notifikasi komunitas
class NotifikasiKomunitasModel {
  final int? id;
  final int userId;
  final String userNama;
  final String userUsername;
  final int? pengirimId;
  final String pengirimNama;
  final String pengirimUsername;
  final String tipe; // 'tag' atau 'balas'
  final int diskusiId;
  final int? jawabanId;
  final int? indukJawabanId;
  final String judulDiskusi;
  final String cuplikanTeks;
  final bool sudahDibaca;
  final DateTime dibuatPada;

  const NotifikasiKomunitasModel({
    this.id,
    required this.userId,
    required this.userNama,
    required this.userUsername,
    this.pengirimId,
    required this.pengirimNama,
    required this.pengirimUsername,
    required this.tipe,
    required this.diskusiId,
    this.jawabanId,
    this.indukJawabanId,
    required this.judulDiskusi,
    required this.cuplikanTeks,
    this.sudahDibaca = false,
    required this.dibuatPada,
  });

  bool get isTag => tipe == 'tag';
  bool get isBalas => tipe == 'balas';
  bool get isThreadBalasan => indukJawabanId != null && indukJawabanId! > 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userNama': userNama,
      'userUsername': userUsername,
      'pengirimId': pengirimId,
      'pengirimNama': pengirimNama,
      'pengirimUsername': pengirimUsername,
      'tipe': tipe,
      'diskusiId': diskusiId,
      'jawabanId': jawabanId,
      'indukJawabanId': indukJawabanId,
      'judulDiskusi': judulDiskusi,
      'cuplikanTeks': cuplikanTeks,
      'sudahDibaca': sudahDibaca ? 1 : 0,
      'dibuatPada': dibuatPada.millisecondsSinceEpoch,
    };
  }

  factory NotifikasiKomunitasModel.fromMap(Map<String, dynamic> map) {
    return NotifikasiKomunitasModel(
      id: map['id'] as int?,
      userId: map['userId'] as int? ?? 0,
      userNama: map['userNama'] as String? ?? '',
      userUsername: map['userUsername'] as String? ?? '',
      pengirimId: map['pengirimId'] as int?,
      pengirimNama: map['pengirimNama'] as String? ?? '',
      pengirimUsername: map['pengirimUsername'] as String? ?? '',
      tipe: map['tipe'] as String? ?? 'balas',
      diskusiId: map['diskusiId'] as int? ?? 0,
      jawabanId: map['jawabanId'] as int?,
      indukJawabanId: map['indukJawabanId'] as int?,
      judulDiskusi: map['judulDiskusi'] as String? ?? '',
      cuplikanTeks: map['cuplikanTeks'] as String? ?? '',
      sudahDibaca: (map['sudahDibaca'] as int? ?? 0) == 1,
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuatPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

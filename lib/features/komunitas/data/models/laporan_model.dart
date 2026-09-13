// model laporan moderasi konten
class LaporanModel {
  final int? id;
  final String targetTipe;
  final String targetId;
  final String? kontenTeks;
  final String pelapor;
  final String alasan;
  final String status;
  final DateTime dibuatPada;

  const LaporanModel({
    this.id,
    required this.targetTipe,
    required this.targetId,
    this.kontenTeks,
    required this.pelapor,
    required this.alasan,
    this.status = 'menunggu',
    required this.dibuatPada,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'targetTipe': targetTipe,
    'targetId': targetId,
    'kontenTeks': kontenTeks,
    'pelapor': pelapor,
    'alasan': alasan,
    'status': status,
    'dibuatPada': dibuatPada.millisecondsSinceEpoch,
  };

  factory LaporanModel.fromMap(Map<String, dynamic> map) {
    return LaporanModel(
      id: map['id'] as int?,
      targetTipe: map['targetTipe'] as String? ?? '',
      targetId: map['targetId']?.toString() ?? '',
      kontenTeks: map['kontenTeks'] as String?,
      pelapor: map['pelapor'] as String? ?? 'Anonim',
      alasan: map['alasan'] as String? ?? 'Lainnya',
      status: map['status'] as String? ?? 'menunggu',
      dibuatPada: DateTime.fromMillisecondsSinceEpoch(
        map['dibuatPada'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}

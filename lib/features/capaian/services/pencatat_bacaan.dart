import 'dart:async';

import 'package:renjana/features/capaian/data/repositories/arsip_dibaca_repository.dart';

// layanan pencatat bacaan
class PencatatBacaan {
  static const int totalDetik = 10;
  static const Duration ambangBaca = Duration(seconds: totalDetik);

  final ArsipDibacaRepository _repository;
  Timer? _ticker;
  int _detikTersisa = totalDetik;
  bool _sudahSelesai = false;

  int get detikTersisa => _detikTersisa;
  bool get sudahSelesai => _sudahSelesai;

  PencatatBacaan({ArsipDibacaRepository? repository})
    : _repository = repository ?? ArsipDibacaRepository();

  // mulai timer bacaan
  void mulai(
    String jenis,
    String kodeTag, {
    void Function(int detikTersisa)? onTick,
    void Function()? onSelesai,
  }) {
    batalkan();
    _detikTersisa = totalDetik;
    _sudahSelesai = false;

    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_detikTersisa > 1) {
        _detikTersisa--;
        onTick?.call(_detikTersisa);
      } else {
        _detikTersisa = 0;
        _sudahSelesai = true;
        _ticker?.cancel();
        _ticker = null;
        _repository.catat(jenis, kodeTag);
        onTick?.call(0);
        onSelesai?.call();
      }
    });
  }

  // batalkan timer
  void batalkan() {
    _ticker?.cancel();
    _ticker = null;
  }
}

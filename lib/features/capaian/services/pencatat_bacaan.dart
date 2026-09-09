import 'dart:async';

import 'package:renjana/features/capaian/data/repositories/arsip_dibaca_repository.dart';

// Menunda pencatatan arsip sampai halamannya dibuka cukup lama, supaya
// membuka lalu langsung menutup tidak terhitung sebagai membaca.
//
// Dipasang di initState halaman detail dan dibatalkan di dispose.
class PencatatBacaan {
  static const Duration ambangBaca = Duration(seconds: 10);

  final ArsipDibacaRepository _repository;
  Timer? _timer;

  PencatatBacaan({ArsipDibacaRepository? repository})
    : _repository = repository ?? ArsipDibacaRepository();

  void mulai(String jenis, String kodeTag) {
    _timer?.cancel();
    _timer = Timer(ambangBaca, () => _repository.catat(jenis, kodeTag));
  }

  void batalkan() {
    _timer?.cancel();
    _timer = null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../static/data_wilayah_nusantara.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import 'package:renjana/features/jelajah/data/models/hasil_jelajah_model.dart';
import 'package:renjana/features/capaian/data/repositories/arsip_dibaca_repository.dart';
import 'wilayah_repository.dart';

// enum tingkat penuntasan provinsi
enum TingkatWilayah { belum, dikunjungi, tuntas, dikuasai }

extension RupaTingkat on TingkatWilayah {
  Color get warna {
    switch (this) {
      case TingkatWilayah.dikuasai:
      case TingkatWilayah.tuntas:
        return AppColors.gold;
      case TingkatWilayah.dikunjungi:
        return AppColors.perunggu;
      case TingkatWilayah.belum:
        return AppColors.border;
    }
  }

  bool get adaCapaian => this != TingkatWilayah.belum;

  String get label {
    switch (this) {
      case TingkatWilayah.belum:
        return 'Belum dijelajahi';
      case TingkatWilayah.dikunjungi:
        return 'Dikunjungi';
      case TingkatWilayah.tuntas:
        return 'Tuntas';
      case TingkatWilayah.dikuasai:
        return 'Dikuasai';
    }
  }
}

// model capaian penuntasan provinsi
class ProgresProvinsi {
  final String provinsi;
  final TingkatWilayah tingkat;
  final int jumlahArsip;
  final int arsipDibaca;

  // section arsip
  final List<HasilJelajah> belumDibaca;
  final List<HasilJelajah> sudahDibaca;

  // section pembaruan arsip
  final bool adaArsipBaru;
  final int selisihArsipBaru;

  const ProgresProvinsi({
    required this.provinsi,
    required this.tingkat,
    required this.jumlahArsip,
    required this.arsipDibaca,
    this.belumDibaca = const [],
    this.sudahDibaca = const [],
    this.adaArsipBaru = false,
    this.selisihArsipBaru = 0,
  });

  bool get semuaDibaca => jumlahArsip > 0 && arsipDibaca >= jumlahArsip;
}

class ProgresWilayahRepository {
  final FirebaseFirestore _firestore;
  final WilayahRepository _wilayahRepository;
  final ArsipDibacaRepository _arsipDibacaRepository;

  static Map<String, Map<String, Object?>>? _cachedCatatan;
  static String? _cachedUser;

  ProgresWilayahRepository({
    FirebaseFirestore? firestore,
    WilayahRepository? wilayahRepository,
    ArsipDibacaRepository? arsipDibacaRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _wilayahRepository = wilayahRepository ?? WilayahRepository(),
        _arsipDibacaRepository =
            arsipDibacaRepository ?? ArsipDibacaRepository();

  // section identitas pengguna
  String get _userUid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final fUser = FirebaseAuth.instance.currentUser;
    if (fUser != null && fUser.uid.isNotEmpty) return fUser.uid;
    final intId = idAkunAktif;
    if (intId > 0) return 'user_$intId';
    return 'guest';
  }

  // section koleksi progres wilayah
  CollectionReference<Map<String, dynamic>> _koleksi() {
    return _firestore
        .collection('users')
        .doc(_userUid)
        .collection('progres_wilayah');
  }

  // section bersihkan cache
  static void bersihkanCache() {
    _cachedCatatan = null;
    _cachedUser = null;
  }

  Future<Map<String, Map<String, Object?>>> _catatan() async {
    final uid = _userUid;
    if (uid == 'guest') return {};

    if (_cachedCatatan != null && _cachedUser == uid) {
      return _cachedCatatan!;
    }

    try {
      final snap = await _koleksi().get().timeout(const Duration(seconds: 10));
      final map = <String, Map<String, Object?>>{};
      for (final doc in snap.docs) {
        final d = doc.data();
        final prov = (d['provinsi'] as String? ?? doc.id).toLowerCase();
        map[prov] = d;
      }
      _cachedCatatan = map;
      _cachedUser = uid;
      return map;
    } catch (_) {
      if (_cachedUser != uid) return const {};
      return _cachedCatatan ?? const {};
    }
  }

  Future<void> _simpan(
    String provinsi,
    TingkatWilayah tingkat,
    int arsip,
  ) async {
    final uid = _userUid;
    if (uid == 'guest') return;

    final provKey = provinsi.toLowerCase();
    final data = <String, Object?>{
      'provinsi': provinsi,
      'tingkat': tingkat.name,
      'jumlahArsip': arsip,
      'diperbaruiPada': DateTime.now().millisecondsSinceEpoch,
    };

    if (_cachedUser == uid) {
      _cachedCatatan?[provKey] = data;
    }

    try {
      await _koleksi().doc(provKey).set(data, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<Set<String>> _refDibaca() => _arsipDibacaRepository.himpunan();

  Future<ProgresProvinsi> progresProvinsi(String namaProvinsi) async {
    final arsip = await _wilayahRepository.arsipProvinsi(namaProvinsi);
    final dibaca = await _refDibaca();
    final catatan = await _catatan();
    return _hitung(namaProvinsi, arsip, dibaca, catatan, simpan: true);
  }

  // section pemetaan penuntasan seluruh provinsi
  Future<Map<String, TingkatWilayah>> tingkatSemuaProvinsi() async {
    final kelompok = await _wilayahRepository.arsipPerProvinsi();
    final dibaca = await _refDibaca();
    final catatan = await _catatan();

    final hasil = <String, TingkatWilayah>{};
    for (final provinsi in semuaProvinsi) {
      final kunci = provinsi.nama.toLowerCase();
      final progres = await _hitung(
        provinsi.nama,
        kelompok[kunci] ?? const [],
        dibaca,
        catatan,
        simpan: false,
      );
      hasil[kunci] = progres.tingkat;
    }
    return hasil;
  }

  Future<ProgresProvinsi> _hitung(
    String namaProvinsi,
    List<HasilJelajah> arsip,
    Set<String> dibaca,
    Map<String, Map<String, Object?>> catatan, {
    required bool simpan,
  }) async {
    final belum = arsip
        .where((item) => !dibaca.contains(item.refRiwayat))
        .toList();
    final sudah = arsip
        .where((item) => dibaca.contains(item.refRiwayat))
        .toList();
    final terbaca = arsip.length - belum.length;

    final semua = arsip.isNotEmpty && belum.isEmpty;
    final TingkatWilayah tingkat;
    if (terbaca == 0) {
      tingkat = TingkatWilayah.belum;
    } else if (!semua) {
      tingkat = TingkatWilayah.dikunjungi;
    } else {
      tingkat = TingkatWilayah.tuntas;
    }

    final rekam = catatan[namaProvinsi.toLowerCase()];
    final arsipTercatat = (rekam?['jumlahArsip'] as num?)?.toInt() ?? 0;
    final tingkatTercatat = rekam?['tingkat'] as String? ?? '';
    final pernahTuntas =
        tingkatTercatat == TingkatWilayah.tuntas.name ||
        tingkatTercatat == TingkatWilayah.dikuasai.name;
    final adaBaru = pernahTuntas && arsip.length > arsipTercatat;

    if (simpan) await _simpan(namaProvinsi, tingkat, arsip.length);

    return ProgresProvinsi(
      provinsi: namaProvinsi,
      tingkat: tingkat,
      jumlahArsip: arsip.length,
      arsipDibaca: terbaca,
      belumDibaca: belum,
      sudahDibaca: sudah,
      adaArsipBaru: adaBaru,
      selisihArsipBaru: adaBaru ? arsip.length - arsipTercatat : 0,
    );
  }
}

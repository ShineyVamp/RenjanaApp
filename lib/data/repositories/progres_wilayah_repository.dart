import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../local/db_helper.dart';
import 'pemilik_akun.dart';
import '../models/hasil_jelajah_model.dart';
import '../models/hasil_kuis_model.dart';
import 'arsip_dibaca_repository.dart';
import 'hasil_kuis_repository.dart';
import 'wilayah_repository.dart';

// Tingkat penuntasan satu provinsi.
enum TingkatWilayah { belum, dikunjungi, tuntas, dikuasai }

extension RupaTingkat on TingkatWilayah {
  // Warna capaian, dipakai penanda peta dan kartu penuntasan.
  Color get warna {
    switch (this) {
      case TingkatWilayah.dikuasai:
        return AppColors.gold;
      case TingkatWilayah.tuntas:
        return AppColors.perak;
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

// Kemajuan satu provinsi beserta rincian apa saja yang belum diselesaikan.
class ProgresProvinsi {
  final String provinsi;
  final TingkatWilayah tingkat;
  final int jumlahArsip;
  final int arsipDibaca;

  // Arsip provinsi ini yang belum pernah dibuka.
  final List<HasilJelajah> belumDibaca;

  // Tema kuis provinsi ini sudah pernah dikerjakan tanpa salah.
  final bool kuisSempurna;
  final String temaKuis;

  // Arsip provinsi ini bertambah setelah terakhir kali tingkatnya dicatat.
  final bool adaArsipBaru;
  final int selisihArsipBaru;

  const ProgresProvinsi({
    required this.provinsi,
    required this.tingkat,
    required this.jumlahArsip,
    required this.arsipDibaca,
    this.belumDibaca = const [],
    this.kuisSempurna = false,
    this.temaKuis = '',
    this.adaArsipBaru = false,
    this.selisihArsipBaru = 0,
  });

  bool get semuaDibaca => jumlahArsip > 0 && arsipDibaca >= jumlahArsip;
}

// Menghitung tingkat penuntasan tiap provinsi dari arsip yang sudah dibuka
// dan rekor kuis, lalu menyimpan tingkat terakhir beserta jumlah arsip saat
// itu ke tabel `progres_wilayah`.
class ProgresWilayahRepository {
  final DbHelper _dbHelper;
  final WilayahRepository _wilayahRepository;
  final ArsipDibacaRepository _arsipDibacaRepository;
  final HasilKuisRepository _hasilKuisRepository;

  ProgresWilayahRepository({
    DbHelper? dbHelper,
    WilayahRepository? wilayahRepository,
    ArsipDibacaRepository? arsipDibacaRepository,
    HasilKuisRepository? hasilKuisRepository,
  }) : _dbHelper = dbHelper ?? DbHelper(),
       _wilayahRepository = wilayahRepository ?? WilayahRepository(),
       _arsipDibacaRepository =
           arsipDibacaRepository ?? ArsipDibacaRepository(),
       _hasilKuisRepository = hasilKuisRepository ?? HasilKuisRepository();

  // Nama tema kuis untuk satu provinsi, mengikuti penamaan di seed.
  static String temaKuisProvinsi(String provinsi) => 'Kekayaan $provinsi';

  int get _pemilik => idAkunAktif;

  Future<Map<String, Map<String, Object?>>> _catatan() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return {};

    final db = await _dbHelper.database;
    final baris = await db.query(
      'progres_wilayah',
      where: 'userId = ?',
      whereArgs: [pemilik],
    );
    return {
      for (final r in baris) (r['provinsi'] as String? ?? '').toLowerCase(): r,
    };
  }

  Future<void> _simpan(
    String provinsi,
    TingkatWilayah tingkat,
    int arsip,
  ) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return;

    final db = await _dbHelper.database;
    await db.insert('progres_wilayah', {
      'userId': pemilik,
      'provinsi': provinsi,
      'tingkat': tingkat.name,
      'jumlahArsip': arsip,
      'diperbaruiPada': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Kunci referensi arsip yang pernah dibaca, mis. 'budaya|BUD-RMH-1-D'.
  Future<Set<String>> _refDibaca() => _arsipDibacaRepository.himpunan();

  Future<ProgresProvinsi> progresProvinsi(String namaProvinsi) async {
    final arsip = await _wilayahRepository.arsipProvinsi(namaProvinsi);
    final dibaca = await _refDibaca();
    final catatan = await _catatan();
    final rekor = await _hasilKuisRepository.rekorPerTema();
    return _hitung(namaProvinsi, arsip, dibaca, catatan, rekor, simpan: true);
  }

  // Tingkat seluruh provinsi sekaligus, untuk pewarnaan penanda peta.
  // Seluruh bahannya dibaca sekali lalu dibagi di memori.
  Future<Map<String, TingkatWilayah>> tingkatSemuaProvinsi() async {
    final kelompok = await _wilayahRepository.arsipPerProvinsi();
    final dibaca = await _refDibaca();
    final catatan = await _catatan();
    final rekor = await _hasilKuisRepository.rekorPerTema();

    final hasil = <String, TingkatWilayah>{};
    for (final provinsi in semuaProvinsi) {
      final kunci = provinsi.nama.toLowerCase();
      final progres = await _hitung(
        provinsi.nama,
        kelompok[kunci] ?? const [],
        dibaca,
        catatan,
        rekor,
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
    Map<String, Map<String, Object?>> catatan,
    Map<String, HasilKuis> rekor, {
    required bool simpan,
  }) async {
    final belum = arsip
        .where((item) => !dibaca.contains(item.refRiwayat))
        .toList();
    final terbaca = arsip.length - belum.length;

    final tema = temaKuisProvinsi(namaProvinsi);
    final sempurna = rekor[tema.toLowerCase()]?.sempurna ?? false;

    final semua = arsip.isNotEmpty && belum.isEmpty;
    final TingkatWilayah tingkat;
    if (terbaca == 0) {
      tingkat = TingkatWilayah.belum;
    } else if (!semua) {
      tingkat = TingkatWilayah.dikunjungi;
    } else if (sempurna) {
      tingkat = TingkatWilayah.dikuasai;
    } else {
      tingkat = TingkatWilayah.tuntas;
    }

    // Provinsi yang tingkatnya pernah tuntas lalu bertambah arsipnya ditandai
    // agar penggunanya tahu ada yang perlu dibaca lagi.
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
      kuisSempurna: sempurna,
      temaKuis: tema,
      adaArsipBaru: adaBaru,
      selisihArsipBaru: adaBaru ? arsip.length - arsipTercatat : 0,
    );
  }
}

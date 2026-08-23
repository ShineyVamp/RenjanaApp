import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'budaya_model.dart';
import 'sejarah_model.dart';

// Jenis arsip yang diusulkan. Nilainya ikut tersimpan di kolom `jenis`.
enum JenisUsulan { sejarah, budaya, kuis }

// Usulan bisa berupa arsip baru atau perbaikan arsip yang sudah terbit.
enum MaksudUsulan { baru, koreksi }

// Perjalanan sebuah usulan sampai diputuskan admin.
enum StatusUsulan { menunggu, revisi, disetujui, ditolak }

extension RupaJenisUsulan on JenisUsulan {
  String get label {
    switch (this) {
      case JenisUsulan.sejarah:
        return 'Sejarah';
      case JenisUsulan.budaya:
        return 'Budaya';
      case JenisUsulan.kuis:
        return 'Tema Kuis';
    }
  }

  IconData get ikon {
    switch (this) {
      case JenisUsulan.sejarah:
        return Icons.history_edu_rounded;
      case JenisUsulan.budaya:
        return Icons.temple_hindu_rounded;
      case JenisUsulan.kuis:
        return Icons.quiz_rounded;
    }
  }
}

extension RupaStatusUsulan on StatusUsulan {
  String get label {
    switch (this) {
      case StatusUsulan.menunggu:
        return 'Menunggu';
      case StatusUsulan.revisi:
        return 'Perlu Perbaikan';
      case StatusUsulan.disetujui:
        return 'Disetujui';
      case StatusUsulan.ditolak:
        return 'Ditolak';
    }
  }

  Color get warna {
    switch (this) {
      case StatusUsulan.menunggu:
        return AppColors.perunggu;
      case StatusUsulan.revisi:
        return AppColors.warning;
      case StatusUsulan.disetujui:
        return AppColors.gold;
      case StatusUsulan.ditolak:
        return AppColors.error;
    }
  }

  IconData get ikon {
    switch (this) {
      case StatusUsulan.menunggu:
        return Icons.hourglass_empty_rounded;
      case StatusUsulan.revisi:
        return Icons.edit_note_rounded;
      case StatusUsulan.disetujui:
        return Icons.verified_rounded;
      case StatusUsulan.ditolak:
        return Icons.cancel_outlined;
    }
  }

  // Usulan yang masih bisa disunting pengusulnya.
  bool get bisaDisunting =>
      this == StatusUsulan.menunggu || this == StatusUsulan.revisi;

  // Usulan yang masih menunggu keputusan admin.
  bool get terbuka =>
      this == StatusUsulan.menunggu || this == StatusUsulan.revisi;
}

// Kunci di dalam muatan `isi`. Dikumpulkan di sini supaya form pengguna dan
// panel admin membaca nama yang sama persis.
class KunciUsulan {
  KunciUsulan._();

  // dipakai semua jenis
  static const String gambar = 'gambar';
  static const String judul = 'judul';
  static const String jenisMedia = 'jenisMedia';
  static const String mediaUrl = 'mediaUrl';

  // sejarah
  static const String subtitle = 'subtitle';
  static const String tanggalKey = 'tanggalKey';
  static const String ringkasan = 'ringkasan';
  static const String periode = 'periode';
  static const String jenisPeristiwa = 'jenisPeristiwa';
  static const String detailPeristiwa = 'detailPeristiwa';

  // daftar peristiwa: {tanggal, judul, keterangan}
  static const String alurPeristiwa = 'alurPeristiwa';

  // budaya
  static const String kategori = 'kategori';
  static const String tagline = 'tagline';
  static const String deskripsi = 'deskripsi';
  static const String maknaSpiritual = 'maknaSpiritual';
  static const String konteksBudaya = 'konteksBudaya';
  static const String detailKategori = 'detailKategori';
  static const String destinasi = 'destinasi';

  // tema kuis
  static const String tema = 'tema';
  static const String kategoriKuis = 'kategoriKuis';
  static const String subKategori = 'subKategori';

  // daftar soal: {soal, jawaban[4], benar, penjelasan}
  static const String soal = 'soal';

  // Salinan arsip sebelum dikoreksi, dipakai memulihkannya bila admin menarik
  // kembali persetujuan.
  static const String cadangan = 'cadangan';
}

// Satu usulan konten, isi tabel `usulan`.
class Usulan {
  final int? id;
  final JenisUsulan jenis;
  final MaksudUsulan maksud;

  // Arsip yang dikoreksi; kosong pada usulan arsip baru.
  final String targetKodeTag;

  final String provinsi;

  // Ringkasan satu baris untuk daftar, diambil dari judul isian.
  final String judul;

  // Muatan usulan, bentuknya berbeda tiap jenis.
  final Map<String, dynamic> isi;

  final StatusUsulan status;
  final String catatanAdmin;

  // ID tag arsip yang terbit setelah usulan disetujui.
  final String kodeTagHasil;

  final DateTime dibuatPada;
  final DateTime diperbaruiPada;

  const Usulan({
    this.id,
    required this.jenis,
    this.maksud = MaksudUsulan.baru,
    this.targetKodeTag = '',
    required this.provinsi,
    required this.judul,
    this.isi = const {},
    this.status = StatusUsulan.menunggu,
    this.catatanAdmin = '',
    this.kodeTagHasil = '',
    required this.dibuatPada,
    required this.diperbaruiPada,
  });

  bool get koreksi => maksud == MaksudUsulan.koreksi;

  String teks(String kunci) => (isi[kunci] as Object?)?.toString().trim() ?? '';

  // Nilai daftar pada muatan, mis. pilihan jawaban atau alur peristiwa.
  List<Map<String, dynamic>> daftar(String kunci) {
    final nilai = isi[kunci];
    if (nilai is! List) return const [];
    return nilai.whereType<Map>().map(Map<String, dynamic>.from).toList();
  }

  Usulan salin({
    JenisUsulan? jenis,
    MaksudUsulan? maksud,
    String? targetKodeTag,
    String? provinsi,
    String? judul,
    Map<String, dynamic>? isi,
    StatusUsulan? status,
    String? catatanAdmin,
    String? kodeTagHasil,
    DateTime? diperbaruiPada,
  }) {
    return Usulan(
      id: id,
      jenis: jenis ?? this.jenis,
      maksud: maksud ?? this.maksud,
      targetKodeTag: targetKodeTag ?? this.targetKodeTag,
      provinsi: provinsi ?? this.provinsi,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      status: status ?? this.status,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      kodeTagHasil: kodeTagHasil ?? this.kodeTagHasil,
      dibuatPada: dibuatPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }

  Map<String, Object?> toKolom(int userId) => {
    'userId': userId,
    'jenis': jenis.name,
    'maksud': maksud.name,
    'targetKodeTag': targetKodeTag,
    'provinsi': provinsi,
    'judul': judul,
    'isi': jsonEncode(isi),
    'status': status.name,
    'catatanAdmin': catatanAdmin,
    'kodeTagHasil': kodeTagHasil,
    'dibuatPada': dibuatPada.millisecondsSinceEpoch,
    'diperbaruiPada': diperbaruiPada.millisecondsSinceEpoch,
  };

  factory Usulan.dariKolom(Map<String, dynamic> kolom) {
    return Usulan(
      id: kolom['id'] as int?,
      jenis: _pilihEnum(
        JenisUsulan.values,
        kolom['jenis'],
        JenisUsulan.sejarah,
      ),
      maksud: _pilihEnum(
        MaksudUsulan.values,
        kolom['maksud'],
        MaksudUsulan.baru,
      ),
      targetKodeTag: kolom['targetKodeTag'] as String? ?? '',
      provinsi: kolom['provinsi'] as String? ?? '',
      judul: kolom['judul'] as String? ?? '',
      isi: muatanDariJson(kolom['isi']),
      status: _pilihEnum(
        StatusUsulan.values,
        kolom['status'],
        StatusUsulan.menunggu,
      ),
      catatanAdmin: kolom['catatanAdmin'] as String? ?? '',
      kodeTagHasil: kolom['kodeTagHasil'] as String? ?? '',
      dibuatPada: _waktu(kolom['dibuatPada']),
      diperbaruiPada: _waktu(kolom['diperbaruiPada']),
    );
  }

  // Kerangka usulan koreksi untuk arsip sejarah yang sudah terbit. Isinya
  // disalin apa adanya supaya pengusul tinggal mengubah yang keliru saja.
  factory Usulan.koreksiSejarah(SejarahModel arsip) {
    final kini = DateTime.now();
    return Usulan(
      jenis: JenisUsulan.sejarah,
      maksud: MaksudUsulan.koreksi,
      targetKodeTag: arsip.kodeTag,
      provinsi: arsip.provinsi ?? '',
      judul: arsip.judul,
      isi: {
        KunciUsulan.judul: arsip.judul,
        KunciUsulan.subtitle: arsip.subtitle,
        KunciUsulan.tanggalKey: arsip.tanggalKey,
        KunciUsulan.ringkasan: arsip.ringkasan,
        KunciUsulan.gambar: arsip.gambarUtama,
        KunciUsulan.jenisMedia: arsip.jenisMedia,
        KunciUsulan.mediaUrl: arsip.mediaUrl ?? '',
        KunciUsulan.periode: arsip.periode ?? '',
        KunciUsulan.jenisPeristiwa: arsip.jenisPeristiwa ?? '',
        KunciUsulan.detailPeristiwa: arsip.detailPeristiwa,
        KunciUsulan.alurPeristiwa: arsip.alurPeristiwa
            .map(
              (p) => {
                'tanggal': p.date,
                'judul': p.title,
                'keterangan': p.desc,
                'gambar': p.imgPath ?? '',
              },
            )
            .toList(),
      },
      dibuatPada: kini,
      diperbaruiPada: kini,
    );
  }

  // Kerangka usulan koreksi untuk arsip budaya yang sudah terbit.
  factory Usulan.koreksiBudaya(BudayaModel arsip) {
    final kini = DateTime.now();
    return Usulan(
      jenis: JenisUsulan.budaya,
      maksud: MaksudUsulan.koreksi,
      targetKodeTag: arsip.kodeTag,
      provinsi: arsip.provinsi ?? '',
      judul: arsip.judul,
      isi: {
        KunciUsulan.judul: arsip.judul,
        KunciUsulan.kategori: arsip.jenis,
        KunciUsulan.tagline: arsip.tagline,
        KunciUsulan.deskripsi: arsip.deskripsi,
        KunciUsulan.maknaSpiritual: arsip.maknaSpiritual ?? '',
        KunciUsulan.konteksBudaya: arsip.konteksBudaya ?? '',
        KunciUsulan.gambar: arsip.gambarUtama,
        KunciUsulan.jenisMedia: arsip.jenisMedia,
        KunciUsulan.mediaUrl: arsip.mediaUrl ?? '',
        KunciUsulan.destinasi: arsip.isDestinasi,
        KunciUsulan.detailKategori: arsip.detailKategori,
      },
      dibuatPada: kini,
      diperbaruiPada: kini,
    );
  }

  // Membaca kolom `isi`; nilai null, kosong, atau rusak jadi {}.
  static Map<String, dynamic> muatanDariJson(Object? mentah) {
    if (mentah == null) return const {};
    final teks = mentah.toString().trim();
    if (teks.isEmpty) return const {};
    try {
      final hasil = jsonDecode(teks);
      if (hasil is Map) return Map<String, dynamic>.from(hasil);
    } catch (_) {}
    return const {};
  }

  static T _pilihEnum<T extends Enum>(
    List<T> pilihan,
    Object? nilai,
    T bawaan,
  ) {
    final teks = nilai?.toString().trim() ?? '';
    for (final p in pilihan) {
      if (p.name == teks) return p;
    }
    return bawaan;
  }

  static DateTime _waktu(Object? nilai) =>
      DateTime.fromMillisecondsSinceEpoch((nilai as num?)?.toInt() ?? 0);
}

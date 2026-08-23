import 'package:sqflite/sqflite.dart';

import '../../core/constants/lencana_katalog.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../local/db_helper.dart';
import 'pemilik_akun.dart';
import '../models/hasil_jelajah_model.dart';
import 'arsip_dibaca_repository.dart';
import 'hasil_kuis_repository.dart';
import 'jelajah_repository.dart';
import 'runtun_repository.dart';
import 'usulan_repository.dart';

// Satu lencana beserta kemajuan pemiliknya.
class StatusLencana {
  final Lencana lencana;
  final int tercapai;
  final int target;
  final bool terbuka;

  // Terbuka pada pemeriksaan terakhir, dipakai menandai lencana baru.
  final bool baru;

  // Dipilih pengguna untuk dipajang di halaman profil.
  final bool disematkan;

  // Logo yang disetel admin; kosong berarti memakai ikon bawaan.
  final String gambar;

  const StatusLencana({
    required this.lencana,
    required this.tercapai,
    required this.target,
    required this.terbuka,
    this.baru = false,
    this.disematkan = false,
    this.gambar = '',
  });

  double get rasio =>
      target <= 0 ? 0 : (tercapai / target).clamp(0.0, 1.0).toDouble();
}

// Menghitung status seluruh lencana lalu membuka yang syaratnya sudah
// terpenuhi. Lencana yang sudah terbuka tidak pernah dicabut kembali,
// meski arsip baru masuk atau runtun putus.
class LencanaRepository {
  final DbHelper _dbHelper;
  final JelajahRepository _jelajahRepository;
  final ArsipDibacaRepository _arsipDibacaRepository;
  final HasilKuisRepository _hasilKuisRepository;
  final RuntunRepository _runtunRepository;
  final UsulanRepository _usulanRepository;

  LencanaRepository({
    DbHelper? dbHelper,
    JelajahRepository? jelajahRepository,
    ArsipDibacaRepository? arsipDibacaRepository,
    HasilKuisRepository? hasilKuisRepository,
    RuntunRepository? runtunRepository,
    UsulanRepository? usulanRepository,
  }) : _dbHelper = dbHelper ?? DbHelper(),
       _jelajahRepository = jelajahRepository ?? JelajahRepository(),
       _arsipDibacaRepository =
           arsipDibacaRepository ?? ArsipDibacaRepository(),
       _hasilKuisRepository = hasilKuisRepository ?? HasilKuisRepository(),
       _runtunRepository = runtunRepository ?? RuntunRepository(),
       _usulanRepository = usulanRepository ?? UsulanRepository();

  // Banyaknya lencana yang boleh disemat sekaligus di halaman profil.
  static const int batasSematan = 3;

  int get _pemilik => idAkunAktif;

  // Logo lencana yang disetel admin, kuncinya kode lencana.
  Future<Map<String, String>> logo() async {
    final db = await _dbHelper.database;
    final baris = await db.query('lencana_ikon');
    return {
      for (final r in baris)
        (r['kode'] as String? ?? ''): (r['gambar'] as String? ?? ''),
    }..removeWhere((kode, gambar) => kode.isEmpty || gambar.isEmpty);
  }

  // Menyetel atau melepas logo satu lencana. Dipakai halaman admin.
  Future<void> setLogo(String kode, String? gambar) async {
    final db = await _dbHelper.database;
    if (gambar == null || gambar.trim().isEmpty) {
      await db.delete('lencana_ikon', where: 'kode = ?', whereArgs: [kode]);
      return;
    }
    await db.insert('lencana_ikon', {
      'kode': kode,
      'gambar': gambar.trim(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Kode lencana terbuka beserta status sematannya.
  Future<Map<String, bool>> _kodeTerbuka() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const {};

    final db = await _dbHelper.database;
    final baris = await db.query(
      'lencana',
      columns: ['kode', 'disematkan'],
      where: 'userId = ?',
      whereArgs: [pemilik],
    );
    return {
      for (final r in baris)
        if ((r['kode'] as String? ?? '').isNotEmpty)
          r['kode'] as String: ((r['disematkan'] as num?)?.toInt() ?? 0) == 1,
    };
  }

  // Menyemat atau melepas satu lencana. Hanya berlaku bagi yang sudah terbuka.
  // Mengembalikan false bila kuota sematan sudah penuh.
  Future<bool> setSematan(String kode, bool disematkan) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return false;

    final db = await _dbHelper.database;
    if (disematkan) {
      final terpasang = Sqflite.firstIntValue(
        await db.rawQuery(
          'SELECT COUNT(*) FROM lencana WHERE userId = ? AND disematkan = 1',
          [pemilik],
        ),
      );
      if ((terpasang ?? 0) >= batasSematan) return false;
    }

    await db.update(
      'lencana',
      {'disematkan': disematkan ? 1 : 0},
      where: 'userId = ? AND kode = ?',
      whereArgs: [pemilik, kode],
    );
    return true;
  }

  Future<void> _buka(Iterable<String> kode) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return;

    final db = await _dbHelper.database;
    final sekarang = DateTime.now().millisecondsSinceEpoch;
    for (final k in kode) {
      await db.insert('lencana', {
        'userId': pemilik,
        'kode': k,
        'dibukaPada': sekarang,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  static String _kategoriArsip(HasilJelajah item) =>
      item.jenis == JenisArsip.budaya
      ? (item.budaya?.jenis.trim().toUpperCase() ?? '')
      : '';

  static String _pulauArsip(HasilJelajah item) =>
      pulauDariProvinsi(item.asalProvinsi)?.id ?? '';

  // Menghitung kemajuan seluruh lencana, membuka yang sudah memenuhi syarat,
  // lalu mengembalikan status akhirnya.
  Future<List<StatusLencana>> evaluasi() async {
    final semuaArsip = await _jelajahRepository.semuaArsip();
    final refs = await _arsipDibacaRepository.semua();
    final dibuka = await _jelajahRepository.ambilDariRiwayat(refs);
    final rekor = await _hasilKuisRepository.rekorPerTema();
    final runtun = await _runtunRepository.ringkasan();
    final sudahTerbuka = await _kodeTerbuka();
    final usulanTerbit = await _usulanRepository.jumlahDisetujui();
    final petaLogo = await logo();

    // jumlah arsip tersedia dan yang sudah dibuka, per kategori dan per pulau
    final totalKategori = <String, int>{};
    final totalPulau = <String, int>{};
    for (final item in semuaArsip) {
      final kat = _kategoriArsip(item);
      if (kat.isNotEmpty) {
        totalKategori[kat] = (totalKategori[kat] ?? 0) + 1;
      }
      final pulau = _pulauArsip(item);
      if (pulau.isNotEmpty) {
        totalPulau[pulau] = (totalPulau[pulau] ?? 0) + 1;
      }
    }

    final bacaKategori = <String, int>{};
    final bacaPulau = <String, int>{};
    for (final item in dibuka) {
      final kat = _kategoriArsip(item);
      if (kat.isNotEmpty) {
        bacaKategori[kat] = (bacaKategori[kat] ?? 0) + 1;
      }
      final pulau = _pulauArsip(item);
      if (pulau.isNotEmpty) {
        bacaPulau[pulau] = (bacaPulau[pulau] ?? 0) + 1;
      }
    }

    final temaSempurna = rekor.values.where((r) => r.sempurna).length;

    final hasil = <StatusLencana>[];
    final baruTerbuka = <String>{};

    for (final lencana in lencanaKatalog) {
      int tercapai;
      int target;

      switch (lencana.syarat) {
        case JenisSyarat.arsipKategori:
          target = totalKategori[lencana.acuan] ?? 0;
          tercapai = bacaKategori[lencana.acuan] ?? 0;
          break;
        case JenisSyarat.arsipPulau:
          target = totalPulau[lencana.acuan] ?? 0;
          tercapai = bacaPulau[lencana.acuan] ?? 0;
          break;
        case JenisSyarat.kuisSempurna:
          target = lencana.ambang;
          tercapai = temaSempurna;
          break;
        case JenisSyarat.runtun:
          target = lencana.ambang;
          tercapai = runtun.terpanjang;
          break;
        case JenisSyarat.jumlahArsip:
          target = lencana.ambang;
          tercapai = dibuka.length;
          break;
        case JenisSyarat.usulanDisetujui:
          target = lencana.ambang;
          tercapai = usulanTerbit;
          break;
      }

      // Kategori atau pulau yang belum punya arsip sama sekali tidak bisa
      // dianggap tuntas hanya karena targetnya nol.
      final memenuhi = target > 0 && tercapai >= target;
      final sudah = sudahTerbuka.containsKey(lencana.kode);
      if (memenuhi && !sudah) baruTerbuka.add(lencana.kode);

      hasil.add(
        StatusLencana(
          lencana: lencana,
          tercapai: tercapai > target ? target : tercapai,
          target: target,
          terbuka: sudah || memenuhi,
          baru: memenuhi && !sudah,
          disematkan: sudahTerbuka[lencana.kode] ?? false,
          gambar: petaLogo[lencana.kode] ?? '',
        ),
      );
    }

    if (baruTerbuka.isNotEmpty) await _buka(baruTerbuka);
    return hasil;
  }

  Future<int> jumlahTerbuka() async {
    final status = await evaluasi();
    return status.where((s) => s.terbuka).length;
  }
}

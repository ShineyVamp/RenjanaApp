import 'package:sqflite/sqflite.dart';

import '../local/db_helper.dart';
import 'pemilik_akun.dart';
import 'hasil_kuis_repository.dart';
import 'riwayat_repository.dart';

// Ringkasan kebiasaan harian satu akun.
class RingkasanRuntun {
  final int berjalan;
  final int terpanjang;
  final int totalHari;
  final bool hadirHariIni;

  const RingkasanRuntun({
    this.berjalan = 0,
    this.terpanjang = 0,
    this.totalHari = 0,
    this.hadirHariIni = false,
  });
}

// Satu tugas kecil hari ini.
class MisiHarian {
  final String kode;
  final String nama;
  final String keterangan;
  final int target;
  final int tercapai;

  const MisiHarian({
    required this.kode,
    required this.nama,
    required this.keterangan,
    required this.target,
    required this.tercapai,
  });

  bool get selesai => tercapai >= target;
}

// Kunjungan harian dan misi hari ini, milik akun yang sedang login.
// Kunjungan disimpan satu baris per tanggal di tabel `kunjungan`; misi tidak
// disimpan dan selalu dihitung ulang dari aktivitas hari ini.
class RuntunRepository {
  final DbHelper _dbHelper;
  final RiwayatRepository _riwayatRepository;
  final HasilKuisRepository _hasilKuisRepository;

  RuntunRepository({
    DbHelper? dbHelper,
    RiwayatRepository? riwayatRepository,
    HasilKuisRepository? hasilKuisRepository,
  }) : _dbHelper = dbHelper ?? DbHelper(),
       _riwayatRepository = riwayatRepository ?? RiwayatRepository(),
       _hasilKuisRepository = hasilKuisRepository ?? HasilKuisRepository();

  static const int targetArsipHarian = 1;
  static const int targetKuisHarian = 1;

  int get _pemilik => idAkunAktif;

  static String _kunci(DateTime tanggal) {
    final bulan = tanggal.month.toString().padLeft(2, '0');
    final hari = tanggal.day.toString().padLeft(2, '0');
    return '${tanggal.year}-$bulan-$hari';
  }

  Future<void> catatKunjunganHariIni() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return;

    final db = await _dbHelper.database;
    await db.insert('kunjungan', {
      'userId': pemilik,
      'tanggal': _kunci(DateTime.now()),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Set<String>> _tanggalKunjungan() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return <String>{};

    final db = await _dbHelper.database;
    final baris = await db.query(
      'kunjungan',
      columns: ['tanggal'],
      where: 'userId = ?',
      whereArgs: [pemilik],
    );
    return baris
        .map((r) => r['tanggal'] as String? ?? '')
        .where((t) => t.isNotEmpty)
        .toSet();
  }

  // Runtun berjalan dihitung mundur dari hari ini. Hari ini yang belum
  // tercatat tidak langsung memutus runtun selama kemarin hadir.
  Future<RingkasanRuntun> ringkasan() async {
    final tanggal = await _tanggalKunjungan();
    if (tanggal.isEmpty) return const RingkasanRuntun();

    final hariIni = DateTime.now();
    final awal = DateTime(hariIni.year, hariIni.month, hariIni.day);
    final hadirHariIni = tanggal.contains(_kunci(awal));

    var mulai = awal;
    if (!hadirHariIni) {
      final kemarin = awal.subtract(const Duration(days: 1));
      if (!tanggal.contains(_kunci(kemarin))) {
        return RingkasanRuntun(
          terpanjang: _runtunTerpanjang(tanggal),
          totalHari: tanggal.length,
        );
      }
      mulai = kemarin;
    }

    var berjalan = 0;
    var cursor = mulai;
    while (tanggal.contains(_kunci(cursor))) {
      berjalan++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return RingkasanRuntun(
      berjalan: berjalan,
      terpanjang: _runtunTerpanjang(tanggal),
      totalHari: tanggal.length,
      hadirHariIni: hadirHariIni,
    );
  }

  int _runtunTerpanjang(Set<String> tanggal) {
    final urut = tanggal.toList()..sort();
    var terpanjang = 0;
    var berjalan = 0;
    DateTime? sebelumnya;

    for (final teks in urut) {
      final hari = DateTime.tryParse(teks);
      if (hari == null) continue;

      if (sebelumnya != null && hari.difference(sebelumnya).inDays == 1) {
        berjalan++;
      } else {
        berjalan = 1;
      }
      if (berjalan > terpanjang) terpanjang = berjalan;
      sebelumnya = hari;
    }
    return terpanjang;
  }

  Future<List<MisiHarian>> misiHariIni() async {
    final arsip = await _riwayatRepository.jumlahDibukaHariIni();
    final kuis = await _hasilKuisRepository.jumlahHariIni();
    final ringkas = await ringkasan();

    return [
      MisiHarian(
        kode: 'hadir',
        nama: 'Datang hari ini',
        keterangan: 'Buka Renjana untuk menjaga runtun',
        target: 1,
        tercapai: ringkas.hadirHariIni ? 1 : 0,
      ),
      MisiHarian(
        kode: 'arsip',
        nama: 'Baca satu arsip',
        keterangan: 'Buka satu halaman sejarah atau budaya',
        target: targetArsipHarian,
        tercapai: arsip,
      ),
      MisiHarian(
        kode: 'kuis',
        nama: 'Selesaikan satu kuis',
        keterangan: 'Tema apa pun, sependek apa pun',
        target: targetKuisHarian,
        tercapai: kuis,
      ),
    ];
  }
}

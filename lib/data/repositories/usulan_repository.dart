import 'dart:convert';

import '../../core/constants/budaya_kategori.dart';
import '../local/db_helper.dart';
import '../models/budaya_model.dart';
import '../models/quiz_model.dart';
import '../models/sejarah_model.dart';
import '../models/usulan_model.dart';
import 'budaya_repository.dart';
import 'pemilik_akun.dart';
import 'quiz_repository.dart';
import 'sejarah_repository.dart';

// Hasil penerbitan sebuah usulan.
class HasilTerap {
  final String kodeTag;
  final String? galat;

  const HasilTerap.berhasil(this.kodeTag) : galat = null;
  const HasilTerap.gagal(this.galat) : kodeTag = '';

  bool get sukses => galat == null;
}

// Satu field arsip yang disandingkan antara isi sekarang dan yang diusulkan.
class BedaKoreksi {
  final String label;
  final String sebelum;
  final String sesudah;

  const BedaKoreksi(this.label, this.sebelum, this.sesudah);

  // Field yang dikosongkan pengusul berarti dibiarkan seperti semula, bukan
  // permintaan menghapus isinya.
  bool get dibiarkan => sesudah.trim().isEmpty && sebelum.trim().isNotEmpty;

  bool get berubah => sebelum.trim() != sesudah.trim() && !dibiarkan;
}

// Usulan konten dari pengguna beserta keputusan admin atasnya.
//
// Pengguna hanya melihat usulannya sendiri; admin melihat milik semua akun,
// jadi pembacaannya dipisah antara `milikSaya` dan `semua`.
class UsulanRepository {
  final DbHelper _dbHelper;
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;
  final QuizRepository _quizRepository;

  UsulanRepository({
    DbHelper? dbHelper,
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
    QuizRepository? quizRepository,
  }) : _dbHelper = dbHelper ?? DbHelper(),
       _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository(),
       _quizRepository = quizRepository ?? QuizRepository();

  // Banyaknya usulan baru yang boleh dikirim satu akun dalam sehari, penahan
  // agar antrean tinjauan admin tidak dibanjiri.
  static const int batasUsulanHarian = 5;

  int get _pemilik => idAkunAktif;

  // section pengiriman oleh pengguna

  // Usulan yang dibuat hari ini, dihitung dari waktu pembuatannya sehingga
  // memperbaiki usulan lama tidak ikut memakan jatah.
  Future<int> jumlahHariIni() async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final kini = DateTime.now();
    final awalHari = DateTime(kini.year, kini.month, kini.day);

    final db = await _dbHelper.database;
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM usulan '
      'WHERE userId = ? AND dibuatPada >= ?',
      [pemilik, awalHari.millisecondsSinceEpoch],
    );
    return (hasil.first['total'] as num?)?.toInt() ?? 0;
  }

  Future<bool> masihBolehMengusulkan() async =>
      await jumlahHariIni() < batasUsulanHarian;

  Future<bool> kirim(Usulan usulan) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return false;

    final db = await _dbHelper.database;
    final id = await db.insert('usulan', usulan.toKolom(pemilik)..remove('id'));
    return id > 0;
  }

  // Mengirim ulang usulan yang diminta diperbaiki. Statusnya kembali menunggu
  // dan catatan admin dikosongkan, tetapi hanya bila usulannya memang milik
  // akun ini dan masih boleh disunting.
  Future<bool> perbarui(Usulan usulan) async {
    final pemilik = _pemilik;
    final id = usulan.id;
    if (pemilik <= 0 || id == null) return false;

    final db = await _dbHelper.database;
    final jumlah = await db.update(
      'usulan',
      usulan
          .salin(
            status: StatusUsulan.menunggu,
            catatanAdmin: '',
            diperbaruiPada: DateTime.now(),
          )
          .toKolom(pemilik),
      where: 'id = ? AND userId = ?',
      whereArgs: [id, pemilik],
    );
    return jumlah > 0;
  }

  Future<bool> batalkan(int id) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return false;

    final db = await _dbHelper.database;
    final jumlah = await db.delete(
      'usulan',
      where: 'id = ? AND userId = ? AND status IN (?, ?)',
      whereArgs: [
        id,
        pemilik,
        StatusUsulan.menunggu.name,
        StatusUsulan.revisi.name,
      ],
    );
    return jumlah > 0;
  }

  // section pembacaan

  Future<List<Usulan>> milikSaya({int? batas, int lewati = 0}) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return const [];

    final db = await _dbHelper.database;
    final baris = await db.query(
      'usulan',
      where: 'userId = ?',
      whereArgs: [pemilik],
      orderBy: 'diperbaruiPada DESC, id DESC',
      limit: batas,
      offset: lewati > 0 ? lewati : null,
    );
    return baris.map(Usulan.dariKolom).toList();
  }

  Future<int> jumlahMilikSaya({StatusUsulan? status}) async {
    final pemilik = _pemilik;
    if (pemilik <= 0) return 0;

    final db = await _dbHelper.database;
    final hasil = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM usulan WHERE userId = ?'
      '${status == null ? '' : ' AND status = ?'}',
      [pemilik, if (status != null) status.name],
    );
    return (hasil.first['total'] as num?)?.toInt() ?? 0;
  }

  Future<Usulan?> ambil(int id) async {
    final db = await _dbHelper.database;
    final baris = await db.query(
      'usulan',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (baris.isEmpty) return null;
    return Usulan.dariKolom(baris.first);
  }

  // Nama pengusul, dipakai panel admin dan atribusi pada arsip yang terbit.
  Future<String> namaPengusul(int usulanId) async {
    final db = await _dbHelper.database;
    final baris = await db.rawQuery(
      'SELECT user.nama AS nama FROM usulan '
      'JOIN user ON user.id = usulan.userId WHERE usulan.id = ?',
      [usulanId],
    );
    if (baris.isEmpty) return '';
    return baris.first['nama'] as String? ?? '';
  }

  // section panel admin

  Future<List<Usulan>> semua({
    StatusUsulan? status,
    MaksudUsulan? maksud,
    int? batas,
    int lewati = 0,
  }) async {
    final syarat = <String>[
      if (status != null) 'status = ?',
      if (maksud != null) 'maksud = ?',
    ];
    final nilai = <Object>[
      if (status != null) status.name,
      if (maksud != null) maksud.name,
    ];

    final db = await _dbHelper.database;
    final baris = await db.query(
      'usulan',
      where: syarat.isEmpty ? null : syarat.join(' AND '),
      whereArgs: nilai.isEmpty ? null : nilai,
      orderBy: 'diperbaruiPada DESC, id DESC',
      limit: batas,
      offset: lewati > 0 ? lewati : null,
    );
    return baris.map(Usulan.dariKolom).toList();
  }

  // Banyaknya usulan per maksud pada satu status, untuk angka pada penyaring.
  Future<Map<MaksudUsulan, int>> jumlahPerMaksud(StatusUsulan status) async {
    final db = await _dbHelper.database;
    final baris = await db.rawQuery(
      'SELECT maksud, COUNT(*) AS total FROM usulan '
      'WHERE status = ? GROUP BY maksud',
      [status.name],
    );

    final hasil = {for (final m in MaksudUsulan.values) m: 0};
    for (final r in baris) {
      final nama = r['maksud'] as String? ?? '';
      for (final m in MaksudUsulan.values) {
        if (m.name == nama) hasil[m] = (r['total'] as num?)?.toInt() ?? 0;
      }
    }
    return hasil;
  }

  // Banyaknya usulan per status untuk seluruh akun, dipakai angka pada tab
  // admin dan penanda di drawer.
  Future<Map<StatusUsulan, int>> jumlahPerStatus() async {
    final db = await _dbHelper.database;
    final baris = await db.rawQuery(
      'SELECT status, COUNT(*) AS total FROM usulan GROUP BY status',
    );

    final hasil = {for (final s in StatusUsulan.values) s: 0};
    for (final r in baris) {
      final nama = r['status'] as String? ?? '';
      for (final s in StatusUsulan.values) {
        if (s.name == nama) {
          hasil[s] = (r['total'] as num?)?.toInt() ?? 0;
        }
      }
    }
    return hasil;
  }

  // Keputusan admin. Catatan wajib diisi untuk penolakan dan permintaan
  // revisi; pengecekannya ada di halaman admin, bukan di sini.
  Future<bool> putuskan({
    required int id,
    required StatusUsulan status,
    String catatan = '',
    String kodeTagHasil = '',
  }) async {
    final db = await _dbHelper.database;
    final jumlah = await db.update(
      'usulan',
      {
        'status': status.name,
        'catatanAdmin': catatan.trim(),
        if (kodeTagHasil.trim().isNotEmpty) 'kodeTagHasil': kodeTagHasil.trim(),
        'diperbaruiPada': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return jumlah > 0;
  }

  // Menyunting isi usulan dari panel admin. Berbeda dari `perbarui` milik
  // pengguna: status, catatan, dan pemiliknya tidak ikut berubah, sebab admin
  // sedang merapikan tulisan orang lain.
  Future<bool> perbaruiSebagaiAdmin(Usulan usulan) async {
    final id = usulan.id;
    if (id == null) return false;

    final db = await _dbHelper.database;
    final jumlah = await db.update(
      'usulan',
      {
        'jenis': usulan.jenis.name,
        'provinsi': usulan.provinsi,
        'judul': usulan.judul,
        'isi': jsonEncode(usulan.isi),
        'diperbaruiPada': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return jumlah > 0;
  }

  // section perbandingan koreksi

  // Menyandingkan isi arsip yang sekarang dengan yang diusulkan, supaya admin
  // langsung melihat bagian mana yang hendak diubah. Dibaca dari arsip yang
  // hidup, bukan dari cadangan, sebab cadangan baru terisi setelah disetujui.
  Future<List<BedaKoreksi>> bandingkanKoreksi(Usulan usulan) async {
    if (!usulan.koreksi) return const [];

    final kodeTag = usulan.targetKodeTag.trim();
    if (kodeTag.isEmpty) return const [];

    switch (usulan.jenis) {
      case JenisUsulan.sejarah:
        final arsip = await _sejarahRepository.getSejarahByKodeTag(kodeTag);
        if (arsip == null) return const [];

        return [
          BedaKoreksi('Judul', arsip.judul, usulan.teks(KunciUsulan.judul)),
          BedaKoreksi(
            'Penanda Tanggal',
            arsip.subtitle,
            usulan.teks(KunciUsulan.subtitle),
          ),
          BedaKoreksi(
            'Tanggal',
            arsip.tanggalKey,
            usulan.teks(KunciUsulan.tanggalKey),
          ),
          BedaKoreksi('Provinsi', arsip.provinsi ?? '', usulan.provinsi),
          BedaKoreksi(
            'Ringkasan',
            arsip.ringkasan,
            usulan.teks(KunciUsulan.ringkasan),
          ),
          BedaKoreksi(
            'Gambar',
            arsip.gambarUtama,
            usulan.teks(KunciUsulan.gambar),
          ),
          BedaKoreksi(
            'Alur Peristiwa',
            _ringkasPeristiwa(
              arsip.alurPeristiwa
                  .map(
                    (p) => {
                      'tanggal': p.date,
                      'judul': p.title,
                      'keterangan': p.desc,
                    },
                  )
                  .toList(),
            ),
            _ringkasPeristiwa(usulan.daftar(KunciUsulan.alurPeristiwa)),
          ),
        ];

      case JenisUsulan.budaya:
        final arsip = await _budayaRepository.getBudayaByKodeTag(kodeTag);
        if (arsip == null) return const [];

        final detail = _detailDari(usulan);
        return [
          BedaKoreksi('Nama', arsip.judul, usulan.teks(KunciUsulan.judul)),
          BedaKoreksi('Provinsi', arsip.provinsi ?? '', usulan.provinsi),
          BedaKoreksi(
            'Tagline',
            arsip.tagline,
            usulan.teks(KunciUsulan.tagline),
          ),
          BedaKoreksi(
            'Deskripsi',
            arsip.deskripsi,
            usulan.teks(KunciUsulan.deskripsi),
          ),
          BedaKoreksi(
            'Gambar',
            arsip.gambarUtama,
            usulan.teks(KunciUsulan.gambar),
          ),
          BedaKoreksi(
            'Makna Spiritual',
            arsip.maknaSpiritual ?? '',
            usulan.teks(KunciUsulan.maknaSpiritual),
          ),
          BedaKoreksi(
            'Konteks Budaya',
            arsip.konteksBudaya ?? '',
            usulan.teks(KunciUsulan.konteksBudaya),
          ),
          for (final field in fieldKategori(arsip.jenis))
            BedaKoreksi(
              field.label,
              _ringkasNilai(arsip.detailKategori[field.kunci]),
              _ringkasNilai(detail[field.kunci]),
            ),
        ];

      case JenisUsulan.kuis:
        return const [];
    }
  }

  static String _ringkasPeristiwa(List<Map<String, dynamic>> daftar) {
    return daftar
        .map((p) {
          final bagian = [
            p['tanggal']?.toString().trim() ?? '',
            p['judul']?.toString().trim() ?? '',
            p['keterangan']?.toString().trim() ?? '',
          ].where((b) => b.isNotEmpty);
          return bagian.join(' — ');
        })
        .where((b) => b.isNotEmpty)
        .join('\n');
  }

  static String _ringkasNilai(Object? nilai) {
    if (nilai == null) return '';
    if (nilai is List) return nilai.map((e) => '$e').join('\n');
    return nilai.toString();
  }

  // section penerbitan

  // Menerapkan usulan ke arsip sungguhan.
  //
  // Tiga jalan berbeda: koreksi menimpa arsip yang dikoreksi, usulan yang
  // sudah pernah terbit diperbarui di tempat supaya ID tagnya tidak berubah,
  // dan sisanya diterbitkan sebagai arsip baru.
  Future<HasilTerap> terapkan(Usulan usulan) async {
    final id = usulan.id;
    if (id == null) return const HasilTerap.gagal('Usulan tidak dikenali.');

    final nama = await namaPengusul(id);

    try {
      if (usulan.koreksi) {
        return await _perbaruiArsip(
          usulan,
          usulan.targetKodeTag,
          simpanCadangan: true,
        );
      }

      final terbit = usulan.kodeTagHasil.trim();
      if (terbit.isNotEmpty && await _arsipAda(usulan.jenis, terbit)) {
        return await _perbaruiArsip(usulan, terbit);
      }

      switch (usulan.jenis) {
        case JenisUsulan.sejarah:
          return await _terbitkanSejarah(usulan, nama);
        case JenisUsulan.budaya:
          return await _terbitkanBudaya(usulan, nama);
        case JenisUsulan.kuis:
          return await _terbitkanKuis(usulan);
      }
    } catch (_) {
      return const HasilTerap.gagal('Gagal menerbitkan arsip.');
    }
  }

  // Membatalkan penerbitan saat admin mengubah keputusan dari disetujui ke
  // status lain. Usulan baru dihapus arsipnya; koreksi dipulihkan dari
  // cadangan yang disimpan sebelum ditimpa.
  Future<HasilTerap> tarikTerbitan(Usulan usulan) async {
    try {
      if (usulan.koreksi) return await _pulihkanCadangan(usulan);

      final terbit = usulan.kodeTagHasil.trim();
      if (terbit.isEmpty) return const HasilTerap.berhasil('');

      switch (usulan.jenis) {
        case JenisUsulan.sejarah:
          await _sejarahRepository.deleteSejarah(terbit);
        case JenisUsulan.budaya:
          await _budayaRepository.deleteBudaya(terbit);
        case JenisUsulan.kuis:
          await _quizRepository.deleteQuizzesByTema(terbit);
      }
      return HasilTerap.berhasil(terbit);
    } catch (_) {
      return const HasilTerap.gagal('Gagal menarik arsip yang sudah terbit.');
    }
  }

  Future<bool> _arsipAda(JenisUsulan jenis, String kodeTag) async {
    switch (jenis) {
      case JenisUsulan.sejarah:
        return await _sejarahRepository.getSejarahByKodeTag(kodeTag) != null;
      case JenisUsulan.budaya:
        return await _budayaRepository.getBudayaByKodeTag(kodeTag) != null;
      case JenisUsulan.kuis:
        return (await _quizRepository.getQuizByTema(kodeTag)).isNotEmpty;
    }
  }

  // section penerbitan arsip baru

  Future<HasilTerap> _terbitkanSejarah(Usulan usulan, String nama) async {
    final judul = usulan.teks(KunciUsulan.judul);
    if (judul.isEmpty) {
      return const HasilTerap.gagal('Usulan belum punya judul.');
    }

    final tanggalKey = _tanggalAtauHariIni(usulan);
    final semua = await _sejarahRepository.getAllSejarah();
    final sekelompok = semua.where((s) => s.tanggalKey == tanggalKey);
    final urutan = sekelompok.isEmpty
        ? 1
        : sekelompok.map((s) => s.urutan).reduce((a, b) => a > b ? a : b) + 1;
    final kodeTag = 'HIS-$tanggalKey-$urutan';

    await _sejarahRepository.tambahSejarah(
      SejarahModel(
        kodeTag: kodeTag,
        tanggalKey: tanggalKey,
        urutan: urutan,
        judul: judul,
        subtitle: usulan.teks(KunciUsulan.subtitle),
        ringkasan: usulan.teks(KunciUsulan.ringkasan),
        gambarUtama: _gambarAtauBawaan(usulan),
        alurPeristiwa: _peristiwaDari(usulan),
        provinsi: usulan.provinsi,
        kontributor: nama,
        periode: usulan.teks(KunciUsulan.periode).isEmpty
            ? null
            : usulan.teks(KunciUsulan.periode),
        jenisPeristiwa: usulan.teks(KunciUsulan.jenisPeristiwa).isEmpty
            ? null
            : usulan.teks(KunciUsulan.jenisPeristiwa),
        detailPeristiwa: (usulan.isi[KunciUsulan.detailPeristiwa] is Map)
            ? Map<String, dynamic>.from(
                usulan.isi[KunciUsulan.detailPeristiwa] as Map,
              )
            : const {},
        jenisMedia: usulan.teks(KunciUsulan.jenisMedia).isEmpty
            ? 'gambar'
            : usulan.teks(KunciUsulan.jenisMedia),
        mediaUrl: usulan.teks(KunciUsulan.mediaUrl).isEmpty
            ? null
            : usulan.teks(KunciUsulan.mediaUrl),
      ),
    );

    return HasilTerap.berhasil(kodeTag);
  }

  Future<HasilTerap> _terbitkanBudaya(Usulan usulan, String nama) async {
    final judul = usulan.teks(KunciUsulan.judul);
    final kode = usulan.teks(KunciUsulan.kategori);
    final kategori = kategoriByKode(kode);
    if (judul.isEmpty || kategori == null) {
      return const HasilTerap.gagal('Judul atau kategorinya tidak lengkap.');
    }

    final semua = await _budayaRepository.getAllBudaya();
    final sekategori = semua.where((b) => b.jenis == kode);
    final urutan = sekategori.isEmpty
        ? 1
        : sekategori.map((b) => b.urutan).reduce((a, b) => a > b ? a : b) + 1;

    final destinasi = usulan.isi[KunciUsulan.destinasi] == true;
    final kodeTag = buatKodeTagBudaya(
      jenis: kode,
      urutan: urutan,
      isDestinasi: destinasi,
    );

    await _budayaRepository.tambahBudaya(
      BudayaModel(
        kodeTag: kodeTag,
        jenis: kode,
        urutan: urutan,
        judul: judul,
        kategoriLabel: kategori.label,
        tagline: usulan.teks(KunciUsulan.tagline),
        deskripsi: usulan.teks(KunciUsulan.deskripsi),
        gambarUtama: _gambarAtauBawaan(usulan),
        maknaSpiritual: _kosongJadiNull(
          usulan.teks(KunciUsulan.maknaSpiritual),
        ),
        konteksBudaya: _kosongJadiNull(usulan.teks(KunciUsulan.konteksBudaya)),
        provinsi: usulan.provinsi,
        detailKategori: _detailDari(usulan),
        kontributor: nama,
        jenisMedia: usulan.teks(KunciUsulan.jenisMedia).isEmpty
            ? 'gambar'
            : usulan.teks(KunciUsulan.jenisMedia),
        mediaUrl: usulan.teks(KunciUsulan.mediaUrl).isEmpty
            ? null
            : usulan.teks(KunciUsulan.mediaUrl),
      ),
    );

    return HasilTerap.berhasil(kodeTag);
  }

  // Tema kuis tidak punya ID tag; yang terbit adalah kumpulan soalnya, dan
  // nama temanya dipakai sebagai penanda hasil.
  Future<HasilTerap> _terbitkanKuis(Usulan usulan) async {
    final tema = usulan.teks(KunciUsulan.tema);
    final daftarSoal = usulan.daftar(KunciUsulan.soal);
    if (tema.isEmpty || daftarSoal.isEmpty) {
      return const HasilTerap.gagal('Tema atau soalnya belum lengkap.');
    }

    final gambar = usulan.teks(KunciUsulan.gambar);
    var masuk = 0;

    for (final s in daftarSoal) {
      final jawaban = (s['jawaban'] as List? ?? const [])
          .map((e) => '$e'.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final pertanyaan = s['soal']?.toString().trim() ?? '';
      if (pertanyaan.isEmpty || jawaban.length < 2) continue;

      final berhasil = await _quizRepository.tambahQuiz(
        QuizSQLModel(
          kategori: usulan.teks(KunciUsulan.kategoriKuis),
          subKategori: usulan.teks(KunciUsulan.subKategori),
          tema: tema,
          soal: pertanyaan,
          daftarJawaban: jawaban,
          jawabanBenar: (s['benar'] as num?)?.toInt() ?? 0,
          gambar: gambar.isEmpty ? null : gambar,
          penjelasan: _kosongJadiNull(s['penjelasan']?.toString() ?? ''),
        ),
      );
      if (berhasil) masuk++;
    }

    if (masuk == 0) {
      return const HasilTerap.gagal(
        'Tidak ada soal yang bisa disimpan. Mungkin soalnya sudah ada.',
      );
    }
    return HasilTerap.berhasil(tema);
  }

  // section pembaruan arsip yang sudah terbit

  // Menimpa arsip yang sudah ada, dipakai koreksi maupun penyuntingan admin.
  // ID tag, urutan, dan nama kontributor aslinya tidak ikut berubah: yang
  // menyunting memperbaiki tulisan orang lain, bukan mengambil alihnya.
  Future<HasilTerap> _perbaruiArsip(
    Usulan usulan,
    String target, {
    bool simpanCadangan = false,
  }) async {
    final kodeTag = target.trim();
    if (kodeTag.isEmpty) {
      return const HasilTerap.gagal('Arsip yang dituju tidak dikenali.');
    }

    switch (usulan.jenis) {
      case JenisUsulan.sejarah:
        final arsip = await _sejarahRepository.getSejarahByKodeTag(kodeTag);
        if (arsip == null) {
          return HasilTerap.gagal('Arsip $kodeTag sudah tidak ada.');
        }
        if (simpanCadangan) await _simpanCadanganSejarah(usulan, arsip);

        await _sejarahRepository.updateSejarah(
          SejarahModel(
            id: arsip.id,
            kodeTag: arsip.kodeTag,
            tanggalKey: _pilih(
              usulan.teks(KunciUsulan.tanggalKey),
              arsip.tanggalKey,
            ),
            urutan: arsip.urutan,
            judul: _pilih(usulan.teks(KunciUsulan.judul), arsip.judul),
            subtitle: _pilih(usulan.teks(KunciUsulan.subtitle), arsip.subtitle),
            ringkasan: _pilih(
              usulan.teks(KunciUsulan.ringkasan),
              arsip.ringkasan,
            ),
            gambarUtama: _pilih(
              usulan.teks(KunciUsulan.gambar),
              arsip.gambarUtama,
            ),
            alurPeristiwa: usulan.daftar(KunciUsulan.alurPeristiwa).isEmpty
                ? arsip.alurPeristiwa
                : _peristiwaDari(usulan),
            provinsi: _pilih(usulan.provinsi, arsip.provinsi ?? ''),
            kontributor: arsip.kontributor,
            periode: _pilih(
              usulan.teks(KunciUsulan.periode),
              arsip.periode ?? '',
            ),
            jenisPeristiwa: _pilih(
              usulan.teks(KunciUsulan.jenisPeristiwa),
              arsip.jenisPeristiwa ?? '',
            ),
            detailPeristiwa: (usulan.isi[KunciUsulan.detailPeristiwa] is Map)
                ? Map<String, dynamic>.from(
                    usulan.isi[KunciUsulan.detailPeristiwa] as Map,
                  )
                : arsip.detailPeristiwa,
            jenisMedia: _pilih(
              usulan.teks(KunciUsulan.jenisMedia),
              arsip.jenisMedia,
            ),
            mediaUrl: _pilih(
              usulan.teks(KunciUsulan.mediaUrl),
              arsip.mediaUrl ?? '',
            ),
          ),
        );
        return HasilTerap.berhasil(arsip.kodeTag);

      case JenisUsulan.budaya:
        final arsip = await _budayaRepository.getBudayaByKodeTag(kodeTag);
        if (arsip == null) {
          return HasilTerap.gagal('Arsip $kodeTag sudah tidak ada.');
        }
        if (simpanCadangan) await _simpanCadanganBudaya(usulan, arsip);

        final detail = _detailDari(usulan);
        await _budayaRepository.updateBudaya(
          BudayaModel(
            id: arsip.id,
            kodeTag: arsip.kodeTag,
            jenis: arsip.jenis,
            urutan: arsip.urutan,
            judul: _pilih(usulan.teks(KunciUsulan.judul), arsip.judul),
            kategoriLabel: arsip.kategoriLabel,
            tagline: _pilih(usulan.teks(KunciUsulan.tagline), arsip.tagline),
            deskripsi: _pilih(
              usulan.teks(KunciUsulan.deskripsi),
              arsip.deskripsi,
            ),
            gambarUtama: _pilih(
              usulan.teks(KunciUsulan.gambar),
              arsip.gambarUtama,
            ),
            maknaSpiritual: _kosongJadiNull(
              _pilih(
                usulan.teks(KunciUsulan.maknaSpiritual),
                arsip.maknaSpiritual ?? '',
              ),
            ),
            gambarMaknaSpiritual: arsip.gambarMaknaSpiritual,
            konteksBudaya: _kosongJadiNull(
              _pilih(
                usulan.teks(KunciUsulan.konteksBudaya),
                arsip.konteksBudaya ?? '',
              ),
            ),
            gambarKonteksBudaya: arsip.gambarKonteksBudaya,
            provinsi: _pilih(usulan.provinsi, arsip.provinsi ?? ''),
            detailKategori: detail.isEmpty ? arsip.detailKategori : detail,
            kontributor: arsip.kontributor,
            jenisMedia: _pilih(
              usulan.teks(KunciUsulan.jenisMedia),
              arsip.jenisMedia,
            ),
            mediaUrl: _pilih(
              usulan.teks(KunciUsulan.mediaUrl),
              arsip.mediaUrl ?? '',
            ),
          ),
        );
        return HasilTerap.berhasil(arsip.kodeTag);

      case JenisUsulan.kuis:
        // Soal tidak bisa ditimpa satu per satu, jadi tema lamanya dibersihkan
        // lalu diisi ulang dari usulan yang sekarang.
        await _quizRepository.deleteQuizzesByTema(kodeTag);
        return await _terbitkanKuis(usulan);
    }
  }

  // section cadangan koreksi

  Future<void> _simpanCadanganSejarah(Usulan usulan, SejarahModel arsip) async {
    await _simpanIsi(usulan, {
      KunciUsulan.judul: arsip.judul,
      KunciUsulan.subtitle: arsip.subtitle,
      KunciUsulan.tanggalKey: arsip.tanggalKey,
      KunciUsulan.ringkasan: arsip.ringkasan,
      KunciUsulan.gambar: arsip.gambarUtama,
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
    });
  }

  Future<void> _simpanCadanganBudaya(Usulan usulan, BudayaModel arsip) async {
    await _simpanIsi(usulan, {
      KunciUsulan.judul: arsip.judul,
      KunciUsulan.tagline: arsip.tagline,
      KunciUsulan.deskripsi: arsip.deskripsi,
      KunciUsulan.maknaSpiritual: arsip.maknaSpiritual ?? '',
      KunciUsulan.konteksBudaya: arsip.konteksBudaya ?? '',
      KunciUsulan.gambar: arsip.gambarUtama,
      KunciUsulan.detailKategori: arsip.detailKategori,
      'provinsi': arsip.provinsi ?? '',
    });
  }

  // Cadangan disisipkan ke muatan usulan, bukan tabel tersendiri, sebab hanya
  // berguna selama usulan itu masih ada.
  Future<void> _simpanIsi(Usulan usulan, Map<String, dynamic> cadangan) async {
    final id = usulan.id;
    if (id == null) return;

    final isiBaru = Map<String, dynamic>.from(usulan.isi)
      ..[KunciUsulan.cadangan] = cadangan;

    final db = await _dbHelper.database;
    await db.update(
      'usulan',
      {'isi': jsonEncode(isiBaru)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<HasilTerap> _pulihkanCadangan(Usulan usulan) async {
    final cadangan = usulan.isi[KunciUsulan.cadangan];
    final kodeTag = usulan.targetKodeTag.trim();
    if (cadangan is! Map || kodeTag.isEmpty) {
      return const HasilTerap.gagal(
        'Tidak ada cadangan, arsip tidak bisa dikembalikan otomatis.',
      );
    }

    // Cadangan diperlakukan sebagai muatan usulan, jadi jalur pembaruan yang
    // sama bisa dipakai untuk mengembalikannya.
    final pemulih = usulan.salin(
      isi: Map<String, dynamic>.from(cadangan),
      provinsi: cadangan['provinsi']?.toString() ?? usulan.provinsi,
    );
    return await _perbaruiArsip(pemulih, kodeTag);
  }

  // section alat bantu

  static List<TimelineItemModel> _peristiwaDari(Usulan usulan) {
    return usulan.daftar(KunciUsulan.alurPeristiwa).map((p) {
      final gambar = p['gambar']?.toString().trim() ?? '';
      return TimelineItemModel(
        date: p['tanggal']?.toString() ?? '',
        title: p['judul']?.toString() ?? '',
        desc: p['keterangan']?.toString() ?? '',
        imgPath: gambar.isEmpty ? null : gambar,
        hasImage: gambar.isNotEmpty,
      );
    }).toList();
  }

  static Map<String, dynamic> _detailDari(Usulan usulan) {
    final detail = usulan.isi[KunciUsulan.detailKategori];
    return detail is Map ? Map<String, dynamic>.from(detail) : const {};
  }

  // Tanggal yang tidak diisi pengusul memakai tanggal persetujuan, supaya ID
  // tagnya tetap terbentuk.
  static String _tanggalAtauHariIni(Usulan usulan) {
    final tanggal = usulan.teks(KunciUsulan.tanggalKey);
    if (tanggal.length == 6 && int.tryParse(tanggal) != null) return tanggal;

    final kini = DateTime.now();
    return '${_duaAngka(kini.day)}${_duaAngka(kini.month)}'
        '${_duaAngka(kini.year % 100)}';
  }

  // Arsip wajib punya gambar; usulan tanpa gambar memakai berkas bawaan yang
  // bisa diganti admin lewat form konten.
  static String _gambarAtauBawaan(Usulan usulan) {
    final gambar = usulan.teks(KunciUsulan.gambar);
    return gambar.isEmpty ? 'assets/images/onboardin1.jpg' : gambar;
  }

  // Nilai usulan dipakai bila diisi; yang dikosongkan berarti tidak diubah.
  static String _pilih(String usulan, String asli) =>
      usulan.trim().isEmpty ? asli : usulan.trim();

  static String? _kosongJadiNull(String teks) =>
      teks.trim().isEmpty ? null : teks.trim();

  static String _duaAngka(int nilai) => nilai.toString().padLeft(2, '0');

  // section bahan lencana

  Future<int> jumlahDisetujui() =>
      jumlahMilikSaya(status: StatusUsulan.disetujui);
}

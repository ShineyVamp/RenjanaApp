import 'package:sqflite/sqflite.dart';

import '../../core/constants/katalog_kategori.dart';
import '../local/db_helper.dart';

// Hasil pemeriksaan sebelum sebuah kategori dihapus.
class PemakaiKategori {
  final int arsip;
  final int soal;

  const PemakaiKategori({this.arsip = 0, this.soal = 0});

  int get total => arsip + soal;
  bool get kosong => total == 0;

  // Keterangan singkat untuk dialog konfirmasi, mis. '4 arsip, 12 soal'.
  String get ringkasan => [
    if (arsip > 0) '$arsip arsip',
    if (soal > 0) '$soal soal',
  ].join(', ');
}

// Pembacaan dan penyuntingan tabel `kategori`, sekaligus penjaga isi
// KatalogKategori di memori.
class KategoriRepository {
  final DbHelper _dbHelper;

  KategoriRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  // Membaca seluruh kategori lalu memasangnya ke katalog. Dipanggil sekali
  // dari main() dan setiap kali admin menyunting isinya.
  //
  // Kegagalan sengaja ditelan: katalog akan memakai daftar bawaan sehingga
  // aplikasi tetap jalan meski database bermasalah.
  Future<void> muat() async {
    try {
      final db = await _dbHelper.database;
      final baris = await db.query(
        'kategori',
        orderBy: 'ranah ASC, urutan ASC, id ASC',
      );

      final isi = <String, List<KategoriItem>>{};
      for (final r in baris) {
        final item = KategoriItem.fromMap(r);
        if (item.kode.isEmpty) continue;
        isi.putIfAbsent(item.ranah, () => []).add(item);
      }
      KatalogKategori.pasang(isi);
    } catch (_) {}
  }

  Future<List<KategoriItem>> semua(String ranah) async {
    final db = await _dbHelper.database;
    final baris = await db.query(
      'kategori',
      where: 'ranah = ?',
      whereArgs: [ranah],
      orderBy: 'urutan ASC, id ASC',
    );
    return baris.map(KategoriItem.fromMap).toList();
  }

  // Kode kategori dipakai arsip lewat kolom `jenis`, jadi harus unik dalam
  // satu ranah.
  Future<bool> kodeTerpakai(String ranah, String kode, {int? kecuali}) async {
    final db = await _dbHelper.database;
    final baris = await db.query(
      'kategori',
      columns: ['id'],
      where: 'ranah = ? AND kode = ?',
      whereArgs: [ranah, kode.trim().toUpperCase()],
    );
    return baris.any((r) => r['id'] != kecuali);
  }

  // Menyimpan kategori baru atau perubahan kategori yang sudah ada, lalu
  // memuat ulang katalog. Kategori baru ditaruh di urutan terakhir ranahnya.
  Future<void> simpan(KategoriItem item) async {
    final db = await _dbHelper.database;
    final data = item.toKolom();

    if (item.id == null) {
      final terakhir =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT MAX(urutan) FROM kategori WHERE ranah = ?',
              [item.ranah],
            ),
          ) ??
          0;
      data['urutan'] = terakhir + 1;
      await db.insert(
        'kategori',
        data,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      await db.update(
        'kategori',
        data,
        where: 'id = ?',
        whereArgs: [item.id],
      );
      await _samakanLabelArsip(db, item);
    }

    await muat();
  }

  // Menyimpan urutan baru satu ranah sesuai posisi pada daftar.
  Future<void> urutkan(List<KategoriItem> urut) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      for (var i = 0; i < urut.length; i++) {
        final id = urut[i].id;
        if (id == null) continue;
        await txn.update(
          'kategori',
          {'urutan': i + 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
    await muat();
  }

  // Kategori bawaan tidak boleh dihapus karena arsip lama menunjuk kodenya.
  Future<bool> hapus(KategoriItem item) async {
    if (item.id == null || item.bawaan) return false;

    final pemakai = await jumlahPemakai(item);
    if (!pemakai.kosong) return false;

    final db = await _dbHelper.database;
    await db.delete('kategori', where: 'id = ?', whereArgs: [item.id]);
    await muat();
    return true;
  }

  // Banyaknya baris yang menunjuk kategori ini. Dipakai untuk mencegah
  // penghapusan kategori yang isinya masih ada.
  Future<PemakaiKategori> jumlahPemakai(KategoriItem item) async {
    if (item.ranah != ranahBudaya) return const PemakaiKategori();

    final db = await _dbHelper.database;
    final kode = item.kode.trim().toUpperCase();

    final arsip =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM budaya WHERE UPPER(jenis) = ?',
            [kode],
          ),
        ) ??
        0;
    final soal =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM quiz WHERE UPPER(subKategori) = ?',
            [kode],
          ),
        ) ??
        0;

    return PemakaiKategori(arsip: arsip, soal: soal);
  }

  // Tabel budaya menyimpan nama kategori dalam kolom `kategoriLabel`, jadi
  // penggantian nama harus ikut turun ke arsipnya.
  Future<void> _samakanLabelArsip(Database db, KategoriItem item) async {
    if (item.ranah != ranahBudaya) return;

    try {
      await db.update(
        'budaya',
        {'kategoriLabel': item.label},
        where: 'UPPER(jenis) = ?',
        whereArgs: [item.kode.trim().toUpperCase()],
      );
    } catch (_) {}
  }
}

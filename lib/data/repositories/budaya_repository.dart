import 'dart:math';
import '../local/db_helper.dart';
import '../local/seed/budaya_seed.dart';
import '../models/budaya_model.dart';

class BudayaRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<List<BudayaModel>> getAllBudaya() async {
    final db = await _dbHelper.database;
    final maps = await db.query('budaya', orderBy: 'id DESC');

    if (maps.isEmpty) {
      return defaultBudayaList;
    }

    return maps.map((map) {
      return BudayaModel(
        id: map['id'] as int?,
        kodeTag: map['kodeTag'] as String? ?? 'BUD-SNJT-1',
        jenis: map['jenis'] as String? ?? 'SNJT',
        urutan: map['urutan'] as int? ?? 1,
        judul: map['judul'] as String? ?? '',
        kategoriLabel: map['kategoriLabel'] as String? ?? 'SENJATA TRADISIONAL',
        tagline: map['tagline'] as String? ?? '',
        deskripsi: map['deskripsi'] as String? ?? '',
        gambarUtama:
            map['gambarUtama'] as String? ?? 'assets/images/kerisB.jpg',
        maknaSpiritual: map['maknaSpiritual'] as String?,
        gambarMaknaSpiritual: map['gambarMaknaSpiritual'] as String?,
        konteksBudaya: map['konteksBudaya'] as String?,
        gambarKonteksBudaya: map['gambarKonteksBudaya'] as String?,
        provinsi: map['provinsi'] as String?,
        detailKategori: BudayaModel.detailDariJson(map['detailKategori']),
      );
    }).toList();
  }

  // Sorotan "Budaya Hari Ini". Acak, tapi benihnya tanggal hari ini supaya
  // pilihannya tetap sama sampai besok.
  Future<BudayaModel> getBudayaHariIni() async {
    final list = await getAllBudaya();
    if (list.isEmpty) return defaultBudayaList.first;

    // diurutkan dulu agar tidak bergantung urutan baris database
    final pool = List<BudayaModel>.from(list)
      ..sort((a, b) => a.kodeTag.compareTo(b.kodeTag));
    final now = DateTime.now();
    final benihHariIni =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return pool[Random(benihHariIni).nextInt(pool.length)];
  }

  // Semua budaya pada satu kategori (kolom `jenis`).
  Future<List<BudayaModel>> getBudayaByJenis(String jenis) async {
    final list = await getAllBudaya();
    final target = jenis.trim().toUpperCase();
    final result = list
        .where((b) => b.jenis.trim().toUpperCase() == target)
        .toList();
    result.sort((a, b) => a.urutan.compareTo(b.urutan));
    return result;
  }

  // Budaya yang sekaligus tempat wisata (ID tag berakhiran `-D`).
  Future<List<BudayaModel>> getDestinasiList({
    bool acak = false,
    int? limit,
  }) async {
    final list = await getAllBudaya();
    final result = list.where((b) => b.isDestinasi).toList();

    if (acak) {
      result.shuffle();
    } else {
      result.sort((a, b) => a.judul.compareTo(b.judul));
    }

    if (limit != null && limit > 0 && result.length > limit) {
      return result.sublist(0, limit);
    }
    return result;
  }

  // Jumlah seluruh destinasi.
  Future<int> getDestinasiCount() async {
    final list = await getAllBudaya();
    return list.where((b) => b.isDestinasi).length;
  }

  // Budaya dikelompokkan per kategori, dipakai daftar Koleksi Budaya.
  Future<Map<String, List<BudayaModel>>> getBudayaGroupedByJenis() async {
    final list = await getAllBudaya();
    final Map<String, List<BudayaModel>> grouped = {};
    for (final b in list) {
      grouped.putIfAbsent(b.jenis.trim().toUpperCase(), () => []).add(b);
    }
    for (final items in grouped.values) {
      items.sort((a, b) => a.urutan.compareTo(b.urutan));
    }
    return grouped;
  }

  Future<BudayaModel?> getBudayaByKodeTag(String kodeTag) async {
    final list = await getAllBudaya();
    try {
      return list.firstWhere((b) => b.kodeTag == kodeTag);
    } catch (_) {
      return null;
    }
  }

  Future<List<BudayaModel>> getRandomBudayaList({
    int count = 5,
    BudayaModel? exclude,
  }) async {
    final list = await getAllBudaya();
    final pool = List<BudayaModel>.from(
      list.where((b) => exclude == null || b.kodeTag != exclude.kodeTag),
    )..shuffle();

    final List<BudayaModel> result = [];
    final random = Random();
    while (result.length < count) {
      if (pool.isNotEmpty) {
        final index = result.length < pool.length
            ? result.length
            : random.nextInt(pool.length);
        result.add(pool[index]);
      } else if (list.isNotEmpty) {
        result.add(list.first);
      } else {
        result.add(defaultBudayaList.first);
      }
    }
    return result;
  }

  Future<int> tambahBudaya(BudayaModel model) async {
    final db = await _dbHelper.database;
    return await db.insert('budaya', {
      'kodeTag': model.kodeTag,
      'jenis': model.jenis,
      'urutan': model.urutan,
      'judul': model.judul,
      'kategoriLabel': model.kategoriLabel,
      'tagline': model.tagline,
      'deskripsi': model.deskripsi,
      'gambarUtama': model.gambarUtama,
      'maknaSpiritual': model.maknaSpiritual,
      'gambarMaknaSpiritual': model.gambarMaknaSpiritual,
      'konteksBudaya': model.konteksBudaya,
      'gambarKonteksBudaya': model.gambarKonteksBudaya,
      'provinsi': model.provinsi,
      'detailKategori': model.detailKategoriJson,
    });
  }

  // [previousKodeTag] diisi bila ID tag ikut berubah, supaya bookmark lama
  // ikut dipindahkan.
  Future<int> updateBudaya(BudayaModel model, {String? previousKodeTag}) async {
    final db = await _dbHelper.database;
    final oldKodeTag = previousKodeTag ?? model.kodeTag;
    final count = await db.update(
      'budaya',
      {
        'kodeTag': model.kodeTag,
        'jenis': model.jenis,
        'urutan': model.urutan,
        'judul': model.judul,
        'kategoriLabel': model.kategoriLabel,
        'tagline': model.tagline,
        'deskripsi': model.deskripsi,
        'gambarUtama': model.gambarUtama,
        'maknaSpiritual': model.maknaSpiritual,
        'gambarMaknaSpiritual': model.gambarMaknaSpiritual,
        'konteksBudaya': model.konteksBudaya,
        'gambarKonteksBudaya': model.gambarKonteksBudaya,
        'provinsi': model.provinsi,
        'detailKategori': model.detailKategoriJson,
      },
      where: model.id != null ? 'id = ?' : 'kodeTag = ?',
      whereArgs: [model.id ?? oldKodeTag],
    );

    if (oldKodeTag != model.kodeTag) {
      await db.rawUpdate(
        'UPDATE OR IGNORE bookmark SET kodeTag = ? WHERE kodeTag = ?',
        [model.kodeTag, oldKodeTag],
      );
    }

    return count;
  }

  Future<int> deleteBudaya(String kodeTag) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'budaya',
      where: 'kodeTag = ?',
      whereArgs: [kodeTag],
    );
    // bersihkan bookmark yang menunjuk item yang sudah dihapus
    await db.delete('bookmark', where: 'kodeTag = ?', whereArgs: [kodeTag]);
    return count;
  }
}

import 'dart:convert';
import 'dart:math';
import '../local/budaya_data.dart';
import '../local/db_helper.dart';
import '../models/budaya_model.dart';
import '../models/sejarah_model.dart';

class BudayaRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<List<BudayaModel>> getAllBudaya() async {
    final db = await _dbHelper.database;
    final maps = await db.query('budaya', orderBy: 'id DESC');

    if (maps.isEmpty) {
      return defaultBudayaList;
    }

    return maps.map((map) {
      List<RelatedItemModel> related = [];
      if (map['relatedItems'] != null &&
          map['relatedItems'].toString().isNotEmpty) {
        try {
          final decoded = jsonDecode(map['relatedItems'] as String);
          if (decoded is List) {
            related = decoded
                .map((i) => RelatedItemModel.fromMap(i as Map<String, dynamic>))
                .toList();
          }
        } catch (_) {}
      }

      return BudayaModel(
        id: map['id'] as int?,
        kodeTag: map['kodeTag'] as String? ?? 'BUD-SNJT-1',
        jenis: map['jenis'] as String? ?? 'SNJT',
        urutan: map['urutan'] as int? ?? 1,
        judul: map['judul'] as String? ?? '',
        kategoriLabel: map['kategoriLabel'] as String? ?? 'SENJATA TRADISIONAL',
        tagline: map['tagline'] as String? ?? '',
        deskripsi: map['deskripsi'] as String? ?? '',
        gambarUtama: map['gambarUtama'] as String? ?? 'assets/images/kerisB.jpg',
        maknaSpiritual: map['maknaSpiritual'] as String?,
        gambarMaknaSpiritual: map['gambarMaknaSpiritual'] as String?,
        konteksBudaya: map['konteksBudaya'] as String?,
        gambarKonteksBudaya: map['gambarKonteksBudaya'] as String?,
        relatedItems: related,
      );
    }).toList();
  }

  Future<BudayaModel> getRandomBudaya() async {
    final list = await getAllBudaya();
    if (list.isEmpty) return defaultBudayaList.first;
    final pool = List<BudayaModel>.from(list)..shuffle();
    return pool.first;
  }

  /// Semua budaya pada satu kategori (kolom `jenis`), diurutkan naik.
  Future<List<BudayaModel>> getBudayaByJenis(String jenis) async {
    final list = await getAllBudaya();
    final target = jenis.trim().toUpperCase();
    final result = list
        .where((b) => b.jenis.trim().toUpperCase() == target)
        .toList();
    result.sort((a, b) => a.urutan.compareTo(b.urutan));
    return result;
  }

  /// Budaya yang sekaligus tempat wisata (ID tag berakhiran `-D`).
  Future<List<BudayaModel>> getDestinasiList() async {
    final list = await getAllBudaya();
    final result = list.where((b) => b.isDestinasi).toList();
    result.sort((a, b) => a.judul.compareTo(b.judul));
    return result;
  }

  /// Jumlah item per kategori, dipakai daftar "Koleksi Budaya" di beranda.
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
        final index =
            result.length < pool.length ? result.length : random.nextInt(pool.length);
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
      'relatedItems': jsonEncode(
        model.relatedItems.map((i) => i.toMap()).toList(),
      ),
    });
  }

  /// [previousKodeTag] diisi bila ID tag ikut berubah, supaya baris yang
  /// benar tetap ditemukan dan bookmark lama tidak menggantung.
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
        'relatedItems': jsonEncode(
          model.relatedItems.map((i) => i.toMap()).toList(),
        ),
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
    // Bersihkan bookmark yang menunjuk item yang sudah dihapus.
    await db.delete('bookmark', where: 'kodeTag = ?', whereArgs: [kodeTag]);
    return count;
  }
}

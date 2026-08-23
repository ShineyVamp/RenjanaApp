import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../../core/constants/wilayah_nusantara.dart';
import '../models/bookmark_model.dart';
import 'pemilik_akun.dart';
import 'budaya_repository.dart';
import 'sejarah_repository.dart';

class BookmarkRepository {
  final DbHelper _dbHelper;
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;

  BookmarkRepository({
    DbHelper? dbHelper,
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
  }) : _dbHelper = dbHelper ?? DbHelper(),
       _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository();

  static bool _legacyClaimed = false;

  int get _pemilik => idAkunAktif;

  // Mengklaim bookmark versi lama yang tersimpan tanpa pemilik.
  Future<Database> _db() async {
    final db = await _dbHelper.database;
    if (!_legacyClaimed) {
      _legacyClaimed = true;
      if (_pemilik > 0) {
        try {
          await db.rawUpdate(
            'UPDATE OR IGNORE bookmark SET userId = ? WHERE userId IS NULL',
            [_pemilik],
          );
        } catch (_) {}
      }
    }
    return db;
  }

  Future<bool> isBookmarked(String kodeTag) async {
    try {
      final db = await _db();
      final results = await db.query(
        'bookmark',
        where: 'kodeTag = ? AND userId = ?',
        whereArgs: [kodeTag, _pemilik],
      );
      return results.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleBookmark(String itemType, String kodeTag) async {
    final alreadyBookmarked = await isBookmarked(kodeTag);
    if (alreadyBookmarked) {
      await removeBookmark(kodeTag);
      return false;
    } else {
      await addBookmark(itemType, kodeTag);
      return true;
    }
  }

  Future<bool> addBookmark(String itemType, String kodeTag) async {
    try {
      final db = await _db();
      final id = await db.insert('bookmark', {
        'userId': _pemilik,
        'itemType': itemType.toLowerCase(),
        'kodeTag': kodeTag,
        'createdAt': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return id > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeBookmark(String kodeTag) async {
    try {
      final db = await _db();
      final count = await db.delete(
        'bookmark',
        where: 'kodeTag = ? AND userId = ?',
        whereArgs: [kodeTag, _pemilik],
      );
      return count > 0;
    } catch (_) {
      return false;
    }
  }

  Future<List<BookmarkItemModel>> getAllBookmarks() async {
    try {
      final db = await _db();
      final results = await db.query(
        'bookmark',
        where: 'userId = ?',
        whereArgs: [_pemilik],
        orderBy: 'id DESC',
      );

      final List<BookmarkItemModel> items = [];
      for (final map in results) {
        final itemType = (map['itemType'] as String? ?? 'sejarah')
            .toLowerCase();
        final kodeTag = map['kodeTag'] as String? ?? '';

        // Arsip dicari di database, sedangkan wilayah diambil dari katalog
        // konstanta karena pulau dan provinsi tidak disimpan sebagai baris.
        switch (itemType) {
          case 'sejarah':
            final sejarah = await _sejarahRepository.getSejarahByKodeTag(
              kodeTag,
            );
            if (sejarah != null) {
              items.add(BookmarkItemModel.fromMap(map, sejarah: sejarah));
            }

          case 'budaya':
            final budaya = await _budayaRepository.getBudayaByKodeTag(kodeTag);
            if (budaya != null) {
              items.add(BookmarkItemModel.fromMap(map, budaya: budaya));
            }

          case 'pulau':
            final pulau = pulauDariId(
              kodeTag.replaceFirst(BookmarkItemModel.awalanPulau, ''),
            );
            if (pulau != null) {
              items.add(BookmarkItemModel.fromMap(map, pulau: pulau));
            }

          case 'provinsi':
            final wilayah = provinsiDariNama(
              kodeTag.replaceFirst(BookmarkItemModel.awalanProvinsi, ''),
            );
            if (wilayah != null) {
              items.add(BookmarkItemModel.fromMap(map, wilayah: wilayah));
            }
        }
      }

      return items;
    } catch (_) {
      return [];
    }
  }
}

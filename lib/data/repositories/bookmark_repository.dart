import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../models/bookmark_model.dart';
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
  })  : _dbHelper = dbHelper ?? DbHelper(),
        _sejarahRepository = sejarahRepository ?? SejarahRepository(),
        _budayaRepository = budayaRepository ?? BudayaRepository();

  Future<bool> isBookmarked(String kodeTag) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        'bookmark',
        where: 'kodeTag = ?',
        whereArgs: [kodeTag],
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
      final db = await _dbHelper.database;
      final id = await db.insert(
        'bookmark',
        {
          'itemType': itemType.toLowerCase(),
          'kodeTag': kodeTag,
          'createdAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id > 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeBookmark(String kodeTag) async {
    try {
      final db = await _dbHelper.database;
      final count = await db.delete(
        'bookmark',
        where: 'kodeTag = ?',
        whereArgs: [kodeTag],
      );
      return count > 0;
    } catch (_) {
      return false;
    }
  }

  Future<List<BookmarkItemModel>> getAllBookmarks() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query('bookmark', orderBy: 'id DESC');

      final List<BookmarkItemModel> items = [];
      for (final map in results) {
        final itemType =
            (map['itemType'] as String? ?? 'sejarah').toLowerCase();
        final kodeTag = map['kodeTag'] as String? ?? '';

        if (itemType == 'sejarah') {
          final sejarah =
              await _sejarahRepository.getSejarahByKodeTag(kodeTag);
          if (sejarah != null) {
            items.add(BookmarkItemModel.fromMap(map, sejarah: sejarah));
          }
        } else if (itemType == 'budaya') {
          final budaya =
              await _budayaRepository.getBudayaByKodeTag(kodeTag);
          if (budaya != null) {
            items.add(BookmarkItemModel.fromMap(map, budaya: budaya));
          }
        }
      }

      return items;
    } catch (_) {
      return [];
    }
  }

  Future<int> getBookmarksCount() async {
    try {
      final db = await _dbHelper.database;
      final results =
          await db.rawQuery('SELECT COUNT(*) as total FROM bookmark');
      if (results.isNotEmpty && results.first['total'] != null) {
        return (results.first['total'] as num).toInt();
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}

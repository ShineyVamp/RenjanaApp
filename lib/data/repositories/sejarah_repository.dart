import 'dart:convert';
import 'dart:math';
import '../local/db_helper.dart';
import '../local/seed/sejarah_seed.dart';
import '../models/sejarah_model.dart';

class SejarahRepository {
  final DbHelper _dbHelper = DbHelper();

  Future<List<SejarahModel>> getAllSejarah() async {
    final db = await _dbHelper.database;
    final maps = await db.query('sejarah', orderBy: 'id DESC');

    if (maps.isEmpty) {
      return defaultSejarahList;
    }

    return maps.map((map) {
      List<TimelineItemModel> alur = [];
      if (map['alurPeristiwa'] != null &&
          map['alurPeristiwa'].toString().isNotEmpty) {
        try {
          final decoded = jsonDecode(map['alurPeristiwa'] as String);
          if (decoded is List) {
            alur = decoded
                .map(
                  (i) => TimelineItemModel.fromMap(i as Map<String, dynamic>),
                )
                .toList();
          }
        } catch (_) {}
      }

      return SejarahModel(
        id: map['id'] as int?,
        kodeTag: map['kodeTag'] as String? ?? 'HIS-01',
        tanggalKey: map['tanggalKey'] as String? ?? '170845',
        urutan: map['urutan'] as int? ?? 1,
        judul: map['judul'] as String? ?? '',
        subtitle: map['subtitle'] as String? ?? '',
        ringkasan: map['ringkasan'] as String? ?? '',
        gambarUtama:
            map['gambarUtama'] as String? ?? 'assets/images/1308history.png',
        alurPeristiwa: alur,
        provinsi: map['provinsi'] as String?,
      );
    }).toList();
  }

  Future<SejarahModel> getSejarahHariIni() async {
    final list = await getAllSejarah();
    final now = DateTime.now();
    final dayStr = now.day.toString().padLeft(2, '0');
    final monthStr = now.month.toString().padLeft(2, '0');
    final todayPrefix = '$dayStr$monthStr';

    try {
      return list.firstWhere(
        (s) => s.tanggalKey.startsWith(todayPrefix) && s.urutan == 1,
      );
    } catch (_) {
      return list.isNotEmpty ? list.first : defaultSejarahList.first;
    }
  }

  Future<SejarahModel?> getSejarahByKodeTag(String kodeTag) async {
    final list = await getAllSejarah();
    try {
      return list.firstWhere((s) => s.kodeTag == kodeTag);
    } catch (_) {
      return null;
    }
  }

  Future<List<SejarahModel>> getRandomSejarahList({
    int count = 5,
    SejarahModel? exclude,
  }) async {
    final list = await getAllSejarah();
    final pool = List<SejarahModel>.from(
      list.where((s) => exclude == null || s.kodeTag != exclude.kodeTag),
    )..shuffle();

    final List<SejarahModel> result = [];
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
        result.add(defaultSejarahList.first);
      }
    }
    return result;
  }

  Future<int> tambahSejarah(SejarahModel model) async {
    final db = await _dbHelper.database;
    return await db.insert('sejarah', {
      'kodeTag': model.kodeTag,
      'tanggalKey': model.tanggalKey,
      'urutan': model.urutan,
      'judul': model.judul,
      'subtitle': model.subtitle,
      'ringkasan': model.ringkasan,
      'gambarUtama': model.gambarUtama,
      'alurPeristiwa': jsonEncode(
        model.alurPeristiwa.map((i) => i.toMap()).toList(),
      ),
      'provinsi': model.provinsi,
    });
  }

  // [previousKodeTag] diisi bila ID tag ikut berubah; bookmark lama ikut
  // dipindahkan ke ID tag baru.
  Future<int> updateSejarah(
    SejarahModel model, {
    String? previousKodeTag,
  }) async {
    final db = await _dbHelper.database;
    final oldKodeTag = previousKodeTag ?? model.kodeTag;
    final count = await db.update(
      'sejarah',
      {
        'kodeTag': model.kodeTag,
        'tanggalKey': model.tanggalKey,
        'urutan': model.urutan,
        'judul': model.judul,
        'subtitle': model.subtitle,
        'ringkasan': model.ringkasan,
        'gambarUtama': model.gambarUtama,
        'alurPeristiwa': jsonEncode(
          model.alurPeristiwa.map((i) => i.toMap()).toList(),
        ),
        'provinsi': model.provinsi,
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

  Future<int> deleteSejarah(String kodeTag) async {
    final db = await _dbHelper.database;
    final count = await db.delete(
      'sejarah',
      where: 'kodeTag = ?',
      whereArgs: [kodeTag],
    );
    // hapus bookmark yang menunjuk item ini
    await db.delete('bookmark', where: 'kodeTag = ?', whereArgs: [kodeTag]);
    return count;
  }
}

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../data/local/seed/sejarah_seed.dart';
import '../models/sejarah_model.dart';

class SejarahRepository {
  final FirebaseFirestore _firestore;
  static List<SejarahModel>? _cacheSejarah;

  SejarahRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // in-memory cache sejarah
  static void bersihkanCache() {
    _cacheSejarah = null;
  }

  // ambil semua data
  Future<List<SejarahModel>> getAllSejarah({bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheSejarah != null && _cacheSejarah!.isNotEmpty) {
      return List<SejarahModel>.from(_cacheSejarah!);
    }

    try {
      final snap = await _firestore
          .collection('sejarah')
          .get()
          .timeout(const Duration(seconds: 10));
      if (snap.docs.isNotEmpty) {
        final list = snap.docs
            .map((doc) => SejarahModel.fromFirestore(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => a.urutan.compareTo(b.urutan));
        _cacheSejarah = list;
        return List<SejarahModel>.from(_cacheSejarah!);
      }
    } catch (_) {}

    _cacheSejarah = List<SejarahModel>.from(defaultSejarahList);
    return List<SejarahModel>.from(_cacheSejarah!);
  }

  // sejarah berdasarkan periode
  Future<List<SejarahModel>> getSejarahByPeriode(String periode) async {
    final list = await getAllSejarah();
    final target = periode.trim().toUpperCase();
    return list
        .where((s) => (s.periode?.trim().toUpperCase() ?? '') == target)
        .toList();
  }

  // sejarah hari ini
  Future<SejarahModel> getSejarahHariIni() async {
    final list = await getAllSejarah();
    if (list.isEmpty) return defaultSejarahList.first;

    final now = DateTime.now();
    final dayStr = now.day.toString().padLeft(2, '0');
    final monthStr = now.month.toString().padLeft(2, '0');
    final todayPrefix = '$dayStr$monthStr';

    try {
      return list.firstWhere(
        (s) => s.tanggalKey.startsWith(todayPrefix) && s.urutan == 1,
      );
    } catch (_) {}

    final pool = List<SejarahModel>.from(list)
      ..sort((a, b) => a.kodeTag.compareTo(b.kodeTag));
    // rotasi harian
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (now.year * 365 + dayOfYear) % pool.length;
    return pool[index];
  }

  // cari kode tag
  Future<SejarahModel?> getSejarahByKodeTag(String kodeTag) async {
    final list = await getAllSejarah();
    try {
      return list.firstWhere((s) => s.kodeTag == kodeTag);
    } catch (_) {
      return null;
    }
  }

  // acak sejarah
  Future<List<SejarahModel>> getRandomSejarahList({
    int count = 5,
    SejarahModel? exclude,
  }) async {
    final list = await getAllSejarah();
    final pool = List<SejarahModel>.from(
      list.where((s) => exclude == null || s.kodeTag != exclude.kodeTag),
    )..shuffle(Random());
    return pool.take(count).toList();
  }

  // tambah data
  Future<int> tambahSejarah(SejarahModel model) async {
    try {
      await _firestore
          .collection('sejarah')
          .doc(model.kodeTag)
          .set(model.toFirestore(), SetOptions(merge: true));
      bersihkanCache();
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // section kumpulkan gambar sejarah
  List<String> _kumpulkanGambar(SejarahModel model) {
    final list = <String>[];
    if (model.gambarUtama.isNotEmpty) {
      list.add(model.gambarUtama);
    }
    for (final a in model.alurPeristiwa) {
      if (a.imgPath != null && a.imgPath!.isNotEmpty) {
        list.add(a.imgPath!);
      }
    }
    final rawBlok = model.detailPeristiwa['blokKonten'];
    if (rawBlok is List) {
      for (final b in rawBlok) {
        if (b is Map && b['data'] is List) {
          for (final item in b['data']) {
            if (item is Map) {
              final img =
                  item['imgPath'] ?? item['gambarUrl'] ?? item['gambar'];
              if (img is String && img.isNotEmpty) {
                list.add(img);
              }
            }
          }
        }
      }
    }
    return list;
  }

  // perbarui data
  Future<int> updateSejarah(
    SejarahModel model, {
    String? previousKodeTag,
  }) async {
    final oldKodeTag = previousKodeTag ?? model.kodeTag;

    try {
      final oldDoc = await _firestore.collection('sejarah').doc(oldKodeTag).get();
      if (oldDoc.exists && oldDoc.data() != null) {
        final oldModel = SejarahModel.fromFirestore(oldDoc.data()!);
        final oldImages = _kumpulkanGambar(oldModel).toSet();
        final newImages = _kumpulkanGambar(model).toSet();
        final unusedImages = oldImages.difference(newImages).toList();
        if (unusedImages.isNotEmpty) {
          await CloudinaryService().deleteImagesByUrls(unusedImages);
        }
      }

      await _firestore
          .collection('sejarah')
          .doc(model.kodeTag)
          .set(model.toFirestore(), SetOptions(merge: true));
      if (oldKodeTag != model.kodeTag) {
        await _firestore.collection('sejarah').doc(oldKodeTag).delete();
      }
      bersihkanCache();
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // hapus data
  Future<int> deleteSejarah(String kodeTag) async {
    try {
      final doc = await _firestore.collection('sejarah').doc(kodeTag).get();
      if (doc.exists && doc.data() != null) {
        final oldModel = SejarahModel.fromFirestore(doc.data()!);
        final images = _kumpulkanGambar(oldModel);
        if (images.isNotEmpty) {
          await CloudinaryService().deleteImagesByUrls(images);
        }
      }

      await _firestore.collection('sejarah').doc(kodeTag).delete();
      bersihkanCache();
      return 1;
    } catch (_) {
      return 0;
    }
  }
}

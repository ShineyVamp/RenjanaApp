import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../models/budaya_model.dart';

class BudayaRepository {
  final FirebaseFirestore _firestore;
  static List<BudayaModel>? _cacheBudaya;

  BudayaRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // in-memory cache budaya
  static void bersihkanCache() {
    _cacheBudaya = null;
  }

  // ambil semua data
  Future<List<BudayaModel>> getAllBudaya({bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheBudaya != null && _cacheBudaya!.isNotEmpty) {
      return _cacheBudaya!;
    }

    try {
      final snap = await _firestore
          .collection('budaya')
          .get()
          .timeout(const Duration(seconds: 10));
      if (snap.docs.isNotEmpty) {
        final list = snap.docs
            .map((doc) => BudayaModel.fromFirestore(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => a.urutan.compareTo(b.urutan));
        _cacheBudaya = list;
        return list;
      }
    } catch (_) {}

    return _cacheBudaya ?? const [];
  }

  // budaya hari ini
  Future<BudayaModel?> getBudayaHariIni() async {
    final list = await getAllBudaya();
    if (list.isEmpty) return null;

    final pool = List<BudayaModel>.from(list)
      ..sort((a, b) => a.kodeTag.compareTo(b.kodeTag));
    final now = DateTime.now();
    final benihHariIni =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return pool[Random(benihHariIni).nextInt(pool.length)];
  }

  // budaya berdasarkan jenis
  Future<List<BudayaModel>> getBudayaByJenis(String jenis) async {
    final list = await getAllBudaya();
    final target = jenis.trim().toUpperCase();
    final result = list
        .where((b) => b.jenis.trim().toUpperCase() == target)
        .toList();
    result.sort((a, b) => a.urutan.compareTo(b.urutan));
    return result;
  }

  // daftar destinasi
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

  // jumlah destinasi
  Future<int> getDestinasiCount() async {
    final list = await getAllBudaya();
    return list.where((b) => b.isDestinasi).length;
  }

  // kelompok jenis
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

  // cari kode tag
  Future<BudayaModel?> getBudayaByKodeTag(String kodeTag) async {
    final list = await getAllBudaya();
    try {
      return list.firstWhere((b) => b.kodeTag == kodeTag);
    } catch (_) {
      return null;
    }
  }

  // acak budaya
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
        break;
      }
    }
    return result;
  }

  // tambah data
  Future<int> tambahBudaya(BudayaModel model) async {
    try {
      await _firestore
          .collection('budaya')
          .doc(model.kodeTag)
          .set(model.toFirestore(), SetOptions(merge: true));
      bersihkanCache();
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // kumpulkan gambar budaya
  List<String> _kumpulkanGambar(BudayaModel model) {
    final list = <String>[];
    if (model.gambarUtama.isNotEmpty) list.add(model.gambarUtama);
    if (model.gambarMaknaSpiritual != null &&
        model.gambarMaknaSpiritual!.isNotEmpty) {
      list.add(model.gambarMaknaSpiritual!);
    }
    if (model.gambarKonteksBudaya != null &&
        model.gambarKonteksBudaya!.isNotEmpty) {
      list.add(model.gambarKonteksBudaya!);
    }
    if (model.mediaUrl != null && model.mediaUrl!.isNotEmpty) {
      list.add(model.mediaUrl!);
    }
    for (final val in model.detailKategori.values) {
      if (val is String && val.contains('cloudinary.com')) {
        list.add(val);
      } else if (val is List) {
        for (final item in val) {
          if (item is String && item.contains('cloudinary.com')) {
            list.add(item);
          }
        }
      }
    }
    return list;
  }

  // perbarui data
  Future<int> updateBudaya(BudayaModel model, {String? previousKodeTag}) async {
    final oldKodeTag = previousKodeTag ?? model.kodeTag;

    try {
      final oldDoc =
          await _firestore.collection('budaya').doc(oldKodeTag).get();
      if (oldDoc.exists && oldDoc.data() != null) {
        final oldModel =
            BudayaModel.fromFirestore(oldDoc.data()!, oldDoc.id);
        final oldImages = _kumpulkanGambar(oldModel).toSet();
        final newImages = _kumpulkanGambar(model).toSet();
        final unusedImages = oldImages.difference(newImages).toList();
        if (unusedImages.isNotEmpty) {
          await CloudinaryService().deleteImagesByUrls(unusedImages);
        }
      }

      await _firestore
          .collection('budaya')
          .doc(model.kodeTag)
          .set(model.toFirestore(), SetOptions(merge: true));
      if (oldKodeTag != model.kodeTag) {
        await _firestore.collection('budaya').doc(oldKodeTag).delete();
      }
      bersihkanCache();
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // hapus data
  Future<int> deleteBudaya(String kodeTag) async {
    try {
      final doc = await _firestore.collection('budaya').doc(kodeTag).get();
      if (doc.exists && doc.data() != null) {
        final oldModel = BudayaModel.fromFirestore(doc.data()!, doc.id);
        final images = _kumpulkanGambar(oldModel);
        if (images.isNotEmpty) {
          await CloudinaryService().deleteImagesByUrls(images);
        }
      }

      await _firestore.collection('budaya').doc(kodeTag).delete();
      bersihkanCache();
      return 1;
    } catch (_) {
      return 0;
    }
  }
}

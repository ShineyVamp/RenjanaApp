import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:renjana/features/wilayah/data/static/data_wilayah_nusantara.dart';
import '../../../../core/storage/preference_handler.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';
import '../models/bookmark_model.dart';

class BookmarkRepository {
  final FirebaseFirestore _firestore;
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;
  static Set<String>? _cachedTags;
  static List<BookmarkItemModel>? _cachedBookmarks;

  BookmarkRepository({
    FirebaseFirestore? firestore,
    SejarahRepository? sejarahRepository,
    BudayaRepository? budayaRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _sejarahRepository = sejarahRepository ?? SejarahRepository(),
       _budayaRepository = budayaRepository ?? BudayaRepository();

  String get _uid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final user = PreferenceHandler.user;
    if (user?.uid != null && user!.uid!.isNotEmpty) return user.uid!;
    final id = PreferenceHandler.userId;
    if (id > 0) return 'user_$id';
    return 'guest';
  }

  CollectionReference<Map<String, dynamic>> get _koleksi =>
      _firestore.collection('users').doc(_uid).collection('bookmarks');

  // section bersihkan cache
  static void bersihkanCache() {
    _cachedTags = null;
    _cachedBookmarks = null;
  }

  Future<bool> isBookmarked(String kodeTag) async {
    final tag = kodeTag.trim();
    if (tag.isEmpty) return false;

    if (_cachedTags != null) {
      return _cachedTags!.contains(tag);
    }

    try {
      final snap = await _koleksi.get();
      _cachedTags = snap.docs.map((d) => d.id.trim()).toSet();
      return _cachedTags!.contains(tag);
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
    final tag = kodeTag.trim();
    if (tag.isEmpty) return false;

    _cachedTags ??= {};
    _cachedTags!.add(tag);
    _cachedBookmarks = null;

    try {
      await _koleksi.doc(tag).set({
        'kodeTag': tag,
        'itemType': itemType.toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeBookmark(String kodeTag) async {
    final tag = kodeTag.trim();
    if (tag.isEmpty) return false;

    _cachedTags?.remove(tag);
    _cachedBookmarks = null;

    try {
      await _koleksi.doc(tag).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  // section ambil semua bookmark
  Future<List<BookmarkItemModel>> getAllBookmarks({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBookmarks != null) {
      return _cachedBookmarks!;
    }

    try {
      final snap = await _koleksi.get();
      _cachedTags = snap.docs.map((d) => d.id.trim()).toSet();

      final futures = snap.docs.map((doc) async {
        final map = doc.data();
        final itemType = (map['itemType'] as String? ?? 'sejarah').toLowerCase();
        final kodeTag = doc.id;

        switch (itemType) {
          case 'sejarah':
            final sejarah = await _sejarahRepository.getSejarahByKodeTag(kodeTag);
            if (sejarah != null) {
              return BookmarkItemModel.fromMap(map, sejarah: sejarah);
            }
          case 'budaya':
            final budaya = await _budayaRepository.getBudayaByKodeTag(kodeTag);
            if (budaya != null) {
              return BookmarkItemModel.fromMap(map, budaya: budaya);
            }
          case 'pulau':
            final pulau = pulauDariId(
              kodeTag.replaceFirst(BookmarkItemModel.awalanPulau, ''),
            );
            if (pulau != null) {
              return BookmarkItemModel.fromMap(map, pulau: pulau);
            }
          case 'provinsi':
            final wilayah = provinsiDariNama(
              kodeTag.replaceFirst(BookmarkItemModel.awalanProvinsi, ''),
            );
            if (wilayah != null) {
              return BookmarkItemModel.fromMap(map, wilayah: wilayah);
            }
        }
        return null;
      });

      final resolved = await Future.wait(futures);
      final items = resolved.whereType<BookmarkItemModel>().toList();
      _cachedBookmarks = items;
      return items;
    } catch (_) {
      return _cachedBookmarks ?? [];
    }
  }
}

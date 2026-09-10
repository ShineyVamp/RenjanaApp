import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/wilayah_nusantara.dart';
import '../../../../core/storage/preference_handler.dart';
import 'package:renjana/features/budaya/data/repositories/budaya_repository.dart';
import 'package:renjana/features/sejarah/data/repositories/sejarah_repository.dart';
import '../models/bookmark_model.dart';

class BookmarkRepository {
  final FirebaseFirestore _firestore;
  final SejarahRepository _sejarahRepository;
  final BudayaRepository _budayaRepository;
  static Set<String>? _cachedTags;

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

  static void bersihkanCache() {
    _cachedTags = null;
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

    try {
      await _koleksi.doc(tag).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<BookmarkItemModel>> getAllBookmarks() async {
    try {
      final snap = await _koleksi.get();
      _cachedTags = snap.docs.map((d) => d.id.trim()).toSet();

      final List<BookmarkItemModel> items = [];
      for (final doc in snap.docs) {
        final map = doc.data();
        final itemType = (map['itemType'] as String? ?? 'sejarah').toLowerCase();
        final kodeTag = doc.id;

        switch (itemType) {
          case 'sejarah':
            final sejarah = await _sejarahRepository.getSejarahByKodeTag(kodeTag);
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

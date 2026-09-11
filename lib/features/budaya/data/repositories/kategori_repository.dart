import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/katalog_kategori.dart';
import '../../../../features/budaya/data/repositories/budaya_repository.dart';
import '../../../../features/quiz/data/repositories/quiz_repository.dart';

class PemakaiKategori {
  final int arsip;
  final int soal;

  const PemakaiKategori({this.arsip = 0, this.soal = 0});

  int get total => arsip + soal;
  bool get kosong => total == 0;

  String get ringkasan => [
    if (arsip > 0) '$arsip arsip',
    if (soal > 0) '$soal soal',
  ].join(', ');
}

class KategoriRepository {
  final FirebaseFirestore _firestore;

  static List<KategoriItem>? _cachedSemua;

  KategoriRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // muat kategori
  Future<void> muat() async {
    try {
      final snap = await _firestore.collection('kategori').get();
      if (snap.docs.isNotEmpty) {
        final items = snap.docs
            .map((doc) => KategoriItem.fromFirestore(doc.data(), doc.id))
            .toList();
        items.sort((a, b) => a.urutan.compareTo(b.urutan));

        _cachedSemua = items;
        final isi = <String, List<KategoriItem>>{};
        for (final item in items) {
          if (item.kode.isEmpty) continue;
          isi.putIfAbsent(item.ranah, () => []).add(item);
        }
        KatalogKategori.pasang(isi);
        return;
      }
    } catch (_) {}

    // pasang dari katalog default jika firestore belum terisi
    KatalogKategori.pasang({});
  }

  // ambil semua kategori satu ranah
  Future<List<KategoriItem>> semua(String ranah) async {
    if (_cachedSemua != null) {
      final items = _cachedSemua!.where((k) => k.ranah == ranah).toList();
      items.sort((a, b) => a.urutan.compareTo(b.urutan));
      return items;
    }

    try {
      final snap = await _firestore
          .collection('kategori')
          .where('ranah', isEqualTo: ranah)
          .get();
      if (snap.docs.isNotEmpty) {
        final items = snap.docs
            .map((doc) => KategoriItem.fromFirestore(doc.data(), doc.id))
            .toList();
        items.sort((a, b) => a.urutan.compareTo(b.urutan));
        return items;
      }
    } catch (_) {}

    return KatalogKategori.ranah(ranah);
  }

  // periksa kode terpakai
  Future<bool> kodeTerpakai(String ranah, String kode, {int? kecuali}) async {
    final list = await semua(ranah);
    final targetKode = kode.trim().toUpperCase();
    return list.any((k) => k.kode.trim().toUpperCase() == targetKode && k.id != kecuali);
  }

  // simpan kategori
  Future<void> simpan(KategoriItem item) async {
    final docId = '${item.ranah}_${item.kode}';

    try {
      await _firestore
          .collection('kategori')
          .doc(docId)
          .set(item.toFirestore(), SetOptions(merge: true));
    } catch (_) {}

    _cachedSemua = null;
    await muat();
  }

  // urutkan kategori
  Future<void> urutkan(List<KategoriItem> urut) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < urut.length; i++) {
        final item = urut[i];
        final docId = '${item.ranah}_${item.kode}';
        final docRef = _firestore.collection('kategori').doc(docId);
        batch.update(docRef, {'urutan': i + 1});
      }
      await batch.commit();
    } catch (_) {}

    _cachedSemua = null;
    await muat();
  }

  // hapus kategori
  Future<bool> hapus(KategoriItem item) async {
    if (item.bawaan) return false;

    final pemakai = await jumlahPemakai(item);
    if (!pemakai.kosong) return false;

    try {
      final docId = '${item.ranah}_${item.kode}';
      await _firestore.collection('kategori').doc(docId).delete();
    } catch (_) {}

    _cachedSemua = null;
    await muat();
    return true;
  }

  // jumlah pemakai kategori
  Future<PemakaiKategori> jumlahPemakai(KategoriItem item) async {
    if (item.ranah != ranahBudaya) return const PemakaiKategori();

    final kode = item.kode.trim().toUpperCase();
    int arsip = 0;
    int soal = 0;

    try {
      final listBudaya = await BudayaRepository().getAllBudaya();
      arsip = listBudaya.where((b) => b.jenis.trim().toUpperCase() == kode).length;
    } catch (_) {}

    try {
      final listQuiz = await QuizRepository().getAllQuizzes();
      soal = listQuiz.where((q) => q.subKategori.trim().toUpperCase() == kode).length;
    } catch (_) {}

    return PemakaiKategori(arsip: arsip, soal: soal);
  }

  // bersihkan cache
  static void bersihkanCache() {
    _cachedSemua = null;
  }
}

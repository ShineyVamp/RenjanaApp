import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/laporan_model.dart';

class LaporanRepository {
  final FirebaseFirestore _firestore;

  static List<LaporanModel>? _cachedLaporan;

  LaporanRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // buat laporan
  Future<int> buatLaporan(LaporanModel laporan) async {
    try {
      final docRef = _firestore.collection('laporan').doc();
      final id = laporan.id ?? docRef.id.hashCode.abs();
      final data = laporan.toMap();
      data['id'] = id;
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      _cachedLaporan = null;
      return id;
    } catch (_) {
      return 0;
    }
  }

  // daftar laporan
  Future<List<LaporanModel>> getSemuaLaporan({String? status}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('laporan')
          .orderBy('dibuatPada', descending: true)
          .limit(50);

      if (status != null && status.isNotEmpty && status != 'semua') {
        query = _firestore
            .collection('laporan')
            .where('status', isEqualTo: status)
            .limit(50);
      }

      final snapshot = await query.get();
      final list = snapshot.docs.map((doc) {
        final d = doc.data();
        d['id'] = (d['id'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? doc.id.hashCode.abs();
        return LaporanModel.fromMap(d);
      }).toList();

      _cachedLaporan = list;
      return list;
    } catch (_) {
      return _cachedLaporan ?? const [];
    }
  }

  // hitung laporan menunggu
  Future<int> hitungLaporanMenunggu() async {
    try {
      final snapshot = await _firestore
          .collection('laporan')
          .where('status', isEqualTo: 'menunggu')
          .get();
      return snapshot.docs.length;
    } catch (_) {
      return 0;
    }
  }

  // perbarui status
  Future<int> perbaruiStatus(int id, String status) async {
    try {
      final snap = await _firestore
          .collection('laporan')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('laporan').doc('$id').update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _cachedLaporan = null;
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // hapus laporan
  Future<int> hapusLaporan(int id) async {
    try {
      final snap = await _firestore
          .collection('laporan')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      } else {
        await _firestore.collection('laporan').doc('$id').delete();
      }

      _cachedLaporan = null;
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // bersihkan cache
  static void bersihkanCache() {
    _cachedLaporan = null;
  }
}

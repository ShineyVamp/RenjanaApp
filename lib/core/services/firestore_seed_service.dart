import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/seed/budaya_seed.dart';
import '../../data/local/seed/sejarah_seed.dart';
import '../constants/katalog_kategori.dart';
import 'cloudinary_service.dart';

class FirestoreSeedService {
  final FirebaseFirestore _firestore;

  FirestoreSeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // inisialisasi konten ensiklopedia
  Future<void> inisialisasiKontenEnsiklopedia() async {
    try {
      debugPrint('[Seed] Memulai sinkronisasi ensiklopedia di latar belakang...');
      await Future.wait([
        _seedBudaya(),
        _seedSejarah(),
        _seedKategori(),
      ]);
      debugPrint('[Seed] Sinkronisasi ensiklopedia selesai.');
    } catch (e) {
      debugPrint('[Seed] Gagal sinkronisasi: $e');
    }
  }

  // seed budaya
  Future<void> _seedBudaya() async {
    try {
      final existingDocs = await _firestore.collection('budaya').get();
      final Map<String, Map<String, dynamic>> existingMap = {
        for (final doc in existingDocs.docs) doc.id: doc.data(),
      };

      for (final item in defaultBudayaList) {
        final existing = existingMap[item.kodeTag];
        final data = item.toFirestore();

        // periksa gambar utama
        final existingGambar = existing?['gambarUtama'] as String?;
        if (existingGambar != null && existingGambar.startsWith('http')) {
          data['gambarUtama'] = existingGambar;
        } else if (item.gambarUtama.startsWith('assets/')) {
          data['gambarUtama'] = await CloudinaryService().uploadAsset(
            item.gambarUtama,
            subFolder: 'budaya',
          );
        }

        // periksa gambar makna spiritual
        final existingMakna = existing?['gambarMaknaSpiritual'] as String?;
        if (existingMakna != null && existingMakna.startsWith('http')) {
          data['gambarMaknaSpiritual'] = existingMakna;
        } else if (item.gambarMaknaSpiritual != null &&
            item.gambarMaknaSpiritual!.startsWith('assets/')) {
          data['gambarMaknaSpiritual'] = await CloudinaryService().uploadAsset(
            item.gambarMaknaSpiritual!,
            subFolder: 'budaya',
          );
        }

        // periksa gambar konteks budaya
        final existingKonteks = existing?['gambarKonteksBudaya'] as String?;
        if (existingKonteks != null && existingKonteks.startsWith('http')) {
          data['gambarKonteksBudaya'] = existingKonteks;
        } else if (item.gambarKonteksBudaya != null &&
            item.gambarKonteksBudaya!.startsWith('assets/')) {
          data['gambarKonteksBudaya'] = await CloudinaryService().uploadAsset(
            item.gambarKonteksBudaya!,
            subFolder: 'budaya',
          );
        }

        // simpan jika data baru atau gambar berubah
        final perluSimpan = existing == null ||
            existingGambar != data['gambarUtama'] ||
            existingMakna != data['gambarMaknaSpiritual'] ||
            existingKonteks != data['gambarKonteksBudaya'];

        if (perluSimpan) {
          await _firestore
              .collection('budaya')
              .doc(item.kodeTag)
              .set(data, SetOptions(merge: true));
        }
      }
    } catch (_) {}
  }

  // seed sejarah
  Future<void> _seedSejarah() async {
    try {
      final existingDocs = await _firestore.collection('sejarah').get();
      final Map<String, Map<String, dynamic>> existingMap = {
        for (final doc in existingDocs.docs) doc.id: doc.data(),
      };

      for (final item in defaultSejarahList) {
        final existing = existingMap[item.kodeTag];
        final data = item.toFirestore();

        // periksa gambar utama
        final existingGambar = existing?['gambarUtama'] as String?;
        if (existingGambar != null && existingGambar.startsWith('http')) {
          data['gambarUtama'] = existingGambar;
        } else if (item.gambarUtama.startsWith('assets/')) {
          data['gambarUtama'] = await CloudinaryService().uploadAsset(
            item.gambarUtama,
            subFolder: 'sejarah',
          );
        }

        // periksa gambar alur peristiwa
        final existingAlurRaw = existing?['alurPeristiwa'];
        final List<Map<String, dynamic>> alurList = [];
        bool adaAlurBaru = false;

        for (var i = 0; i < item.alurPeristiwa.length; i++) {
          final alur = item.alurPeristiwa[i];
          final alurMap = alur.toMap();
          String? existingImg;

          if (existingAlurRaw is List &&
              i < existingAlurRaw.length &&
              existingAlurRaw[i] is Map) {
            existingImg = existingAlurRaw[i]['imgPath'] as String?;
          }

          if (existingImg != null && existingImg.startsWith('http')) {
            alurMap['imgPath'] = existingImg;
          } else if (alur.imgPath != null && alur.imgPath!.startsWith('assets/')) {
            final url = await CloudinaryService().uploadAsset(
              alur.imgPath!,
              subFolder: 'sejarah',
            );
            alurMap['imgPath'] = url;
            if (url != alur.imgPath) adaAlurBaru = true;
          }
          alurList.add(alurMap);
        }
        data['alurPeristiwa'] = alurList;

        final perluSimpan = existing == null ||
            existingGambar != data['gambarUtama'] ||
            adaAlurBaru;

        if (perluSimpan) {
          await _firestore
              .collection('sejarah')
              .doc(item.kodeTag)
              .set(data, SetOptions(merge: true));
        }
      }
    } catch (_) {}
  }

  // seed kategori
  Future<void> _seedKategori() async {
    try {
      final snap = await _firestore.collection('kategori').limit(1).get();
      if (snap.docs.isNotEmpty) return;

      final batch = _firestore.batch();
      for (final ranah in ranahKategori) {
        final daftar = kategoriBawaan(ranah);
        for (final item in daftar) {
          final docId = '${ranah}_${item.kode}';
          final docRef = _firestore.collection('kategori').doc(docId);
          batch.set(docRef, item.toFirestore(), SetOptions(merge: true));
        }
      }
      await batch.commit();
    } catch (_) {}
  }
}

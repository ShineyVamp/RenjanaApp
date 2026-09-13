import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/seed/budaya_seed.dart';
import '../../data/local/seed/sejarah_seed.dart';
import '../../features/wilayah/data/repositories/wilayah_repository.dart';
import '../../features/wilayah/data/static/data_wilayah_nusantara.dart';
import '../constants/katalog_kategori.dart';
import 'cloudinary_service.dart';

class FirestoreSeedService {
  final FirebaseFirestore _firestore;

  FirestoreSeedService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // section inisialisasi konten ensiklopedia
  Future<void> inisialisasiKontenEnsiklopedia() async {
    try {
      debugPrint('[Seed] Memulai sinkronisasi ensiklopedia di latar belakang...');
      await Future.wait([
        _seedBudaya(),
        _seedSejarah(),
        _seedKategori(),
        _seedWilayah(),
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

  // section seed kategori
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


  // section seed wilayah
  Future<void> _seedWilayah() async {
    try {
      final pulauDocs = await _firestore.collection('wilayah_pulau').get();
      final existingPulauMap = {
        for (final doc in pulauDocs.docs) doc.id: doc.data(),
      };

      final provDocs = await _firestore.collection('wilayah_provinsi').get();
      final existingProvMap = {
        for (final doc in provDocs.docs) doc.id: doc.data(),
      };

      bool adaPerubahan = false;
      final Map<String, String> uploadedProvGambar = {};

      for (final pulau in gugusPulauList) {
        final existing = existingPulauMap[pulau.id];
        final data = pulau.toMap();

        final existingGambar = existing?['gambar'] as String?;
        if (existingGambar != null && existingGambar.startsWith('http')) {
          data['gambar'] = existingGambar;
        } else if (pulau.gambar.isNotEmpty && pulau.gambar.startsWith('assets/')) {
          data['gambar'] = await CloudinaryService().uploadAsset(
            pulau.gambar,
            subFolder: 'wilayah',
          );
          adaPerubahan = true;
        }

        final rawProvinsi = data['provinsi'] as List<dynamic>? ?? [];
        for (var i = 0; i < pulau.provinsi.length; i++) {
          final prov = pulau.provinsi[i];
          if (i < rawProvinsi.length && rawProvinsi[i] is Map<String, dynamic>) {
            final provMap = rawProvinsi[i] as Map<String, dynamic>;
            final existingProvDoc = existingProvMap[prov.nama.trim()];
            final existingProvImg = existingProvDoc?['gambar'] as String?;

            if (existingProvImg != null && existingProvImg.startsWith('http')) {
              provMap['gambar'] = existingProvImg;
              uploadedProvGambar[prov.nama.trim()] = existingProvImg;
            } else if (prov.gambar != null && prov.gambar!.startsWith('assets/')) {
              final uploadedUrl = await CloudinaryService().uploadAsset(
                prov.gambar!,
                subFolder: 'wilayah',
              );
              provMap['gambar'] = uploadedUrl;
              uploadedProvGambar[prov.nama.trim()] = uploadedUrl;
              adaPerubahan = true;
            } else if (existingProvImg != null) {
              provMap['gambar'] = existingProvImg;
            }
          }
        }

        await _firestore
            .collection('wilayah_pulau')
            .doc(pulau.id)
            .set(data, SetOptions(merge: true));
      }

      for (final pulau in gugusPulauList) {
        for (final prov in pulau.provinsi) {
          final docId = prov.nama.trim();
          final provData = prov.toMap();
          provData['pulauId'] = pulau.id;
          provData['pulauNama'] = pulau.nama;

          final existingProv = existingProvMap[docId];
          final existingGambar = existingProv?['gambar'] as String?;

          if (uploadedProvGambar.containsKey(docId)) {
            provData['gambar'] = uploadedProvGambar[docId];
          } else if (existingGambar != null && existingGambar.startsWith('http')) {
            provData['gambar'] = existingGambar;
          } else if (prov.gambar != null && prov.gambar!.startsWith('assets/')) {
            final uploadedUrl = await CloudinaryService().uploadAsset(
              prov.gambar!,
              subFolder: 'wilayah',
            );
            provData['gambar'] = uploadedUrl;
            adaPerubahan = true;
          } else if (existingGambar != null) {
            provData['gambar'] = existingGambar;
          }

          await _firestore
              .collection('wilayah_provinsi')
              .doc(docId)
              .set(provData, SetOptions(merge: true));
        }
      }

      if (adaPerubahan) {
        WilayahRepository.bersihkanCache();
      }
    } catch (_) {}
  }
}

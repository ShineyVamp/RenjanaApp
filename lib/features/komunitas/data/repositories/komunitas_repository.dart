import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/storage/preference_handler.dart';
import '../../../../core/storage/user_session.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/komunitas_model.dart';
import '../models/notifikasi_model.dart';

// repositori komunitas
class KomunitasRepository {
  final FirebaseFirestore _firestore;

  static List<DiskusiModel>? _cachedDiskusi;
  static final Map<int, List<JawabanModel>> _cachedJawaban = {};
  static List<NotifikasiKomunitasModel>? _cachedNotifikasi;
  static Set<int> _cachedIdSuaraSayaDiskusi = {};
  static Set<int> _cachedIdSuaraSayaJawaban = {};
  static bool _suaraDiskusiLoaded = false;
  static bool _suaraJawabanLoaded = false;

  KomunitasRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  int get _pemilik => idAkunAktif;

  String get _userUid {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) return uid;
    final intId = idAkunAktif;
    return intId > 0 ? 'user_$intId' : 'guest';
  }

  // section cache foto pengguna
  static final Map<String, String?> _userPhotoCache = {};

  Future<void> _isiCacheFoto(List<Map<String, dynamic>> items) async {
    final uidsToFetch = <String>{};
    for (final item in items) {
      final uid = item['userUid'] as String?;
      final foto = item['fotoProfil'] as String?;
      if (uid != null && uid.isNotEmpty) {
        if (foto != null && foto.isNotEmpty) {
          _userPhotoCache[uid] = foto;
        } else if (!_userPhotoCache.containsKey(uid)) {
          uidsToFetch.add(uid);
        }
      }
    }

    if (uidsToFetch.isEmpty) return;

    try {
      final list = uidsToFetch.toList();
      for (var i = 0; i < list.length; i += 10) {
        final chunk = list.sublist(i, i + 10 > list.length ? list.length : i + 10);
        final snap = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        for (final doc in snap.docs) {
          final foto = doc.data()['fotoProfil'] as String?;
          _userPhotoCache[doc.id] = foto;
          final uname = doc.data()['username'] as String?;
          if (uname != null && uname.isNotEmpty) {
            _userPhotoCache[uname.toLowerCase()] = foto;
          }
        }
        for (final uid in chunk) {
          _userPhotoCache.putIfAbsent(uid, () => null);
        }
      }
    } catch (_) {}
  }

  String? _ambilFotoProfil(Map<String, dynamic> d) {
    final uid = d['userUid'] as String?;
    final uname = (d['username'] as String?)?.toLowerCase();
    if (uid != null && _userPhotoCache[uid] != null && _userPhotoCache[uid]!.isNotEmpty) {
      return _userPhotoCache[uid];
    }
    if (uname != null && _userPhotoCache[uname] != null && _userPhotoCache[uname]!.isNotEmpty) {
      return _userPhotoCache[uname];
    }
    final docFoto = d['fotoProfil'] as String?;
    if (docFoto != null && docFoto.isNotEmpty) {
      if (uid != null) _userPhotoCache[uid] = docFoto;
      return docFoto;
    }
    return null;
  }

  // section ambil id suara pengguna aktif
  Future<Set<int>> getDaftarIdSuaraSaya(String targetTipe) async {
    final uid = _userUid;
    if (uid == 'guest') return const {};
    try {
      final snap = await _firestore
          .collection('suara')
          .where('userUid', isEqualTo: uid)
          .where('targetTipe', isEqualTo: targetTipe)
          .get();
      final set = snap.docs
          .map((d) => (d.data()['targetId'] as num?)?.toInt())
          .whereType<int>()
          .toSet();
      if (targetTipe == 'diskusi') {
        _cachedIdSuaraSayaDiskusi = Set<int>.from(set);
        _suaraDiskusiLoaded = true;
      } else {
        _cachedIdSuaraSayaJawaban = Set<int>.from(set);
        _suaraJawabanLoaded = true;
      }
      return set;
    } catch (_) {
      return targetTipe == 'diskusi'
          ? _cachedIdSuaraSayaDiskusi
          : _cachedIdSuaraSayaJawaban;
    }
  }

  // daftar diskusi
  Future<List<DiskusiModel>> getDaftarDiskusi({
    String? kategori,
    String? refArsip,
    String? kataKunci,
    bool forceRefresh = false,
  }) async {
    List<DiskusiModel> daftar;
    if (!forceRefresh && _cachedDiskusi != null) {
      daftar = _cachedDiskusi!;
    } else {
      try {
        final votedDiskusi = await getDaftarIdSuaraSaya('diskusi');
        final snapshot = await _firestore
            .collection('diskusi')
            .orderBy('dibuatPada', descending: true)
            .limit(60)
            .get();

        final maps = snapshot.docs.map((doc) {
          final d = doc.data();
          d['id'] = (d['id'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? doc.id.hashCode.abs();
          return d;
        }).toList();

        await _isiCacheFoto(maps);

        daftar = maps.map((d) {
          final disId = d['id'] as int;
          return DiskusiModel.fromMap(
            d,
            fotoProfil: _ambilFotoProfil(d),
            suaraSaya: votedDiskusi.contains(disId) ? 1 : 0,
          );
        }).toList();

        _cachedDiskusi = daftar;
      } catch (_) {
        daftar = _cachedDiskusi ?? const [];
      }
    }

    var hasil = List<DiskusiModel>.from(daftar);

    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      hasil = hasil.where((d) => d.kategori == kategori).toList();
    }

    if (refArsip != null && refArsip.isNotEmpty) {
      hasil = hasil.where((d) => d.refArsip == refArsip).toList();
    }

    if (kataKunci != null && kataKunci.trim().isNotEmpty) {
      final k = kataKunci.trim().toLowerCase();
      hasil = hasil.where((d) {
        return d.judul.toLowerCase().contains(k) || d.isi.toLowerCase().contains(k);
      }).toList();
    }

    return hasil;
  }

  // section stream realtime daftar diskusi
  Stream<List<DiskusiModel>> streamDaftarDiskusi({
    String? kategori,
    String? refArsip,
    String? kataKunci,
  }) {
    if (!_suaraDiskusiLoaded) {
      getDaftarIdSuaraSaya('diskusi');
    }
    return _firestore
        .collection('diskusi')
        .orderBy('dibuatPada', descending: true)
        .limit(60)
        .snapshots()
        .map((snapshot) {
      final maps = snapshot.docs.map((doc) {
        final d = doc.data();
        final id = (d['id'] as num?)?.toInt() ??
            int.tryParse(doc.id) ??
            doc.id.hashCode.abs();
        d['id'] = id;
        return d;
      }).toList();

      _isiCacheFoto(maps);

      final daftar = maps.map((d) {
        final id = d['id'] as int;
        return DiskusiModel.fromMap(
          d,
          fotoProfil: _ambilFotoProfil(d),
          suaraSaya: _cachedIdSuaraSayaDiskusi.contains(id) ? 1 : 0,
        );
      }).toList();

      _cachedDiskusi = daftar;

      var hasil = List<DiskusiModel>.from(daftar);
      if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
        hasil = hasil.where((d) => d.kategori == kategori).toList();
      }
      if (refArsip != null && refArsip.isNotEmpty) {
        hasil = hasil.where((d) => d.refArsip == refArsip).toList();
      }
      if (kataKunci != null && kataKunci.trim().isNotEmpty) {
        final k = kataKunci.trim().toLowerCase();
        hasil = hasil.where((d) {
          return d.judul.toLowerCase().contains(k) ||
              d.isi.toLowerCase().contains(k);
        }).toList();
      }
      return hasil;
    });
  }

  // section ambil diskusi by id
  Future<DiskusiModel?> getDiskusiById(int id) async {
    if (!_suaraDiskusiLoaded) {
      await getDaftarIdSuaraSaya('diskusi');
    }
    if (_cachedDiskusi != null) {
      for (final d in _cachedDiskusi!) {
        if (d.id == id) {
          return d.copyWith(
            suaraSaya: _cachedIdSuaraSayaDiskusi.contains(id) ? 1 : 0,
          );
        }
      }
    }

    try {
      final snap = await _firestore
          .collection('diskusi')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first.data();
        d['id'] = (d['id'] as num?)?.toInt() ?? id;
        await _isiCacheFoto([d]);
        return DiskusiModel.fromMap(
          d,
          fotoProfil: _ambilFotoProfil(d),
          suaraSaya: _cachedIdSuaraSayaDiskusi.contains(id) ? 1 : 0,
        );
      }
    } catch (_) {}
    return null;
  }

  // section tambah diskusi
  Future<int> tambahDiskusi(DiskusiModel model) async {
    try {
      final docRef = _firestore.collection('diskusi').doc();
      final id = model.id ?? docRef.id.hashCode.abs();
      final doc = model.toMap();
      doc['id'] = id;
      doc['userUid'] = PreferenceHandler.userUid;
      doc['username'] = PreferenceHandler.userUsername;
      doc['penulis'] = PreferenceHandler.userName;

      var foto = PreferenceHandler.user?.fotoProfil ?? '';
      if (foto.isEmpty && PreferenceHandler.userUid.isNotEmpty) {
        foto = _userPhotoCache[PreferenceHandler.userUid] ?? '';
      }
      doc['fotoProfil'] = foto;
      doc['dibuatPada'] = DateTime.now().millisecondsSinceEpoch;
      doc['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(doc);

      final baru = DiskusiModel.fromMap(doc, fotoProfil: foto.isNotEmpty ? foto : null);
      _cachedDiskusi?.insert(0, baru);
      return id;
    } catch (_) {
      return 0;
    }
  }

  // section hapus diskusi
  Future<int> hapusDiskusi(int id) async {
    try {
      final snap = await _firestore
          .collection('diskusi')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      } else {
        await _firestore.collection('diskusi').doc('$id').delete();
      }

      _cachedDiskusi?.removeWhere((d) => d.id == id);
      _cachedJawaban.remove(id);
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // section sinkronkan foto pengguna ke komunitas
  Future<void> sinkronkanFotoPengguna(String userUid, String? fotoUrl) async {
    _userPhotoCache[userUid] = fotoUrl;
    try {
      final batch = _firestore.batch();
      final disDocs = await _firestore
          .collection('diskusi')
          .where('userUid', isEqualTo: userUid)
          .get();
      for (final doc in disDocs.docs) {
        batch.update(doc.reference, {'fotoProfil': fotoUrl ?? ''});
      }

      final jwbDocs = await _firestore
          .collection('jawaban')
          .where('userUid', isEqualTo: userUid)
          .get();
      for (final doc in jwbDocs.docs) {
        batch.update(doc.reference, {'fotoProfil': fotoUrl ?? ''});
      }

      await batch.commit();
      _cachedDiskusi = null;
      _cachedJawaban.clear();
    } catch (_) {}
  }

  // section daftar jawaban
  Future<List<JawabanModel>> getDaftarJawaban(int diskusiId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedJawaban.containsKey(diskusiId)) {
      return _cachedJawaban[diskusiId]!
          .where((j) => j.indukId == null || j.indukId == 0)
          .toList();
    }

    try {
      final votedJawaban = await getDaftarIdSuaraSaya('jawaban');
      final snapshot = await _firestore
          .collection('jawaban')
          .where('diskusiId', isEqualTo: diskusiId)
          .get();

      final balasanCount = <int, int>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final indukId = (d['indukId'] as num?)?.toInt();
        if (indukId != null && indukId > 0) {
          balasanCount[indukId] = (balasanCount[indukId] ?? 0) + 1;
        }
      }

      final maps = snapshot.docs.map((doc) {
        final d = doc.data();
        d['id'] = (d['id'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? doc.id.hashCode.abs();
        return d;
      }).toList();

      await _isiCacheFoto(maps);

      final list = maps.map((d) {
        final jId = d['id'] as int;
        final jumlahBalas = balasanCount[jId] ?? ((d['jumlahBalasan'] as num?)?.toInt() ?? 0);
        return JawabanModel.fromMap(
          d,
          fotoProfil: _ambilFotoProfil(d),
          suaraSaya: votedJawaban.contains(jId) ? 1 : 0,
          jumlahBalasan: jumlahBalas,
        );
      }).toList();

      list.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));
      _cachedJawaban[diskusiId] = list;
      return list.where((j) => j.indukId == null || j.indukId == 0).toList();
    } catch (_) {
      return const [];
    }
  }

  // section daftar balasan
  Future<List<JawabanModel>> getDaftarBalasan(int indukId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      for (final list in _cachedJawaban.values) {
        final balasan = list.where((j) => j.indukId == indukId).toList();
        if (balasan.isNotEmpty) return balasan;
      }
    }

    try {
      final votedJawaban = await getDaftarIdSuaraSaya('jawaban');
      final snapshot = await _firestore
          .collection('jawaban')
          .where('indukId', isEqualTo: indukId)
          .get();

      final list = snapshot.docs.map((doc) {
        final d = doc.data();
        d['id'] = (d['id'] as num?)?.toInt() ?? int.tryParse(doc.id) ?? doc.id.hashCode.abs();
        final jId = d['id'] as int;
        return JawabanModel.fromMap(
          d,
          suaraSaya: votedJawaban.contains(jId) ? 1 : 0,
        );
      }).toList();

      list.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));
      return list;
    } catch (_) {
      return const [];
    }
  }

  // section stream jawaban
  Stream<List<JawabanModel>> streamDaftarJawaban(int diskusiId) {
    if (!_suaraJawabanLoaded) {
      getDaftarIdSuaraSaya('jawaban');
    }
    return _firestore
        .collection('jawaban')
        .where('diskusiId', isEqualTo: diskusiId)
        .snapshots()
        .map((snapshot) {
      final balasanCount = <int, int>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final indukId = (d['indukId'] as num?)?.toInt();
        if (indukId != null && indukId > 0) {
          balasanCount[indukId] = (balasanCount[indukId] ?? 0) + 1;
        }
      }

      final maps = snapshot.docs.map((doc) {
        final d = doc.data();
        final id = (d['id'] as num?)?.toInt() ??
            int.tryParse(doc.id) ??
            doc.id.hashCode.abs();
        d['id'] = id;
        return d;
      }).toList();

      _isiCacheFoto(maps);

      final list = maps.map((d) {
        final id = d['id'] as int;
        final jumlahBalas = balasanCount[id] ?? ((d['jumlahBalasan'] as num?)?.toInt() ?? 0);
        return JawabanModel.fromMap(
          d,
          fotoProfil: _ambilFotoProfil(d),
          suaraSaya: _cachedIdSuaraSayaJawaban.contains(id) ? 1 : 0,
          jumlahBalasan: jumlahBalas,
        );
      }).toList();

      list.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));
      _cachedJawaban[diskusiId] = list;
      return list.where((j) => j.indukId == null || j.indukId == 0).toList();
    });
  }

  // section stream balasan
  Stream<List<JawabanModel>> streamDaftarBalasan(int indukId) {
    if (!_suaraJawabanLoaded) {
      getDaftarIdSuaraSaya('jawaban');
    }
    return _firestore
        .collection('jawaban')
        .where('indukId', isEqualTo: indukId)
        .snapshots()
        .map((snapshot) {
      final maps = snapshot.docs.map((doc) {
        final d = doc.data();
        final id = (d['id'] as num?)?.toInt() ??
            int.tryParse(doc.id) ??
            doc.id.hashCode.abs();
        d['id'] = id;
        return d;
      }).toList();

      _isiCacheFoto(maps);

      final list = maps.map((d) {
        final id = d['id'] as int;
        return JawabanModel.fromMap(
          d,
          fotoProfil: _ambilFotoProfil(d),
          suaraSaya: _cachedIdSuaraSayaJawaban.contains(id) ? 1 : 0,
          jumlahBalasan: (d['jumlahBalasan'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      list.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));
      return list;
    });
  }

  // section ambil jawaban by id
  Future<JawabanModel?> getJawabanById(int id, {bool forceRefresh = false}) async {
    if (!_suaraJawabanLoaded) {
      await getDaftarIdSuaraSaya('jawaban');
    }
    if (!forceRefresh) {
      for (final list in _cachedJawaban.values) {
        for (final j in list) {
          if (j.id == id) {
            return j.copyWith(
              suaraSaya: _cachedIdSuaraSayaJawaban.contains(id) ? 1 : 0,
            );
          }
        }
      }
    }

    try {
      final snap = await _firestore
          .collection('jawaban')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final d = snap.docs.first.data();
        d['id'] = (d['id'] as num?)?.toInt() ?? id;
        await _isiCacheFoto([d]);
        return JawabanModel.fromMap(
          d,
          fotoProfil: _ambilFotoProfil(d),
          suaraSaya: _cachedIdSuaraSayaJawaban.contains(id) ? 1 : 0,
          jumlahBalasan: (d['jumlahBalasan'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (_) {}
    return null;
  }

  // section tambah jawaban
  Future<int> tambahJawaban(JawabanModel model) async {
    try {
      final docRef = _firestore.collection('jawaban').doc();
      final id = model.id ?? docRef.id.hashCode.abs();
      final doc = model.toMap();
      doc['id'] = id;
      doc['userUid'] = PreferenceHandler.userUid;
      doc['username'] = PreferenceHandler.userUsername;
      doc['penulis'] = PreferenceHandler.userName;

      var foto = PreferenceHandler.user?.fotoProfil ?? '';
      if (foto.isEmpty && PreferenceHandler.userUid.isNotEmpty) {
        foto = _userPhotoCache[PreferenceHandler.userUid] ?? '';
      }
      doc['fotoProfil'] = foto;
      doc['dibuatPada'] = DateTime.now().millisecondsSinceEpoch;
      doc['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(doc);

      final baru = JawabanModel.fromMap(doc, fotoProfil: foto.isNotEmpty ? foto : null);
      _cachedJawaban.putIfAbsent(model.diskusiId, () => []).add(baru);

      _firestore.collection('diskusi').doc('${model.diskusiId}').update({
        'jumlahJawaban': FieldValue.increment(1),
      }).catchError((_) {});

      if (model.indukId != null && model.indukId! > 0) {
        _firestore
            .collection('jawaban')
            .where('id', isEqualTo: model.indukId!)
            .limit(1)
            .get()
            .then((snap) {
          if (snap.docs.isNotEmpty) {
            snap.docs.first.reference.update({
              'jumlahBalasan': FieldValue.increment(1),
            });
          }
        }).catchError((_) {});

        for (final list in _cachedJawaban.values) {
          for (var i = 0; i < list.length; i++) {
            if (list[i].id == model.indukId!) {
              list[i] = list[i].copyWith(
                jumlahBalasan: list[i].jumlahBalasan + 1,
              );
              break;
            }
          }
        }
      }

      await _buatNotifikasiTerkait(model, id);

      return id;
    } catch (_) {
      return 0;
    }
  }

  // pemicu notifikasi balasan dan mention
  Future<void> _buatNotifikasiTerkait(
    JawabanModel jawaban,
    int jawabanId,
  ) async {
    try {
      final diskusi = await getDiskusiById(jawaban.diskusiId);
      final judulDiskusi = diskusi?.judul ?? '';
      final diskusiPenulis = diskusi?.penulis ?? '';
      final diskusiUserId = diskusi?.userId ?? 0;

      final senderPenulis = jawaban.penulis;
      final senderUserId = jawaban.userId;
      final kini = DateTime.now().millisecondsSinceEpoch;
      final senderUsername = PreferenceHandler.userUsername.isNotEmpty
          ? PreferenceHandler.userUsername
          : senderPenulis.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

      // notifikasi balasan
      if (jawaban.indukId != null && jawaban.indukId! > 0) {
        final parent = await getJawabanById(jawaban.indukId!);
        if (parent != null) {
          if (parent.penulis.toLowerCase() != senderPenulis.toLowerCase()) {
            await _sisipkanNotifikasi(
              userId: parent.userId,
              targetNama: parent.penulis,
              pengirimId: senderUserId,
              pengirimNama: senderPenulis,
              pengirimUsername: senderUsername,
              tipe: 'balas',
              diskusiId: jawaban.diskusiId,
              jawabanId: jawabanId,
              indukJawabanId: jawaban.indukId,
              judulDiskusi: judulDiskusi,
              cuplikanTeks: jawaban.isi,
              dibuatPada: kini,
            );
          }
        }
      } else if (diskusiPenulis.isNotEmpty &&
          diskusiPenulis.toLowerCase() != senderPenulis.toLowerCase()) {
        await _sisipkanNotifikasi(
          userId: diskusiUserId,
          targetNama: diskusiPenulis,
          pengirimId: senderUserId,
          pengirimNama: senderPenulis,
          pengirimUsername: senderUsername,
          tipe: 'balas',
          diskusiId: jawaban.diskusiId,
          jawabanId: jawabanId,
          indukJawabanId: null,
          judulDiskusi: judulDiskusi,
          cuplikanTeks: jawaban.isi,
          dibuatPada: kini,
        );
      }
    } catch (_) {}
  }

  Future<void> _sisipkanNotifikasi({
    required int userId,
    required String targetNama,
    String? targetUsername,
    int? pengirimId,
    required String pengirimNama,
    required String pengirimUsername,
    required String tipe,
    required int diskusiId,
    int? jawabanId,
    int? indukJawabanId,
    required String judulDiskusi,
    required String cuplikanTeks,
    required int dibuatPada,
  }) async {
    final tUsername = targetUsername ??
        targetNama.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    try {
      final ref = _firestore.collection('notifikasi_komunitas').doc();
      final id = ref.id.hashCode.abs();
      await ref.set({
        'id': id,
        'userId': userId,
        'userNama': targetNama,
        'userUsername': tUsername,
        'pengirimId': pengirimId,
        'pengirimNama': pengirimNama,
        'pengirimUsername': pengirimUsername,
        'tipe': tipe,
        'diskusiId': diskusiId,
        'jawabanId': jawabanId,
        'indukJawabanId': indukJawabanId,
        'judulDiskusi': judulDiskusi,
        'cuplikanTeks': cuplikanTeks,
        'sudahDibaca': 0,
        'dibuatPada': dibuatPada,
      });
    } catch (_) {}
  }

  // cek waktu diskusi terakhir
  Future<DateTime?> getWaktuDiskusiTerakhir(int userId) async {
    if (_cachedDiskusi != null) {
      for (final d in _cachedDiskusi!) {
        if (d.userId == userId) {
          return d.dibuatPada;
        }
      }
    }
    return null;
  }

  // hapus jawaban dan anak balasannya
  Future<int> hapusJawaban(int id) async {
    try {
      final snap = await _firestore
          .collection('jawaban')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      } else {
        await _firestore.collection('jawaban').doc('$id').delete();
      }

      for (final key in _cachedJawaban.keys) {
        _cachedJawaban[key]?.removeWhere((j) => j.id == id || j.indukId == id);
      }
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // cek jawaban terakhir user
  Future<JawabanModel?> getJawabanTerakhirUser(int userId, int diskusiId) async {
    final list = _cachedJawaban[diskusiId];
    if (list != null) {
      for (final j in list.reversed) {
        if (j.userId == userId) return j;
      }
    }
    return null;
  }

  // section toggle suara
  Future<bool> toggleSuara(String targetTipe, int targetId) async {
    final uid = _userUid;
    if (uid == 'guest') return false;

    final docId = '${targetTipe}_${targetId}_$uid';
    final ref = _firestore.collection('suara').doc(docId);
    final collectionName = targetTipe == 'diskusi' ? 'diskusi' : 'jawaban';

    try {
      final snap = await ref.get();
      if (snap.exists) {
        await ref.delete();
        if (targetTipe == 'diskusi') {
          _cachedIdSuaraSayaDiskusi.remove(targetId);
        } else {
          _cachedIdSuaraSayaJawaban.remove(targetId);
        }
        _updateJumlahSuara(collectionName, targetId, -1);
        _updateLocalSuaraCache(targetTipe, targetId, delta: -1, hasVoted: false);
        return false;
      } else {
        await ref.set({
          'targetTipe': targetTipe,
          'targetId': targetId,
          'userId': _pemilik,
          'userUid': uid,
          'nilai': 1,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (targetTipe == 'diskusi') {
          _cachedIdSuaraSayaDiskusi.add(targetId);
        } else {
          _cachedIdSuaraSayaJawaban.add(targetId);
        }
        _updateJumlahSuara(collectionName, targetId, 1);
        _updateLocalSuaraCache(targetTipe, targetId, delta: 1, hasVoted: true);
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  // section update jumlah suara
  void _updateJumlahSuara(String collection, int id, int delta) {
    _firestore
        .collection(collection)
        .where('id', isEqualTo: id)
        .limit(1)
        .get()
        .then((snap) {
      if (snap.docs.isNotEmpty) {
        snap.docs.first.reference.update({
          'jumlahSuara': FieldValue.increment(delta),
        });
      } else {
        _firestore.collection(collection).doc('$id').update({
          'jumlahSuara': FieldValue.increment(delta),
        }).catchError((_) {});
      }
    }).catchError((_) {});
  }

  // section update cache suara
  void _updateLocalSuaraCache(
    String targetTipe,
    int targetId, {
    required int delta,
    required bool hasVoted,
  }) {
    if (targetTipe == 'diskusi') {
      if (_cachedDiskusi != null) {
        for (var i = 0; i < _cachedDiskusi!.length; i++) {
          if (_cachedDiskusi![i].id == targetId) {
            final lama = _cachedDiskusi![i];
            _cachedDiskusi![i] = lama.copyWith(
              jumlahSuara: (lama.jumlahSuara + delta).clamp(0, 999999),
              suaraSaya: hasVoted ? 1 : 0,
            );
            break;
          }
        }
      }
    } else {
      for (final key in _cachedJawaban.keys) {
        final list = _cachedJawaban[key];
        if (list != null) {
          for (var i = 0; i < list.length; i++) {
            if (list[i].id == targetId) {
              final lama = list[i];
              list[i] = lama.copyWith(
                jumlahSuara: (lama.jumlahSuara + delta).clamp(0, 999999),
                suaraSaya: hasVoted ? 1 : 0,
              );
              break;
            }
          }
        }
      }
    }
  }

  // section diskusi pengguna
  Future<List<DiskusiModel>> getDiskusiByUserId(
    int userId, {
    String? username,
    int limit = 8,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('diskusi');
      if (userId > 0) {
        query = query.where('userId', isEqualTo: userId);
      } else if (username != null && username.isNotEmpty) {
        query = query.where('username', isEqualTo: username);
      }
      final snap = await query.limit(limit).get();
      final list = snap.docs.map((doc) {
        final d = doc.data();
        d['id'] = (d['id'] as num?)?.toInt() ??
            int.tryParse(doc.id) ??
            doc.id.hashCode.abs();
        return DiskusiModel.fromMap(d);
      }).toList();

      list.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));
      return list;
    } catch (_) {
      return const [];
    }
  }

  // cari pengguna untuk mention
  Future<List<Map<String, String>>> cariPenggunaTag({
    String kataKunci = '',
    List<String> namaPrioritas = const [],
  }) async {
    final hasil = <Map<String, String>>[];
    final usernamesTerdaftar = <String>{};

    for (final nama in namaPrioritas) {
      final n = nama.trim();
      final uSlug = n.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      if (uSlug.isNotEmpty && !usernamesTerdaftar.contains(uSlug)) {
        if (kataKunci.isEmpty ||
            uSlug.contains(kataKunci.toLowerCase()) ||
            n.toLowerCase().contains(kataKunci.toLowerCase())) {
          usernamesTerdaftar.add(uSlug);
          hasil.add({
            'nama': n,
            'username': uSlug,
            'role': isAdminAccountName(n) || isAdminAccountName(uSlug)
                ? 'admin'
                : 'user',
          });
        }
      }
    }

    if (_cachedDiskusi != null) {
      for (final d in _cachedDiskusi!) {
        final n = d.penulis.trim();
        final uSlug = n.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
        if (uSlug.isNotEmpty && !usernamesTerdaftar.contains(uSlug)) {
          if (kataKunci.isEmpty ||
              uSlug.contains(kataKunci.toLowerCase()) ||
              n.toLowerCase().contains(kataKunci.toLowerCase())) {
            usernamesTerdaftar.add(uSlug);
            hasil.add({
              'nama': n,
              'username': uSlug,
              'role': isAdminAccountName(n) ? 'admin' : 'user',
            });
          }
        }
      }
    }

    return hasil;
  }

  // ambil seluruh daftar nama dan username pengguna untuk regex mention
  Future<List<String>> getSemuaNamaPengguna() async {
    final hasil = <String>{};
    if (_cachedDiskusi != null) {
      for (final d in _cachedDiskusi!) {
        hasil.add(d.penulis.trim());
      }
    }
    return hasil.toList();
  }

  // ambil daftar notifikasi komunitas
  Future<List<NotifikasiKomunitasModel>> getDaftarNotifikasi({
    required String targetIdentifier,
    int? targetUserId,
    String? filterTipe,
    bool hanyaBelumDibaca = false,
  }) async {
    final tLower = targetIdentifier.trim().toLowerCase();
    List<NotifikasiKomunitasModel> sumber;

    if (_cachedNotifikasi != null) {
      sumber = _cachedNotifikasi!;
    } else {
      try {
        final snapshot = await _firestore
            .collection('notifikasi_komunitas')
            .orderBy('dibuatPada', descending: true)
            .limit(100)
            .get();

        sumber = snapshot.docs.map((doc) {
          final d = doc.data();
          d['id'] = (d['id'] as num?)?.toInt() ??
              int.tryParse(doc.id) ??
              doc.id.hashCode.abs();
          return NotifikasiKomunitasModel.fromMap(d);
        }).toList();

        _cachedNotifikasi = sumber;
      } catch (_) {
        sumber = _cachedNotifikasi ?? const [];
      }
    }

    var list = sumber.where((n) {
      if (targetUserId != null &&
          targetUserId > 0 &&
          n.userId == targetUserId) {
        return true;
      }
      return n.userUsername.toLowerCase() == tLower ||
          n.userNama.toLowerCase() == tLower;
    }).toList();

    if (filterTipe != null &&
        filterTipe.isNotEmpty &&
        filterTipe.toLowerCase() != 'semua') {
      list = list
          .where((n) => n.tipe.toLowerCase() == filterTipe.toLowerCase())
          .toList();
    }
    if (hanyaBelumDibaca) {
      list = list.where((n) => !n.sudahDibaca).toList();
    }
    return list;
  }

  // stream realtime daftar notifikasi komunitas
  Stream<List<NotifikasiKomunitasModel>> streamDaftarNotifikasi({
    required String targetIdentifier,
    int? targetUserId,
    String? filterTipe,
    bool hanyaBelumDibaca = false,
  }) {
    final tLower = targetIdentifier.trim().toLowerCase();
    return _firestore
        .collection('notifikasi_komunitas')
        .orderBy('dibuatPada', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final sumber = snapshot.docs.map((doc) {
        final d = doc.data();
        d['id'] = (d['id'] as num?)?.toInt() ??
            int.tryParse(doc.id) ??
            doc.id.hashCode.abs();
        return NotifikasiKomunitasModel.fromMap(d);
      }).toList();

      _cachedNotifikasi = sumber;

      var list = sumber.where((n) {
        if (targetUserId != null &&
            targetUserId > 0 &&
            n.userId == targetUserId) {
          return true;
        }
        return n.userUsername.toLowerCase() == tLower ||
            n.userNama.toLowerCase() == tLower;
      }).toList();

      if (filterTipe != null &&
          filterTipe.isNotEmpty &&
          filterTipe.toLowerCase() != 'semua') {
        list = list
            .where((n) => n.tipe.toLowerCase() == filterTipe.toLowerCase())
            .toList();
      }
      if (hanyaBelumDibaca) {
        list = list.where((n) => !n.sudahDibaca).toList();
      }
      return list;
    });
  }

  // hitung jumlah notifikasi belum dibaca
  Future<int> getJumlahNotifikasiBelumDibaca({
    required String targetIdentifier,
    int? targetUserId,
  }) async {
    final list = await getDaftarNotifikasi(
      targetIdentifier: targetIdentifier,
      targetUserId: targetUserId,
      hanyaBelumDibaca: true,
    );
    return list.length;
  }

  // stream realtime jumlah notifikasi belum dibaca
  Stream<int> streamJumlahNotifikasiBelumDibaca({
    required String targetIdentifier,
    int? targetUserId,
  }) {
    return _firestore
        .collection('notifikasi_komunitas')
        .where('sudahDibaca', isEqualTo: 0)
        .snapshots()
        .map((snapshot) {
      final tLower = targetIdentifier.trim().toLowerCase();
      var count = 0;
      for (final doc in snapshot.docs) {
        final d = doc.data();
        final uId = (d['userId'] as num?)?.toInt();
        final uUser = (d['userUsername'] as String? ?? '').toLowerCase();
        final uNama = (d['userNama'] as String? ?? '').toLowerCase();
        if ((targetUserId != null && targetUserId > 0 && uId == targetUserId) ||
            uUser == tLower ||
            uNama == tLower) {
          count++;
        }
      }
      return count;
    });
  }

  // tandai satu notifikasi telah dibaca
  Future<void> tandaiNotifikasiDibaca(int id) async {
    if (_cachedNotifikasi != null) {
      for (var i = 0; i < _cachedNotifikasi!.length; i++) {
        if (_cachedNotifikasi![i].id == id) {
          _cachedNotifikasi![i] =
              _cachedNotifikasi![i].copyWith(sudahDibaca: true);
        }
      }
    }

    try {
      final snap = await _firestore
          .collection('notifikasi_komunitas')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.update({'sudahDibaca': 1});
      }
    } catch (_) {}
  }

  // tandai semua notifikasi telah dibaca
  Future<void> tandaiSemuaNotifikasiDibaca({
    required String targetIdentifier,
    int? targetUserId,
  }) async {
    final tLower = targetIdentifier.trim().toLowerCase();
    if (_cachedNotifikasi != null) {
      _cachedNotifikasi = _cachedNotifikasi!.map((n) {
        final matches = (targetUserId != null &&
                targetUserId > 0 &&
                n.userId == targetUserId) ||
            n.userUsername.toLowerCase() == tLower ||
            n.userNama.toLowerCase() == tLower;
        return matches ? n.copyWith(sudahDibaca: true) : n;
      }).toList();
    }

    try {
      final snap = await _firestore
          .collection('notifikasi_komunitas')
          .where('sudahDibaca', isEqualTo: 0)
          .get();

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        final d = doc.data();
        final uId = (d['userId'] as num?)?.toInt();
        final uUser = (d['userUsername'] as String? ?? '').toLowerCase();
        final uNama = (d['userNama'] as String? ?? '').toLowerCase();
        if ((targetUserId != null && targetUserId > 0 && uId == targetUserId) ||
            uUser == tLower ||
            uNama == tLower) {
          batch.update(doc.reference, {'sudahDibaca': 1});
        }
      }
      await batch.commit();
    } catch (_) {}
  }

  // hapus notifikasi
  Future<void> hapusNotifikasi(int id) async {
    _cachedNotifikasi?.removeWhere((n) => n.id == id);

    try {
      final snap = await _firestore
          .collection('notifikasi_komunitas')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        await snap.docs.first.reference.delete();
      }
    } catch (_) {}
  }

  // bersihkan cache
  static void bersihkanCache() {
    _cachedDiskusi = null;
    _cachedJawaban.clear();
    _cachedNotifikasi = null;
  }
}

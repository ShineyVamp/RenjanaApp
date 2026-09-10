import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/firebase_auth_service.dart';
import '../../../../core/storage/preference_handler.dart';
import '../models/user_model.dart';

// status sunting
class HasilSuntingProfil {
  final UserSQLModel? user;
  final String? galat;

  const HasilSuntingProfil.berhasil(this.user) : galat = null;
  const HasilSuntingProfil.gagal(this.galat) : user = null;

  bool get sukses => user != null;
}

class UserRepository {
  final FirebaseAuthService _authService;
  final CloudinaryService _cloudinaryService;
  final FirebaseFirestore _firestore;

  // inisialisasi
  UserRepository({
    FirebaseAuthService? authService,
    CloudinaryService? cloudinaryService,
    FirebaseFirestore? firestore,
  })  : _authService = authService ?? FirebaseAuthService(),
        _cloudinaryService = cloudinaryService ?? CloudinaryService(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  // registrasi
  Future<bool> userRegister(UserSQLModel user) async {
    try {
      final res = await _authService.register(
        nama: user.nama,
        username: user.username,
        email: user.email,
        password: user.password,
        role: user.role,
      );
      return res.uid != null;
    } on FirebaseAuthException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  // login
  Future<UserSQLModel?> loginUser(String identifier, String password) async {
    try {
      return await _authService.login(
        identifier: identifier,
        password: password,
      );
    } catch (_) {
      return null;
    }
  }

  // ambil user
  Future<UserSQLModel?> getUserByEmail(String email) async {
    return await _authService.getUserByEmail(email);
  }

  Future<UserSQLModel?> getUserByUid(String uid) async {
    return await _authService.getUserProfile(uid);
  }

  Future<UserSQLModel?> getUserById(int id) async {
    final uid = PreferenceHandler.userUid;
    if (uid.isNotEmpty) {
      final user = await getUserByUid(uid);
      if (user != null) return user;
    }

    try {
      final snapshot = await _usersCol.where('id', isEqualTo: id).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return UserSQLModel.fromFirestore(doc.data(), docId: doc.id);
      }
    } catch (_) {}

    return null;
  }

  // validasi
  Future<bool> usernameDipakai(String username, {int? kecualiId}) async {
    return await _authService.isUsernameTaken(username);
  }

  Future<bool> emailDipakai(String email, {int? kecualiId}) async {
    return await _authService.isEmailTaken(email);
  }

  // foto profil
  Future<int> perbaruiFotoProfil(String email, String? path) async {
    try {
      final query = await _usersCol.where('email', isEqualTo: email.trim()).limit(1).get();
      if (query.docs.isEmpty) return 0;
      final docId = query.docs.first.id;

      String? finalUrl = path;
      if (path != null && !path.startsWith('http')) {
        final file = File(path);
        if (file.existsSync()) {
          final res = await _cloudinaryService.uploadImage(file, subFolder: 'profiles');
          if (res.isSuccess && res.secureUrl != null) {
            finalUrl = res.secureUrl;
          }
        }
      }

      await _usersCol.doc(docId).update({
        'fotoProfil': finalUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return 1;
    } catch (_) {
      return 0;
    }
  }

  // sunting profil
  Future<HasilSuntingProfil> perbaruiProfil({
    required int id,
    required String nama,
    required String username,
    required String email,
    String? fotoProfil,
    bool hapusFoto = false,
  }) async {
    final namaBersih = nama.trim();
    final usernameBersih = username.trim().toLowerCase();
    final emailBersih = email.trim();

    if (namaBersih.isEmpty) {
      return const HasilSuntingProfil.gagal('Nama tidak boleh kosong.');
    }
    if (usernameBersih.isEmpty) {
      return const HasilSuntingProfil.gagal('Username tidak boleh kosong.');
    }
    if (usernameBersih.contains(' ')) {
      return const HasilSuntingProfil.gagal('Username tidak boleh mengandung spasi.');
    }
    if (emailBersih.isEmpty) {
      return const HasilSuntingProfil.gagal('Email tidak boleh kosong.');
    }

    final userUid = PreferenceHandler.userUid;
    if (userUid.isEmpty) {
      return const HasilSuntingProfil.gagal('Sesi tidak ditemukan.');
    }

    if (await _authService.isUsernameTaken(usernameBersih, kecualiUid: userUid)) {
      return const HasilSuntingProfil.gagal('Username itu sudah dipakai akun lain.');
    }
    if (await _authService.isEmailTaken(emailBersih, kecualiUid: userUid)) {
      return const HasilSuntingProfil.gagal('Email itu sudah terdaftar pada akun lain.');
    }

    String? fotoFinal = fotoProfil;

    // upload cloudinary
    if (!hapusFoto && fotoProfil != null && !fotoProfil.startsWith('http')) {
      final file = File(fotoProfil);
      if (file.existsSync()) {
        final uploadRes = await _cloudinaryService.uploadImage(
          file,
          subFolder: 'profiles',
        );
        if (uploadRes.isSuccess && uploadRes.secureUrl != null) {
          fotoFinal = uploadRes.secureUrl;
        }
      }
    }

    // update firestore
    final updateData = <String, dynamic>{
      'nama': namaBersih,
      'username': usernameBersih,
      'email': emailBersih,
      if (hapusFoto) 'fotoProfil': null,
      if (!hapusFoto && fotoFinal != null) 'fotoProfil': fotoFinal,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final sukses = await _authService.updateProfile(
      uid: userUid,
      data: updateData,
    );

    if (!sukses) {
      return const HasilSuntingProfil.gagal('Gagal menyimpan ke cloud.');
    }

    final terbaru = await getUserByUid(userUid);
    if (terbaru != null) {
      return HasilSuntingProfil.berhasil(terbaru);
    }

    return const HasilSuntingProfil.gagal('Gagal memuat profil terbaru.');
  }

  // admin
  Future<bool> ubahRoleUser({required String uid, required String role}) async {
    return await _authService.setRole(uid, role);
  }

  Future<void> inisialisasiAdminBawaan() async {
    await _authService.seedAdminAccounts();
  }
}

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
  final bool butuhReautentikasi;

  const HasilSuntingProfil.berhasil(this.user)
      : galat = null,
        butuhReautentikasi = false;
  const HasilSuntingProfil.gagal(this.galat)
      : user = null,
        butuhReautentikasi = false;
  const HasilSuntingProfil.butuhReauth(this.galat)
      : user = null,
        butuhReautentikasi = true;

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

  // ambil user
  Future<UserSQLModel?> getUserById(int id) async {
    if (id == PreferenceHandler.userId && PreferenceHandler.userUid.isNotEmpty) {
      final user = await getUserByUid(PreferenceHandler.userUid);
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

  // ambil user by username
  Future<UserSQLModel?> getUserByUsername(String username) async {
    try {
      final snapshot = await _usersCol
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(1)
          .get();
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
      final oldFoto = query.docs.first.data()['fotoProfil'] as String?;

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

      if (oldFoto != null && oldFoto.isNotEmpty && oldFoto != finalUrl) {
        await _cloudinaryService.deleteImageByUrl(oldFoto);
      }

      await _usersCol.doc(docId).update({
        'fotoProfil': finalUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _sinkronkanFotoKeKomunitas(docId, finalUrl);
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
    String? passwordKonfirmasi,
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

    final currentUser = await getUserByUid(userUid);

    // sinkronisasi email ke firebase auth jika email berubah
    if (currentUser != null &&
        emailBersih.toLowerCase() != currentUser.email.toLowerCase()) {
      final resEmail = await _authService.updateAuthEmail(
        emailBersih,
        passwordKonfirmasi: passwordKonfirmasi,
      );
      if (resEmail.butuhReauth) {
        return HasilSuntingProfil.butuhReauth(resEmail.galat);
      }
      if (!resEmail.sukses) {
        return HasilSuntingProfil.gagal(
          resEmail.galat ?? 'Gagal memperbarui email autentikasi.',
        );
      }
    }

    final oldFoto = currentUser?.fotoProfil;

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

    // hapus foto lama dari cloudinary bila diganti atau dihapus
    if (hapusFoto && oldFoto != null && oldFoto.isNotEmpty) {
      await _cloudinaryService.deleteImageByUrl(oldFoto);
    } else if (!hapusFoto && fotoFinal != null && fotoFinal != oldFoto && oldFoto != null && oldFoto.isNotEmpty) {
      await _cloudinaryService.deleteImageByUrl(oldFoto);
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

    final targetFoto = hapusFoto ? null : (fotoFinal ?? oldFoto);
    await _sinkronkanFotoKeKomunitas(userUid, targetFoto);

    final terbaru = await getUserByUid(userUid);
    if (terbaru != null) {
      return HasilSuntingProfil.berhasil(terbaru);
    }

    return const HasilSuntingProfil.gagal('Gagal memuat profil terbaru.');
  }

  // section sinkronisasi foto ke komunitas
  Future<void> _sinkronkanFotoKeKomunitas(String userUid, String? fotoUrl) async {
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
    } catch (_) {}
  }

  // admin
  Future<bool> ubahRoleUser({required String uid, required String role}) async {
    return await _authService.setRole(uid, role);
  }

  Future<void> inisialisasiAdminBawaan() async {
    await _authService.seedAdminAccounts();
  }

  // reset password
  Future<({bool sukses, String pesan})> kirimResetPassword(
    String identifier,
  ) async {
    final bersih = identifier.trim();
    if (bersih.isEmpty) {
      return (sukses: false, pesan: 'Email atau username tidak boleh kosong.');
    }

    try {
      final emailTujuan = await _authService.resolveEmailFromIdentifier(bersih);
      if (emailTujuan == null || emailTujuan.isEmpty) {
        return (
          sukses: false,
          pesan: 'Akun dengan username atau email tersebut tidak ditemukan.',
        );
      }

      await _authService.sendPasswordResetEmail(emailTujuan);
      return (
        sukses: true,
        pesan:
            'Tautan pemulihan kata sandi telah dikirim ke $emailTujuan. Silakan periksa kotak masuk atau folder spam Anda.',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return (
          sukses: false,
          pesan: 'Pengguna dengan email tersebut tidak ditemukan.',
        );
      }
      if (e.code == 'invalid-email') {
        return (sukses: false, pesan: 'Format email tidak valid.');
      }
      return (
        sukses: false,
        pesan: e.message ?? 'Gagal mengirim email pemulihan.',
      );
    } catch (e) {
      return (sukses: false, pesan: 'Terjadi kesalahan: $e');
    }
  }

  // ganti password dengan password lama
  Future<({bool sukses, String pesan})> gantiPassword({
    required String passwordLama,
    required String passwordBaru,
  }) async {
    final lama = passwordLama.trim();
    final baru = passwordBaru.trim();

    if (lama.isEmpty) {
      return (sukses: false, pesan: 'Password lama tidak boleh kosong.');
    }
    if (baru.isEmpty) {
      return (sukses: false, pesan: 'Password baru tidak boleh kosong.');
    }
    if (baru.length < 8) {
      return (sukses: false, pesan: 'Password baru minimal 8 karakter.');
    }
    if (lama == baru) {
      return (
        sukses: false,
        pesan: 'Password baru tidak boleh sama dengan password lama.',
      );
    }

    try {
      await _authService.changePassword(
        currentPassword: lama,
        newPassword: baru,
      );
      return (sukses: true, pesan: 'Password berhasil diperbarui.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return (sukses: false, pesan: 'Password lama tidak sesuai.');
      }
      if (e.code == 'weak-password') {
        return (
          sukses: false,
          pesan: 'Password baru terlalu lemah. Gunakan minimal 8 karakter.',
        );
      }
      if (e.code == 'requires-recent-login') {
        return (
          sukses: false,
          pesan: 'Sesi Anda telah kedaluwarsa. Silakan logout dan login kembali.',
        );
      }
      return (sukses: false, pesan: e.message ?? 'Gagal mengubah password.');
    } catch (e) {
      return (sukses: false, pesan: 'Terjadi kesalahan: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/models/user_model.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  // inisialisasi
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');

  // registrasi
  Future<UserSQLModel> register({
    required String nama,
    required String username,
    required String email,
    required String password,
    String? role,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Gagal membuat akun.',
      );
    }

    final effectiveRole = role ??
        (isAdminAccountName(nama) || isAdminAccountName(username)
            ? 'admin'
            : 'user');

    final userData = {
      'uid': firebaseUser.uid,
      'nama': nama.trim(),
      'username': username.trim().toLowerCase(),
      'email': email.trim(),
      'role': effectiveRole,
      'fotoProfil': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _usersCol.doc(firebaseUser.uid).set(userData);

    return UserSQLModel.fromFirestore(
      userData,
      docId: firebaseUser.uid,
    );
  }

  // login
  Future<UserSQLModel?> login({
    required String identifier,
    required String password,
  }) async {
    String emailToUse = identifier.trim();

    if (!emailToUse.contains('@')) {
      final usernameLower = emailToUse.toLowerCase();
      final querySnapshot = await _usersCol
          .where('username', isEqualTo: usernameLower)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final docData = querySnapshot.docs.first.data();
      emailToUse = docData['email'] as String? ?? '';
      if (emailToUse.isEmpty) return null;
    }

    final credential = await _auth.signInWithEmailAndPassword(
      email: emailToUse,
      password: password.trim(),
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) return null;

    final docSnap = await _usersCol.doc(firebaseUser.uid).get();
    if (docSnap.exists && docSnap.data() != null) {
      return UserSQLModel.fromFirestore(
        docSnap.data()!,
        docId: firebaseUser.uid,
      );
    }

    final fallbackUser = UserSQLModel(
      uid: firebaseUser.uid,
      nama: firebaseUser.displayName ?? identifier,
      username: identifier.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
      email: firebaseUser.email ?? emailToUse,
      password: '',
      role: 'user',
    );
    await _usersCol.doc(firebaseUser.uid).set({
      'uid': firebaseUser.uid,
      'nama': fallbackUser.nama,
      'username': fallbackUser.username,
      'email': fallbackUser.email,
      'role': fallbackUser.role,
      'fotoProfil': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return fallbackUser;
  }

  // profil
  Future<UserSQLModel?> getUserProfile(String uid) async {
    try {
      final docSnap = await _usersCol.doc(uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        return UserSQLModel.fromFirestore(docSnap.data()!, docId: uid);
      }
    } catch (_) {}
    return null;
  }

  Future<UserSQLModel?> getUserByEmail(String email) async {
    try {
      final query = await _usersCol
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        return UserSQLModel.fromFirestore(doc.data(), docId: doc.id);
      }
    } catch (_) {}
    return null;
  }

  Future<bool> updateProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(uid).update(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  // validasi
  Future<bool> isUsernameTaken(String username, {String? kecualiUid}) async {
    try {
      final query = await _usersCol
          .where('username', isEqualTo: username.trim().toLowerCase())
          .limit(2)
          .get();

      if (query.docs.isEmpty) return false;
      if (kecualiUid != null) {
        return query.docs.any((doc) => doc.id != kecualiUid);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEmailTaken(String email, {String? kecualiUid}) async {
    try {
      final query = await _usersCol
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(2)
          .get();

      if (query.docs.isEmpty) return false;
      if (kecualiUid != null) {
        return query.docs.any((doc) => doc.id != kecualiUid);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  // admin
  Future<bool> setRole(String uid, String role) async {
    try {
      await _usersCol.doc(uid).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> seedAdminAccounts() async {
    final admins = [
      {
        'email': 'admin1@renjana.com',
        'password': 'Admin123!',
        'nama': 'Admin Renjana 1',
        'username': 'admin1',
      },
      {
        'email': 'admin2@renjana.com',
        'password': 'Admin123!',
        'nama': 'Admin Renjana 2',
        'username': 'admin2',
      },
    ];

    for (final adm in admins) {
      try {
        final existing = await _usersCol
            .where('email', isEqualTo: adm['email'])
            .limit(1)
            .get();

        if (existing.docs.isEmpty) {
          final cred = await _auth.createUserWithEmailAndPassword(
            email: adm['email']!,
            password: adm['password']!,
          );
          if (cred.user != null) {
            await _usersCol.doc(cred.user!.uid).set({
              'uid': cred.user!.uid,
              'nama': adm['nama'],
              'username': adm['username'],
              'email': adm['email'],
              'role': 'admin',
              'fotoProfil': null,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      } catch (_) {}
    }
  }

  // logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
  }
}

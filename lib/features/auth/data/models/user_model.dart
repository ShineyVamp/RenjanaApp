import 'dart:convert';

// akun admin
const Set<String> adminAccountNames = {'admin1', 'admin2'};

bool isAdminAccountName(String identifier) =>
    adminAccountNames.contains(identifier.toLowerCase().trim());

// model user
class UserSQLModel {
  final int? id;
  final String? uid;
  final String nama;
  final String username;
  final String email;
  final String password;
  final String? fotoProfil;
  final String role;

  UserSQLModel({
    this.id,
    this.uid,
    required this.nama,
    required this.username,
    required this.email,
    required this.password,
    this.fotoProfil,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) 'id': id,
      'nama': nama,
      'username': username,
      'email': email,
      'password': password,
      'fotoProfil': fotoProfil,
      'role': role,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'uid': uid,
      'nama': nama,
      'username': username,
      'email': email,
      'fotoProfil': fotoProfil,
      'role': role,
    };
  }

  UserSQLModel copyWith({
    int? id,
    String? uid,
    String? nama,
    String? username,
    String? email,
    String? password,
    String? fotoProfil,
    String? role,
    bool hapusFoto = false,
  }) {
    return UserSQLModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      fotoProfil: hapusFoto ? null : (fotoProfil ?? this.fotoProfil),
      role: role ?? this.role,
    );
  }

  // inisial nama
  String get inisial {
    final bersih = nama.trim();
    if (bersih.isNotEmpty) return bersih[0].toUpperCase();
    final u = username.trim();
    return u.isNotEmpty ? u[0].toUpperCase() : '?';
  }

  // sanitasi password
  UserSQLModel sanitized() => copyWith(password: '');

  // cek admin
  bool get isAdmin =>
      role == 'admin' ||
      isAdminAccountName(nama) ||
      isAdminAccountName(username);
  bool get isAdminAccount => isAdmin;

  factory UserSQLModel.fromMap(Map<String, dynamic> map) {
    final namaVal = map['nama'] as String? ?? '';
    final rawUsername = map['username'] as String?;
    final usernameVal = (rawUsername != null && rawUsername.trim().isNotEmpty)
        ? rawUsername.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')
        : namaVal.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    return UserSQLModel(
      id: map['id'] != null ? map['id'] as int : null,
      uid: map['uid'] as String?,
      nama: namaVal,
      username: usernameVal,
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
      fotoProfil: map['fotoProfil'] as String?,
      role: map['role'] as String? ??
          (isAdminAccountName(namaVal) || isAdminAccountName(usernameVal)
              ? 'admin'
              : 'user'),
    );
  }

  factory UserSQLModel.fromFirestore(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    final namaVal = map['nama'] as String? ?? '';
    final rawUsername = map['username'] as String?;
    final usernameVal = (rawUsername != null && rawUsername.trim().isNotEmpty)
        ? rawUsername.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')
        : namaVal.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    final effectiveUid = docId ?? map['uid'] as String?;
    final derivedId = map['id'] != null
        ? (map['id'] as num).toInt()
        : (effectiveUid != null && effectiveUid.isNotEmpty
            ? effectiveUid.hashCode.abs()
            : null);

    return UserSQLModel(
      id: derivedId,
      uid: effectiveUid,
      nama: namaVal,
      username: usernameVal,
      email: map['email'] as String? ?? '',
      password: '',
      fotoProfil: map['fotoProfil'] as String?,
      role: map['role'] as String? ??
          (isAdminAccountName(namaVal) || isAdminAccountName(usernameVal)
              ? 'admin'
              : 'user'),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSQLModel.fromJson(String source) =>
      UserSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}


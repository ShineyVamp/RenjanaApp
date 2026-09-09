import 'dart:convert';

// akun admin
const Set<String> adminAccountNames = {'admin1', 'admin2'};

bool isAdminAccountName(String identifier) =>
    adminAccountNames.contains(identifier.toLowerCase().trim());

// model user
class UserSQLModel {
  final int? id;
  final String nama;
  final String username;
  final String email;
  final String password;
  final String? fotoProfil;
  final String role;

  UserSQLModel({
    this.id,
    required this.nama,
    required this.username,
    required this.email,
    required this.password,
    this.fotoProfil,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nama': nama,
      'username': username,
      'email': email,
      'password': password,
      'fotoProfil': fotoProfil,
      'role': role,
    };
  }

  UserSQLModel copyWith({
    int? id,
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

  String toJson() => json.encode(toMap());

  factory UserSQLModel.fromJson(String source) =>
      UserSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}


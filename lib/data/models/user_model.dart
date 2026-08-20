import 'dart:convert';

// Nama akun yang diberi hak admin.
const Set<String> adminAccountNames = {'admin1', 'admin2'};

// Pengecekan hak admin, dipakai PreferenceHandler dan MainPage.
bool isAdminAccountName(String nama) =>
    adminAccountNames.contains(nama.toLowerCase().trim());

class UserSQLModel {
  final int? id;
  final String nama;
  final String email;
  final String noHp;
  final String password;

  UserSQLModel({
    this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nama': nama,
      'email': email,
      'noHp': noHp,
      'password': password,
    };
  }

  UserSQLModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? noHp,
    String? password,
  }) {
    return UserSQLModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      password: password ?? this.password,
    );
  }

  // Salinan tanpa password, dipakai saat menyimpan sesi.
  UserSQLModel sanitized() => copyWith(password: '');

  bool get isAdminAccount => isAdminAccountName(nama);

  factory UserSQLModel.fromMap(Map<String, dynamic> map) {
    return UserSQLModel(
      id: map['id'] != null ? map['id'] as int : null,
      nama: map['nama'] as String? ?? '',
      email: map['email'] as String? ?? '',
      noHp: map['noHp'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSQLModel.fromJson(String source) =>
      UserSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

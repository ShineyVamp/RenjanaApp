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

  // Path foto profil di penyimpanan perangkat. Null berarti memakai
  // placeholder huruf depan nama.
  final String? fotoProfil;

  UserSQLModel({
    this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.password,
    this.fotoProfil,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nama': nama,
      'email': email,
      'noHp': noHp,
      'password': password,
      'fotoProfil': fotoProfil,
    };
  }

  UserSQLModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? noHp,
    String? password,
    String? fotoProfil,
    bool hapusFoto = false,
  }) {
    return UserSQLModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      password: password ?? this.password,
      fotoProfil: hapusFoto ? null : (fotoProfil ?? this.fotoProfil),
    );
  }

  // Huruf pertama nama, dipakai saat foto profil belum ada.
  String get inisial {
    final bersih = nama.trim();
    return bersih.isEmpty ? '?' : bersih[0].toUpperCase();
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
      fotoProfil: map['fotoProfil'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserSQLModel.fromJson(String source) =>
      UserSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

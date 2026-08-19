import 'dart:convert';

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

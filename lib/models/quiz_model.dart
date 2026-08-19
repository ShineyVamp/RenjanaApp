import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class QuizSQLModel {
  int? id;
  final String kategori;
  final String tema;
  final String soal;
  final List<String> daftarJawaban;
  final int jawabanBenar;
  QuizSQLModel({
    this.id,
    required this.kategori,
    required this.tema,
    required this.soal,
    required this.daftarJawaban,
    required this.jawabanBenar,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kategori': kategori,
      'tema': tema,
      'soal': soal,
      'daftarJawaban': jsonEncode(daftarJawaban),
      'jawabanBenar': jawabanBenar,
    };
  }

  factory QuizSQLModel.fromMap(Map<String, dynamic> map) {
    return QuizSQLModel(
      id: map['id'] != null ? map['id'] as int : null,
      kategori: map['kategori'] as String,
      tema: map['tema'] as String,
      soal: map['soal'] as String,
      daftarJawaban: map['daftarJawaban'] is String
          ? List<String>.from(jsonDecode(map['daftarJawaban'] as String))
          : List<String>.from(map['daftarJawaban'] as List),
      jawabanBenar: map['jawabanBenar'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizSQLModel.fromJson(String source) =>
      QuizSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

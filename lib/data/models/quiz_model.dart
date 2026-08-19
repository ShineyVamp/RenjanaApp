import 'dart:convert';

class QuizSQLModel {
  int? id;
  final String kategori;
  final String tema;
  final String soal;
  final List<String> daftarJawaban;
  final int jawabanBenar;
  final String? gambar;

  QuizSQLModel({
    this.id,
    required this.kategori,
    required this.tema,
    required this.soal,
    required this.daftarJawaban,
    required this.jawabanBenar,
    this.gambar,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kategori': kategori,
      'tema': tema,
      'soal': soal,
      'daftarJawaban': jsonEncode(daftarJawaban),
      'jawabanBenar': jawabanBenar,
      'gambar': gambar,
    };
  }

  factory QuizSQLModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedJawaban = [];
    if (map['daftarJawaban'] is String) {
      try {
        parsedJawaban = List<String>.from(
          jsonDecode(map['daftarJawaban'] as String),
        );
      } catch (_) {
        parsedJawaban = [];
      }
    } else if (map['daftarJawaban'] is List) {
      parsedJawaban = List<String>.from(map['daftarJawaban'] as List);
    }

    return QuizSQLModel(
      id: map['id'] != null ? map['id'] as int : null,
      kategori: map['kategori'] as String? ?? '',
      tema: map['tema'] as String? ?? '',
      soal: map['soal'] as String? ?? '',
      daftarJawaban: parsedJawaban,
      jawabanBenar: map['jawabanBenar'] as int? ?? 0,
      gambar: map['gambar'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuizSQLModel.fromJson(String source) =>
      QuizSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

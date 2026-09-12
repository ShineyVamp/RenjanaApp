// section model kuis
import 'dart:convert';

class QuizSQLModel {
  int? id;
  final String kategori;
  final String subKategori;
  final String tema;
  final String soal;
  final List<String> daftarJawaban;
  final int jawabanBenar;
  final String? gambar;
  final String? penjelasan;

  QuizSQLModel({
    this.id,
    required this.kategori,
    this.subKategori = '',
    required this.tema,
    required this.soal,
    required this.daftarJawaban,
    required this.jawabanBenar,
    this.gambar,
    this.penjelasan,
  });

  // section serialisasi
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'kategori': kategori,
      'subKategori': subKategori,
      'tema': tema,
      'soal': soal,
      'daftarJawaban': jsonEncode(daftarJawaban),
      'jawabanBenar': jawabanBenar,
      'gambar': gambar,
      'penjelasan': penjelasan,
    };
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'id': id,
      'kategori': kategori,
      'subKategori': subKategori,
      'tema': tema,
      'soal': soal,
      'daftarJawaban': daftarJawaban,
      'jawabanBenar': jawabanBenar,
      'gambar': gambar,
      'penjelasan': penjelasan,
    };
  }

  // section deserialisasi
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
      id: map['id'] != null ? (map['id'] as num).toInt() : null,
      kategori: map['kategori'] as String? ?? '',
      subKategori: map['subKategori'] as String? ?? '',
      tema: map['tema'] as String? ?? '',
      soal: map['soal'] as String? ?? '',
      daftarJawaban: parsedJawaban,
      jawabanBenar: (map['jawabanBenar'] as num?)?.toInt() ?? 0,
      gambar: map['gambar'] as String?,
      penjelasan: map['penjelasan'] as String?,
    );
  }
}

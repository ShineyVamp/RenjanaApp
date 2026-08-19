import 'dart:convert';

class ContentSQLModel {
  int? id;
  final String tipe; // 'sejarah', 'budaya', 'koleksi', 'destinasi'
  final String kodeTag; // cth: 'HIS-150845-A', 'BUD-SNJT-1'
  final String judul;
  final String deskripsi;
  final String? gambar;
  final String? extraInfo; // Tanggal / lokasi / info tambahan

  ContentSQLModel({
    this.id,
    required this.tipe,
    required this.kodeTag,
    required this.judul,
    required this.deskripsi,
    this.gambar,
    this.extraInfo,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'tipe': tipe,
      'kodeTag': kodeTag,
      'judul': judul,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'extraInfo': extraInfo,
    };
  }

  factory ContentSQLModel.fromMap(Map<String, dynamic> map) {
    return ContentSQLModel(
      id: map['id'] != null ? map['id'] as int : null,
      tipe: map['tipe'] as String? ?? 'sejarah',
      kodeTag: map['kodeTag'] as String? ?? '',
      judul: map['judul'] as String? ?? '',
      deskripsi: map['deskripsi'] as String? ?? '',
      gambar: map['gambar'] as String?,
      extraInfo: map['extraInfo'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentSQLModel.fromJson(String source) =>
      ContentSQLModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

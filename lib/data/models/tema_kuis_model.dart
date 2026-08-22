import 'quiz_model.dart';

// Satu tema kuis beserta soal-soalnya, hasil pengelompokan baris tabel quiz
// per nama tema. Dipakai halaman Kuis dan halaman kategori kuis.
class TemaKuis {
  final String tema;
  final String kategori;
  final String subKategori;
  final String gambar;
  final String contohSoal;
  final List<QuizSQLModel> soal;

  const TemaKuis({
    required this.tema,
    required this.kategori,
    required this.subKategori,
    required this.gambar,
    required this.contohSoal,
    required this.soal,
  });

  int get jumlahSoal => soal.length;

  // Kategori dan contoh soal diambil dari soal pertama; sampul dan
  // sub-kategori diambil dari soal pertama yang mengisinya.
  static List<TemaKuis> dariSoal(List<QuizSQLModel> daftar) {
    final kelompok = <String, List<QuizSQLModel>>{};
    for (final q in daftar) {
      final tema = q.tema.trim();
      if (tema.isEmpty) continue;
      kelompok.putIfAbsent(tema, () => []).add(q);
    }

    return kelompok.entries.map((entri) {
      final isi = entri.value;
      final pertama = isi.first;

      var gambar = '';
      var subKategori = '';
      for (final q in isi) {
        if (gambar.isEmpty && (q.gambar?.trim().isNotEmpty ?? false)) {
          gambar = q.gambar!.trim();
        }
        if (subKategori.isEmpty && q.subKategori.trim().isNotEmpty) {
          subKategori = q.subKategori.trim();
        }
      }

      return TemaKuis(
        tema: entri.key,
        kategori: pertama.kategori,
        subKategori: subKategori,
        gambar: gambar,
        contohSoal: pertama.soal,
        soal: isi,
      );
    }).toList();
  }
}

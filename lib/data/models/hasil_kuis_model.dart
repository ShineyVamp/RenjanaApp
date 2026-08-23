// Satu percobaan kuis yang sudah diselesaikan, isi tabel `kuis_riwayat`.
// Tema kosong berarti kuis acak sekategori, bukan kuis satu tema.
class HasilKuis {
  final int? id;
  final String kategori;
  final String subKategori;
  final String tema;
  final int jumlahSoal;
  final int benar;
  final int salah;
  final int detik;
  final DateTime selesaiPada;

  const HasilKuis({
    this.id,
    required this.kategori,
    this.subKategori = '',
    this.tema = '',
    required this.jumlahSoal,
    required this.benar,
    required this.salah,
    required this.detik,
    required this.selesaiPada,
  });

  int get persen => jumlahSoal == 0 ? 0 : ((benar * 100) / jumlahSoal).round();

  bool get sempurna => jumlahSoal > 0 && benar == jumlahSoal;

  bool get kuisTema => tema.trim().isNotEmpty;

  String get judul => kuisTema ? tema : 'Kuis Acak $kategori';

  String get waktuTerbaca {
    final menit = (detik ~/ 60).toString().padLeft(2, '0');
    final sisa = (detik % 60).toString().padLeft(2, '0');
    return '$menit:$sisa';
  }

  // Percobaan dengan jawaban benar terbanyak menang; bila sama, yang paling
  // cepat menang.
  bool lebihBaikDari(HasilKuis lain) {
    if (benar != lain.benar) return benar > lain.benar;
    return detik < lain.detik;
  }

  Map<String, dynamic> toKolom(int userId) => <String, dynamic>{
    'userId': userId,
    'kategori': kategori,
    'subKategori': subKategori,
    'tema': tema,
    'jumlahSoal': jumlahSoal,
    'benar': benar,
    'salah': salah,
    'detik': detik,
    'selesaiPada': selesaiPada.millisecondsSinceEpoch,
  };

  factory HasilKuis.dariKolom(Map<String, dynamic> kolom) {
    return HasilKuis(
      id: kolom['id'] as int?,
      kategori: kolom['kategori'] as String? ?? '',
      subKategori: kolom['subKategori'] as String? ?? '',
      tema: kolom['tema'] as String? ?? '',
      jumlahSoal: (kolom['jumlahSoal'] as num?)?.toInt() ?? 0,
      benar: (kolom['benar'] as num?)?.toInt() ?? 0,
      salah: (kolom['salah'] as num?)?.toInt() ?? 0,
      detik: (kolom['detik'] as num?)?.toInt() ?? 0,
      selesaiPada: DateTime.fromMillisecondsSinceEpoch(
        (kolom['selesaiPada'] as num?)?.toInt() ?? 0,
      ),
    );
  }
}

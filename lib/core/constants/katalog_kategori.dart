// Katalog kategori beserta daftar field khas tiap kategori.
//
// Isinya disimpan di tabel `kategori` dan dihidrasi sekali saat aplikasi mulai
// lewat KategoriRepository.muat(). Daftar bawaan di berkas ini dipakai sebagai
// isi awal tabel sekaligus cadangan bila hidrasi belum jalan.
//
// Ranah memisahkan beberapa katalog di dalam satu tabel yang sama.
import 'dart:convert';

// Kategori budaya, mis. Rumah Adat atau Kuliner Tradisional.
const String ranahBudaya = 'budaya';

enum TipeField {
  teks, // satu baris
  teksPanjang, // paragraf
  daftar, // beberapa baris bernomor, mis. bahan atau langkah
}

TipeField tipeFieldDariNama(String? nama) {
  final cari = nama?.trim() ?? '';
  for (final tipe in TipeField.values) {
    if (tipe.name == cari) return tipe;
  }
  return TipeField.teks;
}

String labelTipeField(TipeField tipe) {
  switch (tipe) {
    case TipeField.teks:
      return 'Satu baris';
    case TipeField.teksPanjang:
      return 'Paragraf';
    case TipeField.daftar:
      return 'Daftar';
  }
}

class FieldKategori {
  final String kunci; // kunci di dalam JSON detailKategori
  final String label; // judul section di detail, label di form admin
  final TipeField tipe;
  final String? petunjuk; // contoh isian di form admin

  const FieldKategori({
    required this.kunci,
    required this.label,
    this.tipe = TipeField.teks,
    this.petunjuk,
  });

  Map<String, dynamic> toMap() => {
    'kunci': kunci,
    'label': label,
    'tipe': tipe.name,
    if (petunjuk != null && petunjuk!.trim().isNotEmpty) 'petunjuk': petunjuk,
  };

  factory FieldKategori.fromMap(Map<String, dynamic> map) {
    final petunjuk = (map['petunjuk'] as String?)?.trim() ?? '';
    return FieldKategori(
      kunci: (map['kunci'] as String?)?.trim() ?? '',
      label: (map['label'] as String?)?.trim() ?? '',
      tipe: tipeFieldDariNama(map['tipe'] as String?),
      petunjuk: petunjuk.isEmpty ? null : petunjuk,
    );
  }
}

// Satu kategori pada salah satu ranah.
class KategoriItem {
  final int? id;
  final String ranah;
  final String kode;
  final String nama;
  final int urutan;
  final List<FieldKategori> field;

  // Kategori dari daftar bawaan. Namanya boleh diubah admin, tetapi barisnya
  // tidak boleh dihapus karena arsip lama menunjuk kodenya.
  final bool bawaan;

  const KategoriItem({
    this.id,
    this.ranah = '',
    required this.kode,
    required this.nama,
    this.urutan = 0,
    this.field = const [],
    this.bawaan = false,
  });

  String get label => nama.toUpperCase();

  KategoriItem salin({
    int? id,
    String? ranah,
    String? kode,
    String? nama,
    int? urutan,
    List<FieldKategori>? field,
    bool? bawaan,
  }) => KategoriItem(
    id: id ?? this.id,
    ranah: ranah ?? this.ranah,
    kode: kode ?? this.kode,
    nama: nama ?? this.nama,
    urutan: urutan ?? this.urutan,
    field: field ?? this.field,
    bawaan: bawaan ?? this.bawaan,
  );

  Map<String, dynamic> toKolom() => {
    'ranah': ranah,
    'kode': kode,
    'nama': nama,
    'urutan': urutan,
    'field': jsonEncode(field.map((f) => f.toMap()).toList()),
    'bawaan': bawaan ? 1 : 0,
  };

  factory KategoriItem.fromMap(Map<String, dynamic> map) => KategoriItem(
    id: map['id'] as int?,
    ranah: (map['ranah'] as String?)?.trim() ?? '',
    kode: (map['kode'] as String?)?.trim() ?? '',
    nama: (map['nama'] as String?)?.trim() ?? '',
    urutan: (map['urutan'] as int?) ?? 0,
    field: bacaFieldKategori(map['field'] as String?),
    bawaan: ((map['bawaan'] as int?) ?? 0) == 1,
  );
}

// Membaca kolom `field` yang berisi JSON larik FieldKategori.
List<FieldKategori> bacaFieldKategori(String? mentah) {
  final teks = mentah?.trim() ?? '';
  if (teks.isEmpty) return const [];

  try {
    final data = jsonDecode(teks);
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => FieldKategori.fromMap(Map<String, dynamic>.from(e)))
        .where((f) => f.kunci.isNotEmpty)
        .toList();
  } catch (_) {
    return const [];
  }
}

// Wadah hasil hidrasi katalog dari database.
class KatalogKategori {
  KatalogKategori._();

  static Map<String, List<KategoriItem>> _isi = const {};

  // Dipasang KategoriRepository setiap kali isi tabel dibaca ulang.
  static void pasang(Map<String, List<KategoriItem>> isi) {
    _isi = isi;
  }

  // Isi satu ranah, urut sesuai kolom urutan. Selama hidrasi belum jalan atau
  // ranahnya kosong, daftar bawaan yang dipakai supaya halaman tetap terisi.
  static List<KategoriItem> ranah(String nama) {
    final tersimpan = _isi[nama];
    if (tersimpan != null && tersimpan.isNotEmpty) return tersimpan;
    return kategoriBawaan(nama);
  }
}

// Daftar bawaan tiap ranah, dipakai menyemai tabel dan sebagai cadangan.
List<KategoriItem> kategoriBawaan(String ranah) => _bawaan[ranah] ?? const [];

Iterable<String> get ranahKategori => _bawaan.keys;

// Melengkapi daftar mentah dengan ranah, urutan sesuai posisi, dan penanda
// bawaan, supaya ketiganya tidak perlu ditulis ulang di tiap baris.
List<KategoriItem> _lengkapi(String ranah, List<KategoriItem> daftar) => [
  for (var i = 0; i < daftar.length; i++)
    daftar[i].salin(ranah: ranah, urutan: i + 1, bawaan: true),
];

final Map<String, List<KategoriItem>> _bawaan = {
  ranahBudaya: _lengkapi(ranahBudaya, _budayaMentah),
};

const List<KategoriItem> _budayaMentah = [
  KategoriItem(
    kode: 'RMH',
    nama: 'Rumah Adat',
    field: [
      FieldKategori(
        kunci: 'bahanBangunan',
        label: 'Bahan Bangunan',
        petunjuk: 'Kayu uru, bambu, ijuk',
      ),
      FieldKategori(
        kunci: 'strukturKhas',
        label: 'Struktur Khas',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'bagianRumah',
        label: 'Bagian Rumah',
        tipe: TipeField.daftar,
        petunjuk: 'Satu bagian per baris',
      ),
      FieldKategori(
        kunci: 'fungsiSosial',
        label: 'Fungsi Sosial',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'TRN',
    nama: 'Tarian Tradisional',
    field: [
      FieldKategori(
        kunci: 'jumlahPenari',
        label: 'Jumlah Penari',
        petunjuk: '8-12 penari perempuan',
      ),
      FieldKategori(
        kunci: 'pengiring',
        label: 'Musik Pengiring',
        petunjuk: 'Gendang, serune kalee',
      ),
      FieldKategori(
        kunci: 'gerakUtama',
        label: 'Gerak Utama',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'waktuPementasan',
        label: 'Waktu Pementasan',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'PKN',
    nama: 'Pakaian Adat',
    field: [
      FieldKategori(kunci: 'bahan', label: 'Bahan Kain'),
      FieldKategori(
        kunci: 'bagianBusana',
        label: 'Bagian Busana',
        tipe: TipeField.daftar,
      ),
      FieldKategori(kunci: 'warnaDominan', label: 'Warna Dominan'),
      FieldKategori(
        kunci: 'pemakaian',
        label: 'Kesempatan Pemakaian',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'UPC',
    nama: 'Upacara dan Tradisi Adat',
    field: [
      FieldKategori(
        kunci: 'waktuPelaksanaan',
        label: 'Waktu Pelaksanaan',
        petunjuk: 'Setiap panen raya',
      ),
      FieldKategori(kunci: 'pelaksana', label: 'Pelaksana'),
      FieldKategori(
        kunci: 'tahapan',
        label: 'Tahapan Upacara',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'perlengkapan',
        label: 'Perlengkapan',
        tipe: TipeField.daftar,
      ),
    ],
  ),
  KategoriItem(
    kode: 'MSK',
    nama: 'Alat Musik dan Lagu Daerah',
    field: [
      FieldKategori(kunci: 'bahan', label: 'Bahan'),
      FieldKategori(
        kunci: 'caraMemainkan',
        label: 'Cara Memainkan',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'tanggaNada',
        label: 'Tangga Nada',
        petunjuk: 'Slendro dan pelog',
      ),
      FieldKategori(
        kunci: 'repertoar',
        label: 'Repertoar Terkenal',
        tipe: TipeField.daftar,
      ),
    ],
  ),
  KategoriItem(
    kode: 'SNJT',
    nama: 'Senjata Tradisional',
    field: [
      FieldKategori(kunci: 'bahan', label: 'Bahan'),
      FieldKategori(
        kunci: 'teknikPembuatan',
        label: 'Teknik Pembuatan',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'bagianSenjata',
        label: 'Bagian Senjata',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'fungsi',
        label: 'Fungsi',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'SRK',
    nama: 'Seni Rupa dan Kriya',
    field: [
      FieldKategori(kunci: 'medium', label: 'Media dan Bahan'),
      FieldKategori(
        kunci: 'teknik',
        label: 'Teknik Pengerjaan',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'motifKhas',
        label: 'Motif Khas',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'maknaMotif',
        label: 'Makna Motif',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'BHS',
    nama: 'Bahasa dan Sastra Daerah',
    field: [
      FieldKategori(kunci: 'rumpunBahasa', label: 'Rumpun Bahasa'),
      FieldKategori(kunci: 'jumlahPenutur', label: 'Jumlah Penutur'),
      FieldKategori(kunci: 'aksara', label: 'Aksara'),
      FieldKategori(
        kunci: 'contohUngkapan',
        label: 'Contoh Ungkapan',
        tipe: TipeField.daftar,
        petunjuk: 'Tulis ungkapan beserta artinya',
      ),
      FieldKategori(
        kunci: 'karyaSastra',
        label: 'Karya Sastra Terkenal',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'SIT',
    nama: 'Situs dan Bangunan Bersejarah',
    field: [
      FieldKategori(
        kunci: 'tahunBerdiri',
        label: 'Tahun Berdiri',
        petunjuk: 'Abad ke-8 Masehi',
      ),
      FieldKategori(kunci: 'pendiri', label: 'Pendiri'),
      FieldKategori(kunci: 'gayaArsitektur', label: 'Gaya Arsitektur'),
      FieldKategori(
        kunci: 'fungsiAsli',
        label: 'Fungsi Asli',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'kondisiSekarang',
        label: 'Kondisi Sekarang',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'KLN',
    nama: 'Kuliner Tradisional',
    field: [
      FieldKategori(
        kunci: 'bahan',
        label: 'Bahan Utama',
        tipe: TipeField.daftar,
        petunjuk: 'Satu bahan per baris',
      ),
      FieldKategori(kunci: 'bumbu', label: 'Bumbu', tipe: TipeField.daftar),
      FieldKategori(
        kunci: 'langkah',
        label: 'Cara Memasak',
        tipe: TipeField.daftar,
        petunjuk: 'Satu langkah per baris, urut',
      ),
      FieldKategori(
        kunci: 'rasa',
        label: 'Profil Rasa',
        petunjuk: 'Gurih, pedas, sedikit manis',
      ),
      FieldKategori(
        kunci: 'penyajian',
        label: 'Cara Penyajian',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'TTR',
    nama: 'Seni Pertunjukan dan Teater',
    field: [
      FieldKategori(kunci: 'jumlahPemain', label: 'Jumlah Pemain'),
      FieldKategori(kunci: 'pengiring', label: 'Musik Pengiring'),
      FieldKategori(
        kunci: 'durasi',
        label: 'Durasi Pementasan',
        petunjuk: 'Semalam suntuk, 6-8 jam',
      ),
      FieldKategori(
        kunci: 'lakon',
        label: 'Lakon Populer',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'jalanCerita',
        label: 'Jalan Cerita',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'PRM',
    nama: 'Permainan dan Olahraga Tradisional',
    field: [
      FieldKategori(
        kunci: 'jumlahPemain',
        label: 'Jumlah Pemain',
        petunjuk: '2 orang',
      ),
      FieldKategori(
        kunci: 'alat',
        label: 'Alat yang Dibutuhkan',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'caraBermain',
        label: 'Cara Bermain',
        tipe: TipeField.daftar,
        petunjuk: 'Satu langkah per baris, urut',
      ),
      FieldKategori(
        kunci: 'nilai',
        label: 'Nilai yang Diajarkan',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
  KategoriItem(
    kode: 'FKL',
    nama: 'Cerita Rakyat dan Mitologi',
    field: [
      FieldKategori(
        kunci: 'tokoh',
        label: 'Tokoh Utama',
        tipe: TipeField.daftar,
      ),
      FieldKategori(
        kunci: 'latar',
        label: 'Latar Cerita',
        petunjuk: 'Pesisir Sumatera Barat',
      ),
      FieldKategori(
        kunci: 'ringkasanCerita',
        label: 'Jalan Cerita',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'pesanMoral',
        label: 'Pesan Moral',
        tipe: TipeField.teksPanjang,
      ),
      FieldKategori(
        kunci: 'versiLain',
        label: 'Versi Lain',
        tipe: TipeField.teksPanjang,
      ),
    ],
  ),
];

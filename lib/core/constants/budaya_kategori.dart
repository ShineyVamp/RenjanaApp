// Katalog kategori budaya, dipakai beranda, halaman kategori, dan form admin.
// Tiap kategori membawa daftar field khasnya sendiri; halaman detail dan form
// admin dibangkitkan dari daftar itu, jadi menambah kategori cukup di file ini.

enum TipeField {
  teks, // satu baris
  teksPanjang, // paragraf
  daftar, // beberapa baris bernomor, mis. bahan atau langkah
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
}

class BudayaKategori {
  final String kode;
  final String nama;
  final List<FieldKategori> field;

  const BudayaKategori({
    required this.kode,
    required this.nama,
    this.field = const [],
  });

  String get label => nama.toUpperCase();
}

const List<BudayaKategori> budayaKategoriList = [
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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
  BudayaKategori(
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

// penanda item yang juga tempat wisata
const String kodeDestinasiSuffix = '-D';

BudayaKategori? kategoriByKode(String kode) {
  final target = kode.trim().toUpperCase();
  for (final k in budayaKategoriList) {
    if (k.kode == target) return k;
  }
  return null;
}

String namaKategori(String kode) => kategoriByKode(kode)?.nama ?? kode;

List<FieldKategori> fieldKategori(String kode) =>
    kategoriByKode(kode)?.field ?? const [];

// ID tag budaya: BUD-<kategori>-<urutan>, plus -D bila destinasi.
String buatKodeTagBudaya({
  required String jenis,
  required int urutan,
  bool isDestinasi = false,
}) {
  final base = 'BUD-${jenis.trim().toUpperCase()}-$urutan';
  return isDestinasi ? '$base$kodeDestinasiSuffix' : base;
}

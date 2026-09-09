import '../models/wilayah_model.dart';

export '../models/wilayah_model.dart';

const List<GugusPulau> gugusPulauList = [
  GugusPulau(
    id: 'sumatera',
    nama: 'Sumatera',
    lon: 101.5,
    lat: -0.5,
    lonMin: 94.5,
    latMax: 6.5,
    lonMax: 107,
    latMin: -6.5,
    gambar: 'assets/images/onboardin2.jpg',
    deskripsi:
        'Pulau terbesar keenam di dunia yang menjadi tempat lahir Kerajaan '
        'Sriwijaya dan Kesultanan Aceh. Rumpun Melayu, Minangkabau, Batak, '
        'dan Lampung tumbuh berdampingan di sini, meninggalkan warisan berupa '
        'rumah gadang, kain songket, ulos, hingga tradisi merantau.',
    provinsi: [
      Provinsi(
        'Aceh',
        'Banda Aceh',
        95.32,
        5.55,
        julukan: 'Serambi Mekkah',
        deskripsi:
            'Gerbang masuk Islam ke Nusantara dan pusat Kesultanan Aceh '
            'Darussalam. Dikenal lewat Tari Saman, Masjid Raya Baiturrahman, '
            'dan kopi Gayo dari dataran tinggi.',
      ),
      Provinsi(
        'Sumatera Utara',
        'Medan',
        98.67,
        3.59,
        julukan: 'Tanah Batak',
        deskripsi:
            'Rumah bagi Danau Toba, danau vulkanik terbesar di dunia, serta '
            'masyarakat Batak dengan sistem marga, kain ulos, dan rumah bolon '
            'beratap melengkung.',
      ),
      Provinsi(
        'Sumatera Barat',
        'Padang',
        100.35,
        -0.95,
        julukan: 'Ranah Minang',
        deskripsi:
            'Tanah Minangkabau yang menganut garis keturunan ibu, satu-satunya '
            'masyarakat matrilineal terbesar di dunia. Terkenal dengan rumah '
            'gadang bergonjong, randai, dan rendang.',
      ),
      Provinsi(
        'Riau',
        'Pekanbaru',
        101.45,
        0.51,
        julukan: 'Bumi Lancang Kuning',
        deskripsi:
            'Pusat kebudayaan Melayu daratan yang tumbuh di sepanjang Sungai '
            'Siak. Kaya tradisi lisan berupa pantun, syair, dan tari zapin.',
      ),
      Provinsi(
        'Kepulauan Riau',
        'Tanjungpinang',
        104.46,
        0.92,
        julukan: 'Bunda Tanah Melayu',
        deskripsi:
            'Gugusan pulau tempat Pulau Penyengat berdiri, tempat Raja Ali '
            'Haji menulis Gurindam Dua Belas dan meletakkan dasar bahasa '
            'Melayu yang kelak menjadi bahasa Indonesia.',
      ),
      Provinsi(
        'Jambi',
        'Jambi',
        103.61,
        -1.61,
        julukan: 'Bumi Sepucuk Jambi Sembilan Lurah',
        deskripsi:
            'Menyimpan Candi Muaro Jambi, kompleks percandian terluas di Asia '
            'Tenggara, bekas pusat pendidikan Buddha era Sriwijaya.',
      ),
      Provinsi(
        'Bengkulu',
        'Bengkulu',
        102.26,
        -3.80,
        julukan: 'Bumi Rafflesia',
        deskripsi:
            'Tempat tumbuh bunga Rafflesia arnoldii dan berdirinya Benteng '
            'Marlborough. Setiap tahun menggelar Festival Tabut memperingati '
            'gugurnya Husain bin Ali.',
      ),
      Provinsi(
        'Sumatera Selatan',
        'Palembang',
        104.76,
        -2.99,
        julukan: 'Bumi Sriwijaya',
        deskripsi:
            'Bekas ibu kota Kerajaan Sriwijaya yang menguasai jalur niaga '
            'maritim Asia. Warisannya hidup lewat kain songket, rumah limas, '
            'dan pempek.',
      ),
      Provinsi(
        'Kepulauan Bangka Belitung',
        'Pangkalpinang',
        106.11,
        -2.13,
        julukan: 'Negeri Serumpun Sebalai',
        deskripsi:
            'Kepulauan penghasil timah dengan pantai berhias batu granit '
            'raksasa. Budayanya berpadu antara Melayu dan peranakan Tionghoa.',
      ),
      Provinsi(
        'Lampung',
        'Bandar Lampung',
        105.26,
        -5.43,
        julukan: 'Sang Bumi Ruwa Jurai',
        deskripsi:
            'Gerbang Sumatera dari Jawa, dikenal lewat kain tapis bersulam '
            'benang emas dan mahkota siger yang menjadi lambang daerah.',
      ),
    ],
  ),
  GugusPulau(
    id: 'jawa',
    nama: 'Jawa',
    lon: 110,
    lat: -7.4,
    lonMin: 105,
    latMax: -5.5,
    lonMax: 115.5,
    latMin: -9,
    gambar: 'assets/images/borobudurB.jpg',
    deskripsi:
        'Pulau terpadat di dunia dan panggung utama sejarah Nusantara, dari '
        'Mataram Kuno, Majapahit, hingga Proklamasi 1945. Batik, gamelan, dan '
        'wayang yang lahir di sini telah diakui UNESCO sebagai warisan dunia.',
    provinsi: [
      Provinsi(
        'Banten',
        'Serang',
        106.15,
        -6.12,
        julukan: 'Tanah Jawara',
        deskripsi:
            'Bekas Kesultanan Banten yang masyhur lewat atraksi debus. Di '
            'pedalamannya, masyarakat Baduy masih memelihara adat tanpa '
            'listrik dan kendaraan bermotor.',
      ),
      Provinsi(
        'DKI Jakarta',
        'Jakarta',
        106.85,
        -6.21,
        julukan: 'Kota Metropolitan',
        deskripsi:
            'Ibu kota tempat Proklamasi dibacakan. Budaya Betawi hidup lewat '
            'ondel-ondel, gambang kromong, dan lenong di tengah kota modern.',
      ),
      Provinsi(
        'Jawa Barat',
        'Bandung',
        107.61,
        -6.91,
        julukan: 'Tatar Sunda',
        deskripsi:
            'Jantung kebudayaan Sunda dengan angklung, wayang golek, dan tari '
            'jaipong. Lanskapnya dipenuhi gunung api yang melahirkan banyak '
            'cerita rakyat.',
      ),
      Provinsi(
        'Jawa Tengah',
        'Semarang',
        110.42,
        -6.97,
        julukan: 'Jantung Budaya Jawa',
        deskripsi:
            'Tempat berdirinya Candi Borobudur dan Prambanan serta Keraton '
            'Surakarta. Pusat kerajinan batik tulis Solo, Pekalongan, dan '
            'Lasem.',
      ),
      Provinsi(
        'DI Yogyakarta',
        'Yogyakarta',
        110.36,
        -7.80,
        julukan: 'Kota Pelajar',
        deskripsi:
            'Satu-satunya daerah yang masih dipimpin sultan. Keraton '
            'Ngayogyakarta menjaga hidup gamelan, tari bedhaya, wayang kulit, '
            'dan tempa keris.',
      ),
      Provinsi(
        'Jawa Timur',
        'Surabaya',
        112.75,
        -7.25,
        julukan: 'Kota Pahlawan',
        deskripsi:
            'Bekas pusat Majapahit dan medan Pertempuran 10 November. Kaya '
            'kesenian rakyat seperti reog Ponorogo, ludruk, dan karapan sapi '
            'Madura.',
      ),
    ],
  ),
  GugusPulau(
    id: 'kalimantan',
    nama: 'Kalimantan',
    lon: 114,
    lat: 0.5,
    lonMin: 108.5,
    latMax: 4.5,
    lonMax: 119.5,
    latMin: -4.5,
    gambar: 'assets/images/onboardin1.jpg',
    deskripsi:
        'Bagian Indonesia dari Pulau Borneo, dijalin ribuan kilometer sungai '
        'yang menjadi jalan utama kehidupan. Tanah rumpun Dayak dan Banjar '
        'dengan rumah betang, tato tradisional, dan ukiran kayu.',
    provinsi: [
      Provinsi(
        'Kalimantan Barat',
        'Pontianak',
        109.33,
        -0.03,
        julukan: 'Bumi Khatulistiwa',
        deskripsi:
            'Dilintasi garis khatulistiwa tepat di Kota Pontianak. Rumah bagi '
            'Dayak Iban dan Kanayatn dengan tenun ikat serta rumah panjang.',
      ),
      Provinsi(
        'Kalimantan Tengah',
        'Palangka Raya',
        113.92,
        -2.21,
        julukan: 'Bumi Tambun Bungai',
        deskripsi:
            'Pusat kepercayaan Kaharingan dengan upacara Tiwah, ritual '
            'pengantaran arwah leluhur yang berlangsung berhari-hari.',
      ),
      Provinsi(
        'Kalimantan Selatan',
        'Banjarbaru',
        114.83,
        -3.44,
        julukan: 'Bumi Lambung Mangkurat',
        deskripsi:
            'Tanah Banjar dengan pasar terapung di atas Sungai Barito dan kain '
            'sasirangan yang dahulu dipakai sebagai kain penyembuh.',
      ),
      Provinsi(
        'Kalimantan Timur',
        'Samarinda',
        117.15,
        -0.50,
        julukan: 'Bumi Etam',
        deskripsi:
            'Tempat berdirinya Kutai Martadipura, kerajaan Hindu tertua di '
            'Indonesia, yang meninggalkan prasasti Yupa abad ke-4.',
      ),
      Provinsi(
        'Kalimantan Utara',
        'Tanjung Selor',
        117.37,
        2.84,
        julukan: 'Bumi Benuanta',
        deskripsi:
            'Provinsi termuda di Indonesia, dihuni suku Tidung dan Dayak '
            'Kenyah yang terkenal dengan tari Kancet dan manik-manik.',
      ),
    ],
  ),
  GugusPulau(
    id: 'sulawesi',
    nama: 'Sulawesi',
    lon: 121,
    lat: -2,
    lonMin: 118,
    latMax: 2.5,
    lonMax: 125.5,
    latMin: -6.5,
    gambar: 'assets/images/onboardin1.jpg',
    deskripsi:
        'Pulau berlengan empat yang mempertemukan pelaut Bugis-Makassar, '
        'masyarakat Toraja di pegunungan, dan Minahasa di utara. Dari sini '
        'lahir kapal pinisi yang berlayar hingga Madagaskar.',
    provinsi: [
      Provinsi(
        'Sulawesi Utara',
        'Manado',
        124.84,
        1.47,
        julukan: 'Bumi Nyiur Melambai',
        deskripsi:
            'Tanah Minahasa dengan tari perang Kabasaran dan Taman Nasional '
            'Bunaken yang menjadi salah satu titik selam terbaik dunia.',
      ),
      Provinsi(
        'Gorontalo',
        'Gorontalo',
        123.06,
        0.54,
        julukan: 'Serambi Madinah',
        deskripsi:
            'Daerah dengan adat yang berpaut erat pada syariat Islam. Dikenal '
            'lewat sulaman karawo yang dikerjakan dengan mencabut serat kain '
            'satu per satu.',
      ),
      Provinsi(
        'Sulawesi Tengah',
        'Palu',
        119.87,
        -0.90,
        julukan: 'Bumi Tadulako',
        deskripsi:
            'Menyimpan patung megalit berusia ribuan tahun di Lembah Bada dan '
            'kain kulit kayu (fuya) yang ditempa dari kulit pohon beringin.',
      ),
      Provinsi(
        'Sulawesi Barat',
        'Mamuju',
        118.89,
        -2.68,
        julukan: 'Bumi Malaqbi',
        deskripsi:
            'Tanah suku Mandar, pembuat perahu sandeq bercadik yang dikenal '
            'sebagai perahu layar tercepat di Nusantara.',
      ),
      Provinsi(
        'Sulawesi Selatan',
        'Makassar',
        119.43,
        -5.15,
        julukan: 'Bumi Siri na Pacce',
        deskripsi:
            'Pertemuan tiga rumpun besar: Bugis, Makassar, dan Toraja. Dari '
            'sini lahir kapal pinisi, rumah tongkonan, dan falsafah harga '
            'diri siri’ na pacce.',
      ),
      Provinsi(
        'Sulawesi Tenggara',
        'Kendari',
        122.51,
        -3.99,
        julukan: 'Bumi Anoa',
        deskripsi:
            'Rumah Kesultanan Buton dengan Benteng Keraton Buton, benteng '
            'batu terluas di dunia, serta tenun Buton bermotif geometris.',
      ),
    ],
  ),
  GugusPulau(
    id: 'balinusra',
    nama: 'Bali & Nusa Tenggara',
    lon: 119.5,
    lat: -9,
    lonMin: 114,
    latMax: -7.8,
    lonMax: 125.5,
    latMin: -11,
    gambar: 'assets/images/onboardin3.jpg',
    deskripsi:
        'Rangkaian pulau dari Bali hingga Timor yang menyimpan keragaman '
        'paling padat di Nusantara: Hindu Bali dengan subak dan odalan, Sasak '
        'di Lombok, serta tenun ikat dan Pasola di Sumba.',
    provinsi: [
      Provinsi(
        'Bali',
        'Denpasar',
        115.50,
        -8.65,
        julukan: 'Pulau Dewata',
        deskripsi:
            'Pulau dengan ribuan pura dan sistem pengairan subak warisan '
            'UNESCO. Kehidupan warganya diatur kalender upacara, dari odalan '
            'hingga Nyepi.',
      ),
      Provinsi(
        'Nusa Tenggara Barat',
        'Mataram',
        117.80,
        -8.58,
        julukan: 'Bumi Gora',
        deskripsi:
            'Menyatukan Lombok dengan budaya Sasak dan Sumbawa dengan tradisi '
            'Samawa. Dikenal lewat tenun songket Sukarara dan gendang beleq.',
      ),
      Provinsi(
        'Nusa Tenggara Timur',
        'Kupang',
        123.60,
        -10.18,
        julukan: 'Bumi Flobamora',
        deskripsi:
            'Rumah komodo di Pulau Rinca dan Flores, tenun ikat Sumba, serta '
            'Pasola, tradisi lempar lembing berkuda sebagai upacara panen.',
      ),
    ],
  ),
  GugusPulau(
    id: 'maluku',
    nama: 'Maluku',
    lon: 128,
    lat: -1.5,
    lonMin: 124.5,
    latMax: 3,
    lonMax: 135,
    latMin: -8.5,
    gambar: 'assets/images/onboardin2.jpg',
    deskripsi:
        'Kepulauan Rempah yang menarik pedagang Arab, Tiongkok, dan Eropa '
        'berabad-abad lamanya demi pala dan cengkeh. Tradisi baharinya hidup '
        'lewat tari cakalele, sasi, dan perahu kora-kora.',
    provinsi: [
      Provinsi(
        'Maluku Utara',
        'Sofifi',
        127.57,
        0.73,
        julukan: 'Bumi Moloku Kie Raha',
        deskripsi:
            'Tanah empat kesultanan: Ternate, Tidore, Bacan, dan Jailolo. '
            'Cengkeh dari sini pernah menjadi komoditas termahal di dunia.',
      ),
      Provinsi(
        'Maluku',
        'Ambon',
        128.18,
        -3.70,
        julukan: 'Bumi Raja-Raja',
        deskripsi:
            'Pusat perdagangan pala Kepulauan Banda dan tempat lahir tradisi '
            'pela gandong, ikatan persaudaraan antarnegeri yang melintasi '
            'batas agama.',
      ),
    ],
  ),
  GugusPulau(
    id: 'papua',
    nama: 'Papua',
    lon: 137,
    lat: -4,
    lonMin: 130.5,
    latMax: 0.5,
    lonMax: 141.5,
    latMin: -9.5,
    gambar: 'assets/images/onboardin3.jpg',
    deskripsi:
        'Wilayah paling timur Indonesia dengan lebih dari 250 bahasa daerah, '
        'jumlah terbanyak di negeri ini. Menyimpan ukiran Asmat, honai suku '
        'Dani di Lembah Baliem, dan bentang laut Raja Ampat.',
    provinsi: [
      Provinsi(
        'Papua Barat Daya',
        'Sorong',
        131.25,
        -0.88,
        julukan: 'Bumi Kasuari',
        deskripsi:
            'Gerbang menuju Raja Ampat, kawasan dengan keanekaragaman hayati '
            'laut tertinggi di dunia, serta rumah suku Moi.',
      ),
      Provinsi(
        'Papua Barat',
        'Manokwari',
        134.06,
        -0.86,
        julukan: 'Kota Injil',
        deskripsi:
            'Titik masuk penyebaran Injil di Tanah Papua pada 1855. Dihuni '
            'suku Arfak dengan tari Tumbu Tanah dan rumah kaki seribu.',
      ),
      Provinsi(
        'Papua Tengah',
        'Nabire',
        135.50,
        -3.36,
        julukan: 'Bumi Meepago',
        deskripsi:
            'Kawasan Danau Paniai dan pegunungan tengah, wilayah suku Mee dan '
            'Moni yang mengenal noken sebagai tas anyaman serbaguna.',
      ),
      Provinsi(
        'Papua Pegunungan',
        'Wamena',
        138.95,
        -4.10,
        julukan: 'Bumi Lapago',
        deskripsi:
            'Lembah Baliem, tanah suku Dani yang tinggal di rumah honai dan '
            'menggelar Festival Lembah Baliem setiap tahun.',
      ),
      Provinsi(
        'Papua',
        'Jayapura',
        140.72,
        -2.53,
        julukan: 'Bumi Tabi',
        deskripsi:
            'Kawasan Danau Sentani dengan tradisi lukisan kulit kayu khombow '
            'dan tifa sebagai pengiring tari perang.',
      ),
      Provinsi(
        'Papua Selatan',
        'Merauke',
        140.40,
        -8.49,
        julukan: 'Bumi Anim Ha',
        deskripsi:
            'Tanah suku Asmat yang ukiran kayunya dikoleksi museum dunia, '
            'dipahat tanpa sketsa sebagai penghormatan kepada leluhur.',
      ),
    ],
  ),
];

// Kotak tampilan nasional.
const double petaLonMin = 94;
const double petaLatMax = 7.5;
const double petaLonMax = 142;
const double petaLatMin = -12;

int get jumlahProvinsi =>
    gugusPulauList.fold(0, (total, g) => total + g.provinsi.length);

List<Provinsi> get semuaProvinsi => [
  for (final pulau in gugusPulauList) ...pulau.provinsi,
];

Provinsi? provinsiDariNama(String? nama) {
  final target = nama?.trim().toLowerCase();
  if (target == null || target.isEmpty) return null;
  for (final pulau in gugusPulauList) {
    for (final p in pulau.provinsi) {
      if (p.nama.toLowerCase() == target) return p;
    }
  }
  return null;
}

GugusPulau? pulauDariProvinsi(String? namaProvinsi) {
  final target = namaProvinsi?.trim().toLowerCase();
  if (target == null || target.isEmpty) return null;
  for (final pulau in gugusPulauList) {
    for (final p in pulau.provinsi) {
      if (p.nama.toLowerCase() == target) return pulau;
    }
  }
  return null;
}

GugusPulau? pulauDariId(String id) {
  final target = id.trim().toLowerCase();
  for (final pulau in gugusPulauList) {
    if (pulau.id == target) return pulau;
  }
  return null;
}

// Gambar provinsi, memakai gambar pulaunya bila belum diisi sendiri.
String gambarProvinsi(Provinsi provinsi) {
  if (provinsi.gambar != null && provinsi.gambar!.trim().isNotEmpty) {
    return provinsi.gambar!;
  }
  return pulauDariProvinsi(provinsi.nama)?.gambar ?? '';
}

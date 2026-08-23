// Bank soal awal untuk tabel `quiz`, dipakai sekali saat database dibuat.
import '../../models/quiz_model.dart';

final List<QuizSQLModel> defaultQuizList = [
  // Sejarah - Perjalanan Revolusi
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Perjalanan Revolusi',
    soal:
        'Di kota manakah naskah teks proklamasi kemerdekaan Indonesia dirumuskan?',
    daftarJawaban: [
      'Jakarta (Rumah Laksamana Maeda)',
      'Bandung',
      'Yogyakarta',
      'Rengasdengklok',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/perumusan.jpg',
    penjelasan:
        'Naskah proklamasi dirumuskan di kediaman Laksamana Tadashi Maeda di Jalan Imam Bonjol No. 1, Jakarta, pada 16-17 Agustus 1945 dini hari.',
  ),
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Perjalanan Revolusi',
    soal:
        'Siapakah tokoh yang mengetik naskah proklamasi kemerdekaan Indonesia setelah disepakati?',
    daftarJawaban: ['Sayuti Melik', 'Sukarni', 'B.M. Diah', 'Chaerul Saleh'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Sayuti Melik mengetik naskah proklamasi kemerdekaan Indonesia didampingi B.M. Diah menggunakan mesin ketik buatan Jerman.',
  ),
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Perjalanan Revolusi',
    soal:
        'Peristiwa pengamanan Soekarno dan Hatta oleh golongan pemuda ke luar kota dikenal dengan nama...',
    daftarJawaban: [
      'Peristiwa Rengasdengklok',
      'Bandung Lautan Api',
      'Pertempuran Surabaya',
      'Serangan Umum 1 Maret',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/rengasdengklok.jpg',
    penjelasan:
        'Peristiwa Rengasdengklok terjadi pada 16 Agustus 1945 dini hari ketika para pemuda membawa Bung Karno dan Bung Hatta ke Karawang.',
  ),
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Perjalanan Revolusi',
    soal:
        'Di manakah lokasi resmi pembacaan teks proklamasi kemerdekaan Indonesia pada 17 Agustus 1945?',
    daftarJawaban: [
      'Jalan Pegangsaan Timur No. 56, Jakarta',
      'Lapangan Ikada, Jakarta',
      'Gedung Istana Merdeka',
      'Gedung Pancasila',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/170845history.png',
    penjelasan:
        'Teks proklamasi dibacakan oleh Ir. Soekarno didampingi Drs. Mohammad Hatta di halaman rumah Bung Karno di Jl. Pegangsaan Timur No. 56.',
  ),
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Perjalanan Revolusi',
    soal:
        'Siapakah tokoh pahlawan wanita yang menjahit Bendera Pusaka Sang Saka Merah Putih pertama?',
    daftarJawaban: [
      'Fatmawati',
      'R.A. Kartini',
      'Dewi Sartika',
      'Cut Nyak Dien',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Ibu Fatmawati menjahit Bendera Pusaka Sang Saka Merah Putih pada Oktober 1944 yang kemudian dikibarkan pada saat proklamasi.',
  ),

  // Sejarah - Detik-Detik Kemerdekaan
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Detik-Detik Kemerdekaan',
    soal:
        'Siapakah dua pemuda yang bertugas mengibarkan bendera merah putih saat proklamasi 17 Agustus 1945?',
    daftarJawaban: [
      'Latief Hendraningrat dan Suhud Sastro Kusumo',
      'Chaerul Saleh dan Wikana',
      'Sayuti Melik dan B.M. Diah',
      'Sukarni dan Yusuf Kunto',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Pengibaran bendera pertama dilakukan oleh prajurit PETA Latief Hendraningrat dibantu oleh Suhud Sastro Kusumo dan SK Trimurti.',
  ),
  QuizSQLModel(
    kategori: 'SEJARAH',
    tema: 'Detik-Detik Kemerdekaan',
    soal:
        'Badan bentukan Jepang yang bertugas mempersiapkan kemerdekaan Republik Indonesia adalah...',
    daftarJawaban: [
      'BPUPKI dan PPKI',
      'PETA dan Heiho',
      'Putera dan Jawa Hokokai',
      'Keibodan dan Seinendan',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/1308history.png',
    penjelasan:
        'BPUPKI (Badan Penyelidik Usaha-usaha Persiapan Kemerdekaan Indonesia) dibentuk untuk merumuskan dasar negara dan UUD.',
  ),

  // Budaya - Cagar Budaya & Arsitektur
  QuizSQLModel(
    kategori: 'BUDAYA',
    subKategori: 'SIT',
    tema: 'Cagar Budaya & Arsitektur',
    soal:
        'Candi Buddha terbesar di dunia yang terletak di Magelang, Jawa Tengah adalah...',
    daftarJawaban: [
      'Candi Borobudur',
      'Candi Prambanan',
      'Candi Mendut',
      'Candi Sewu',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/borobudurB.jpg',
    penjelasan:
        'Candi Borobudur dibangun pada abad ke-8 oleh Dinasti Syailendra dan diakui sebagai Situs Warisan Dunia oleh UNESCO.',
  ),
  QuizSQLModel(
    kategori: 'BUDAYA',
    subKategori: 'SIT',
    tema: 'Cagar Budaya & Arsitektur',
    soal:
        'Senjata tradisional khas Jawa yang memiliki lekukan (luk) khas dan diakui UNESCO sebagai warisan budaya adalah...',
    daftarJawaban: ['Keris', 'Rencong', 'Mandau', 'Kujang'],
    jawabanBenar: 0,
    gambar: 'assets/images/kerisB.jpg',
    penjelasan:
        'Keris merupakan mahakarya senjata tikam tradisional Nusantara yang mengandung nilai spiritual, metalurgi tinggi, dan estetika mendalam.',
  ),
  QuizSQLModel(
    kategori: 'BUDAYA',
    subKategori: 'SIT',
    tema: 'Cagar Budaya & Arsitektur',
    soal:
        'Rumah adat khas masyarakat suku Toraja yang beratap melengkung seperti haluan perahu dinamakan...',
    daftarJawaban: ['Tongkonan', 'Rumah Gadang', 'Joglo', 'Honai'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        'Tongkonan adalah rumah adat suku Toraja yang berfungsi sebagai pusat kehidupan sosial dan ritual keluarga adat Toraja.',
  ),

  // Budaya - Tradisi & Mahakarya Leluhur
  QuizSQLModel(
    kategori: 'BUDAYA',
    subKategori: 'UPC',
    tema: 'Tradisi & Mahakarya Leluhur',
    soal:
        'Upacara adat pemakaman masyarakat Toraja yang sangat terkenal hingga mancanegara adalah...',
    daftarJawaban: ['Rambu Solo', 'Ngaben', 'Tiwah', 'Kasada'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Rambu Solo adalah upacara pemakaman adat suku Toraja yang bertujuan menghormati dan mengantar arwah leluhur menuju alam baka (Puya).',
  ),
  QuizSQLModel(
    kategori: 'BUDAYA',
    subKategori: 'UPC',
    tema: 'Tradisi & Mahakarya Leluhur',
    soal:
        'Kain tradisional khas Nusa Tenggara Timur yang dibuat dengan teknik pintal tangan dan pewarna alami adalah...',
    daftarJawaban: [
      'Tenun Ikat',
      'Batik Tulis',
      'Songket Palembang',
      'Kain Ulos',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Tenun ikat NTT diwariskan turun-temurun dengan motif khas setiap pulau serta mencerminkan status sosial dan filosofi kehidupan.',
  ),

  // Kedaerahan - Kekayaan Sulawesi Selatan
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Selatan',
    tema: 'Kekayaan Sulawesi Selatan',
    soal:
        'Perahu layar tradisional kebanggaan suku Bugis-Makassar yang telah diakui UNESCO sebagai warisan budaya takbenda adalah...',
    daftarJawaban: [
      'Kapal Pinisi',
      'Perahu Cadik',
      'Kapal Jung',
      'Perahu Lancang',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        'Kapal Pinisi merupakan perahu layar tradisional legendaris suku Bugis dan Makassar dari Bulukumba yang mampu mengarungi samudra dunia.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Selatan',
    tema: 'Kekayaan Sulawesi Selatan',
    soal:
        'Tarian tradisional khas Sulawesi Selatan yang ditampilkan khusus untuk menyambut tamu-tamu kehormatan adalah...',
    daftarJawaban: [
      'Tari Paduppa Bosara',
      'Tari Pendet',
      'Tari Saman',
      'Tari Jaipong',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Tari Paduppa Bosara ditarikan oleh wanita Bugis mengenakan Baju Bodo untuk menyambut dan memberikan penghormatan kepada tamu.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Selatan',
    tema: 'Kekayaan Sulawesi Selatan',
    soal:
        'Kuliner sup khas Makassar dengan kuah pekat berempah dan kacang tanah gurih adalah...',
    daftarJawaban: ['Coto Makassar', 'Rawon', 'Soto Betawi', 'Sop Saudara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Coto Makassar dimasak menggunakan lebih dari 40 jenis rempah (Rampa Patangpulo) dan biasa disantap bersama ketupat.',
  ),

  // Kedaerahan - Pesona Nusantara
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    tema: 'Pesona Nusantara',
    soal:
        'Danau vulkanik terbesar di Asia Tenggara yang terletak di Provinsi Sumatera Utara adalah...',
    daftarJawaban: [
      'Danau Toba',
      'Danau Maninjau',
      'Danau Singkarak',
      'Danau Sentani',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        'Danau Toba adalah kaldera raksasa hasil letusan gunung berapi purba ribuan tahun lalu dan memiliki Pulau Samosir di bagian tengahnya.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    tema: 'Pesona Nusantara',
    soal:
        'Alat musik tradisional petik dari Pulau Rote, NTT, yang terbuat dari bambu dan anyaman daun lontar adalah...',
    daftarJawaban: ['Sasando', 'Kolintang', 'Angklung', 'Gamelan'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Sasando adalah instrumen musik dawai unik khas Pulau Rote NTT yang menghasilkan resonansi suara merdu melalui wadah daun lontar.',
  ),

  // Tema kuis kedaerahan per provinsi. Soal sementara berlabel
  // [Karangan] pada penjelasannya.
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Aceh',
    tema: 'Kekayaan Aceh',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Aceh?',
    daftarJawaban: ['Banda Aceh', 'Palu', 'Sorong', 'Tanjungpinang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Banda Aceh adalah ibu kota Provinsi Aceh, yang termasuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Aceh',
    tema: 'Kekayaan Aceh',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Aceh '
        'adalah...',
    daftarJawaban: ['TARI SAMAN ACEH', 'CANDI PRAMBANAN', 'CONGKLAK', 'DEBUS'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TARI SAMAN ACEH berasal dari Aceh dan tercatat dalam '
        'arsip Renjana pada kategori tarian tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Aceh',
    tema: 'Kekayaan Aceh',
    soal: 'Provinsi Aceh dikenal dengan julukan...',
    daftarJawaban: [
      'Serambi Mekkah',
      'Bumi Lancang Kuning',
      'Tatar Sunda',
      'Bumi Nyiur Melambai',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan: '[Karangan] Julukan Serambi Mekkah melekat pada Provinsi Aceh.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Aceh',
    tema: 'Kekayaan Aceh',
    soal: 'Provinsi Aceh termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Aceh masuk gugus pulau '
        'Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Utara',
    tema: 'Kekayaan Sumatera Utara',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sumatera Utara?',
    daftarJawaban: ['Medan', 'Kendari', 'Wamena', 'Palembang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Medan adalah ibu kota Provinsi Sumatera Utara, yang '
        'termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Utara',
    tema: 'Kekayaan Sumatera Utara',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sumatera Utara adalah...',
    daftarJawaban: [
      'RUMAH BOLON',
      'Garda Kedaulatan',
      'RENDANG',
      'LEMPAH KUNING',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] RUMAH BOLON berasal dari Sumatera Utara dan tercatat '
        'dalam arsip Renjana pada kategori rumah adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Utara',
    tema: 'Kekayaan Sumatera Utara',
    soal: 'Provinsi Sumatera Utara dikenal dengan julukan...',
    daftarJawaban: [
      'Tanah Batak',
      'Bumi Meepago',
      'Bumi Rafflesia',
      'Kota Pahlawan',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Tanah Batak melekat pada Provinsi Sumatera '
        'Utara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Utara',
    tema: 'Kekayaan Sumatera Utara',
    soal: 'Provinsi Sumatera Utara termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sumatera Utara masuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Barat',
    tema: 'Kekayaan Sumatera Barat',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sumatera Barat?',
    daftarJawaban: ['Padang', 'Tanjung Selor', 'Kupang', 'Banda Aceh'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Padang adalah ibu kota Provinsi Sumatera Barat, yang '
        'termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Barat',
    tema: 'Kekayaan Sumatera Barat',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sumatera Barat adalah...',
    daftarJawaban: [
      'RENDANG',
      'RUMAH RADAKNG',
      'SASANDO',
      'Ikrar Sumpah Pemuda',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] RENDANG berasal dari Sumatera Barat dan tercatat dalam '
        'arsip Renjana pada kategori kuliner tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Barat',
    tema: 'Kekayaan Sumatera Barat',
    soal: 'Provinsi Sumatera Barat dikenal dengan julukan...',
    daftarJawaban: [
      'Ranah Minang',
      'Bumi Benuanta',
      'Bumi Flobamora',
      'Serambi Mekkah',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Ranah Minang melekat pada Provinsi Sumatera '
        'Barat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Barat',
    tema: 'Kekayaan Sumatera Barat',
    soal: 'Provinsi Sumatera Barat termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sumatera Barat masuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Riau',
    tema: 'Kekayaan Riau',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Riau?',
    daftarJawaban: ['Pekanbaru', 'Manado', 'Sofifi', 'Medan'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Pekanbaru adalah ibu kota Provinsi Riau, yang termasuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Riau',
    tema: 'Kekayaan Riau',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Riau '
        'adalah...',
    daftarJawaban: ['TARI ZAPIN', 'NGABEN', 'Garda Kedaulatan', 'RENDANG'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TARI ZAPIN berasal dari Riau dan tercatat dalam arsip '
        'Renjana pada kategori tarian tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Riau',
    tema: 'Kekayaan Riau',
    soal: 'Provinsi Riau dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Lancang Kuning',
      'Jantung Budaya Jawa',
      'Serambi Madinah',
      'Bumi Raja-Raja',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Lancang Kuning melekat pada Provinsi Riau.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Riau',
    tema: 'Kekayaan Riau',
    soal: 'Provinsi Riau termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Riau masuk gugus pulau '
        'Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Riau',
    tema: 'Kekayaan Kepulauan Riau',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kepulauan Riau?',
    daftarJawaban: ['Tanjungpinang', 'Mamuju', 'Manokwari', 'Jambi'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Tanjungpinang adalah ibu kota Provinsi Kepulauan Riau, '
        'yang termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Riau',
    tema: 'Kekayaan Kepulauan Riau',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kepulauan Riau adalah...',
    daftarJawaban: [
      'GAMBUS MELAYU',
      'BENTENG KERATON BUTON',
      'Malam Perumusan Naskah',
      'MASJID RAYA BAITURRAHMAN',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] GAMBUS MELAYU berasal dari Kepulauan Riau dan tercatat '
        'dalam arsip Renjana pada kategori alat musik dan lagu daerah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Riau',
    tema: 'Kekayaan Kepulauan Riau',
    soal: 'Provinsi Kepulauan Riau dikenal dengan julukan...',
    daftarJawaban: [
      'Bunda Tanah Melayu',
      'Bumi Etam',
      'Bumi Gora',
      'Bumi Anim Ha',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bunda Tanah Melayu melekat pada Provinsi '
        'Kepulauan Riau.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Riau',
    tema: 'Kekayaan Kepulauan Riau',
    soal: 'Provinsi Kepulauan Riau termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kepulauan Riau masuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jambi',
    tema: 'Kekayaan Jambi',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Jambi?',
    daftarJawaban: ['Jambi', 'Kendari', 'Wamena', 'Palembang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Jambi adalah ibu kota Provinsi Jambi, yang termasuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jambi',
    tema: 'Kekayaan Jambi',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Jambi '
        'adalah...',
    daftarJawaban: [
      'AKSARA INCUNG',
      'Malam Perumusan Naskah',
      'MASJID RAYA BAITURRAHMAN',
      'PEMPEK',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/1308history.png',
    penjelasan:
        '[Karangan] AKSARA INCUNG berasal dari Jambi dan tercatat dalam '
        'arsip Renjana pada kategori bahasa dan sastra daerah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jambi',
    tema: 'Kekayaan Jambi',
    soal: 'Provinsi Jambi dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Sepucuk Jambi Sembilan Lurah',
      'Tanah Jawara',
      'Bumi Etam',
      'Bumi Gora',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Sepucuk Jambi Sembilan Lurah melekat pada '
        'Provinsi Jambi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jambi',
    tema: 'Kekayaan Jambi',
    soal: 'Provinsi Jambi termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Jambi masuk gugus '
        'pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bengkulu',
    tema: 'Kekayaan Bengkulu',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Bengkulu?',
    daftarJawaban: ['Bengkulu', 'Semarang', 'Gorontalo', 'Ambon'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Bengkulu adalah ibu kota Provinsi Bengkulu, yang '
        'termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bengkulu',
    tema: 'Kekayaan Bengkulu',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Bengkulu adalah...',
    daftarJawaban: ['TABOT', 'RENDANG', 'LEMPAH KUNING', 'NGABEN'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TABOT berasal dari Bengkulu dan tercatat dalam arsip '
        'Renjana pada kategori upacara dan tradisi adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bengkulu',
    tema: 'Kekayaan Bengkulu',
    soal: 'Provinsi Bengkulu dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Rafflesia',
      'Sang Bumi Ruwa Jurai',
      'Bumi Lambung Mangkurat',
      'Pulau Dewata',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Rafflesia melekat pada Provinsi Bengkulu.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bengkulu',
    tema: 'Kekayaan Bengkulu',
    soal: 'Provinsi Bengkulu termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Bengkulu masuk gugus '
        'pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Selatan',
    tema: 'Kekayaan Sumatera Selatan',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sumatera Selatan?',
    daftarJawaban: ['Palembang', 'Jayapura', 'Pangkalpinang', 'Palangka Raya'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Palembang adalah ibu kota Provinsi Sumatera Selatan, '
        'yang termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Selatan',
    tema: 'Kekayaan Sumatera Selatan',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sumatera Selatan adalah...',
    daftarJawaban: [
      'PEMPEK',
      'MASJID RAYA BAITURRAHMAN',
      'TABOT',
      'BENTENG KERATON BUTON',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] PEMPEK berasal dari Sumatera Selatan dan tercatat dalam '
        'arsip Renjana pada kategori kuliner tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Selatan',
    tema: 'Kekayaan Sumatera Selatan',
    soal: 'Provinsi Sumatera Selatan dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Sriwijaya',
      'Tanah Batak',
      'Kota Metropolitan',
      'Bumi Benuanta',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Sriwijaya melekat pada Provinsi Sumatera '
        'Selatan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sumatera Selatan',
    tema: 'Kekayaan Sumatera Selatan',
    soal: 'Provinsi Sumatera Selatan termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sumatera Selatan masuk '
        'gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Bangka Belitung',
    tema: 'Kekayaan Kepulauan Bangka Belitung',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kepulauan Bangka Belitung?',
    daftarJawaban: ['Pangkalpinang', 'Pontianak', 'Makassar', 'Nabire'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Pangkalpinang adalah ibu kota Provinsi Kepulauan Bangka '
        'Belitung, yang termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Bangka Belitung',
    tema: 'Kekayaan Kepulauan Bangka Belitung',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kepulauan Bangka Belitung adalah...',
    daftarJawaban: ['LEMPAH KUNING', 'TARI ZAPIN', 'BILI\\', 'UKIRAN ASMAT'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] LEMPAH KUNING berasal dari Kepulauan Bangka Belitung '
        'dan tercatat dalam arsip Renjana pada kategori kuliner '
        'tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Bangka Belitung',
    tema: 'Kekayaan Kepulauan Bangka Belitung',
    soal: 'Provinsi Kepulauan Bangka Belitung dikenal dengan julukan...',
    daftarJawaban: [
      'Negeri Serumpun Sebalai',
      'Bumi Sepucuk Jambi Sembilan Lurah',
      'Kota Pahlawan',
      'Bumi Malaqbi',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Negeri Serumpun Sebalai melekat pada Provinsi '
        'Kepulauan Bangka Belitung.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kepulauan Bangka Belitung',
    tema: 'Kekayaan Kepulauan Bangka Belitung',
    soal: 'Provinsi Kepulauan Bangka Belitung termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kepulauan Bangka '
        'Belitung masuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Lampung',
    tema: 'Kekayaan Lampung',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Lampung?',
    daftarJawaban: ['Bandar Lampung', 'Semarang', 'Gorontalo', 'Ambon'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Bandar Lampung adalah ibu kota Provinsi Lampung, yang '
        'termasuk gugus pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Lampung',
    tema: 'Kekayaan Lampung',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Lampung '
        'adalah...',
    daftarJawaban: ['KAIN TAPIS', 'NGABEN', 'Garda Kedaulatan', 'RENDANG'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] KAIN TAPIS berasal dari Lampung dan tercatat dalam '
        'arsip Renjana pada kategori pakaian adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Lampung',
    tema: 'Kekayaan Lampung',
    soal: 'Provinsi Lampung dikenal dengan julukan...',
    daftarJawaban: [
      'Sang Bumi Ruwa Jurai',
      'Bunda Tanah Melayu',
      'Kota Pelajar',
      'Bumi Tadulako',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Sang Bumi Ruwa Jurai melekat pada Provinsi '
        'Lampung.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Lampung',
    tema: 'Kekayaan Lampung',
    soal: 'Provinsi Lampung termasuk dalam gugus pulau...',
    daftarJawaban: ['Sumatera', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Lampung masuk gugus '
        'pulau Sumatera.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Banten',
    tema: 'Kekayaan Banten',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Banten?',
    daftarJawaban: ['Serang', 'Jakarta', 'Tanjung Selor', 'Kupang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Serang adalah ibu kota Provinsi Banten, yang termasuk '
        'gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Banten',
    tema: 'Kekayaan Banten',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Banten '
        'adalah...',
    daftarJawaban: [
      'DEBUS',
      'GAMBUS MELAYU',
      'KAIN KULIT KAYU IVO',
      'Detik Proklamasi',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] DEBUS berasal dari Banten dan tercatat dalam arsip '
        'Renjana pada kategori seni pertunjukan dan teater.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Banten',
    tema: 'Kekayaan Banten',
    soal: 'Provinsi Banten dikenal dengan julukan...',
    daftarJawaban: [
      'Tanah Jawara',
      'Bumi Malaqbi',
      'Kota Injil',
      'Bunda Tanah Melayu',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan: '[Karangan] Julukan Tanah Jawara melekat pada Provinsi Banten.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Banten',
    tema: 'Kekayaan Banten',
    soal: 'Provinsi Banten termasuk dalam gugus pulau...',
    daftarJawaban: ['Jawa', 'Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Banten masuk gugus '
        'pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DKI Jakarta',
    tema: 'Kekayaan DKI Jakarta',
    soal: 'Kota apa yang menjadi ibu kota Provinsi DKI Jakarta?',
    daftarJawaban: ['Jakarta', 'Merauke', 'Pangkalpinang', 'Banjarbaru'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Jakarta adalah ibu kota Provinsi DKI Jakarta, yang '
        'termasuk gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DKI Jakarta',
    tema: 'Kekayaan DKI Jakarta',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi DKI '
        'Jakarta adalah...',
    daftarJawaban: ['Detik Proklamasi', 'UKIRAN ASMAT', 'RENDANG', 'TABOT'],
    jawabanBenar: 0,
    gambar: 'assets/images/170845history.png',
    penjelasan:
        '[Karangan] Detik Proklamasi berasal dari DKI Jakarta dan tercatat '
        'dalam arsip Renjana pada kategori sejarah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DKI Jakarta',
    tema: 'Kekayaan DKI Jakarta',
    soal: 'Provinsi DKI Jakarta dikenal dengan julukan...',
    daftarJawaban: [
      'Kota Metropolitan',
      'Bumi Kasuari',
      'Bumi Lancang Kuning',
      'Jantung Budaya Jawa',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Kota Metropolitan melekat pada Provinsi DKI '
        'Jakarta.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DKI Jakarta',
    tema: 'Kekayaan DKI Jakarta',
    soal: 'Provinsi DKI Jakarta termasuk dalam gugus pulau...',
    daftarJawaban: ['Jawa', 'Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, DKI Jakarta masuk '
        'gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Barat',
    tema: 'Kekayaan Jawa Barat',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Jawa Barat?',
    daftarJawaban: ['Bandung', 'Makassar', 'Nabire', 'Jambi'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Bandung adalah ibu kota Provinsi Jawa Barat, yang '
        'termasuk gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Barat',
    tema: 'Kekayaan Jawa Barat',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Jawa '
        'Barat adalah...',
    daftarJawaban: [
      'CONGKLAK',
      'MASJID SULTAN SURIANSYAH',
      'LUKISAN CADAS MISOOL',
      'CANDI PRAMBANAN',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] CONGKLAK berasal dari Jawa Barat dan tercatat dalam '
        'arsip Renjana pada kategori permainan dan olahraga tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Barat',
    tema: 'Kekayaan Jawa Barat',
    soal: 'Provinsi Jawa Barat dikenal dengan julukan...',
    daftarJawaban: [
      'Tatar Sunda',
      'Tanah Batak',
      'Tanah Jawara',
      'Bumi Benuanta',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Tatar Sunda melekat pada Provinsi Jawa Barat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Barat',
    tema: 'Kekayaan Jawa Barat',
    soal: 'Provinsi Jawa Barat termasuk dalam gugus pulau...',
    daftarJawaban: ['Jawa', 'Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Jawa Barat masuk gugus '
        'pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Tengah',
    tema: 'Kekayaan Jawa Tengah',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Jawa Tengah?',
    daftarJawaban: ['Semarang', 'Palu', 'Sorong', 'Pekanbaru'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Semarang adalah ibu kota Provinsi Jawa Tengah, yang '
        'termasuk gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Tengah',
    tema: 'Kekayaan Jawa Tengah',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Jawa '
        'Tengah adalah...',
    daftarJawaban: [
      'BOROBUDUR',
      'PERESEAN',
      'Garda Kedaulatan',
      'MALIN KUNDANG',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/borobudurB.jpg',
    penjelasan:
        '[Karangan] BOROBUDUR berasal dari Jawa Tengah dan tercatat dalam '
        'arsip Renjana pada kategori seni rupa dan kriya.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Tengah',
    tema: 'Kekayaan Jawa Tengah',
    soal: 'Provinsi Jawa Tengah dikenal dengan julukan...',
    daftarJawaban: [
      'Jantung Budaya Jawa',
      'Bumi Raja-Raja',
      'Ranah Minang',
      'Kota Metropolitan',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Jantung Budaya Jawa melekat pada Provinsi Jawa '
        'Tengah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Tengah',
    tema: 'Kekayaan Jawa Tengah',
    soal: 'Provinsi Jawa Tengah termasuk dalam gugus pulau...',
    daftarJawaban: ['Jawa', 'Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Jawa Tengah masuk '
        'gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DI Yogyakarta',
    tema: 'Kekayaan DI Yogyakarta',
    soal: 'Kota apa yang menjadi ibu kota Provinsi DI Yogyakarta?',
    daftarJawaban: ['Yogyakarta', 'Manokwari', 'Tanjungpinang', 'Semarang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Yogyakarta adalah ibu kota Provinsi DI Yogyakarta, yang '
        'termasuk gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DI Yogyakarta',
    tema: 'Kekayaan DI Yogyakarta',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi DI '
        'Yogyakarta adalah...',
    daftarJawaban: [
      'Q-RIS',
      'TARI ZAPIN',
      'TARI JUGIT',
      'LEGENDA DANAU PANIAI',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/kerisB.jpg',
    penjelasan:
        '[Karangan] Q-RIS berasal dari DI Yogyakarta dan tercatat dalam '
        'arsip Renjana pada kategori senjata tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DI Yogyakarta',
    tema: 'Kekayaan DI Yogyakarta',
    soal: 'Provinsi DI Yogyakarta dikenal dengan julukan...',
    daftarJawaban: [
      'Kota Pelajar',
      'Bumi Siri na Pacce',
      'Bumi Meepago',
      'Bumi Sepucuk Jambi Sembilan Lurah',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Kota Pelajar melekat pada Provinsi DI '
        'Yogyakarta.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'DI Yogyakarta',
    tema: 'Kekayaan DI Yogyakarta',
    soal: 'Provinsi DI Yogyakarta termasuk dalam gugus pulau...',
    daftarJawaban: ['Jawa', 'Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, DI Yogyakarta masuk '
        'gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Timur',
    tema: 'Kekayaan Jawa Timur',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Jawa Timur?',
    daftarJawaban: ['Surabaya', 'Pangkalpinang', 'Banjarbaru', 'Denpasar'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Surabaya adalah ibu kota Provinsi Jawa Timur, yang '
        'termasuk gugus pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Timur',
    tema: 'Kekayaan Jawa Timur',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Jawa '
        'Timur adalah...',
    daftarJawaban: [
      'KARAPAN SAPI',
      'PEMPEK',
      'BENTENG KERATON BUTON',
      'Malam Perumusan Naskah',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] KARAPAN SAPI berasal dari Jawa Timur dan tercatat dalam '
        'arsip Renjana pada kategori permainan dan olahraga tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Timur',
    tema: 'Kekayaan Jawa Timur',
    soal: 'Provinsi Jawa Timur dikenal dengan julukan...',
    daftarJawaban: [
      'Kota Pahlawan',
      'Bumi Kasuari',
      'Bumi Lancang Kuning',
      'Tatar Sunda',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Kota Pahlawan melekat pada Provinsi Jawa Timur.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Jawa Timur',
    tema: 'Kekayaan Jawa Timur',
    soal: 'Provinsi Jawa Timur termasuk dalam gugus pulau...',
    daftarJawaban: ['Jawa', 'Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Jawa Timur masuk gugus '
        'pulau Jawa.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Barat',
    tema: 'Kekayaan Kalimantan Barat',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kalimantan Barat?',
    daftarJawaban: ['Pontianak', 'Palangka Raya', 'Kendari', 'Wamena'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Pontianak adalah ibu kota Provinsi Kalimantan Barat, '
        'yang termasuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Barat',
    tema: 'Kekayaan Kalimantan Barat',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kalimantan Barat adalah...',
    daftarJawaban: [
      'RUMAH RADAKNG',
      'Ikrar Sumpah Pemuda',
      'RANDAI',
      'LEMPAH KUNING',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] RUMAH RADAKNG berasal dari Kalimantan Barat dan '
        'tercatat dalam arsip Renjana pada kategori rumah adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Barat',
    tema: 'Kekayaan Kalimantan Barat',
    soal: 'Provinsi Kalimantan Barat dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Khatulistiwa',
      'Bumi Rafflesia',
      'Kota Pahlawan',
      'Bumi Siri na Pacce',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Khatulistiwa melekat pada Provinsi '
        'Kalimantan Barat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Barat',
    tema: 'Kekayaan Kalimantan Barat',
    soal: 'Provinsi Kalimantan Barat termasuk dalam gugus pulau...',
    daftarJawaban: [
      'Kalimantan',
      'Sulawesi',
      'Sumatera',
      'Bali & Nusa Tenggara',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kalimantan Barat masuk '
        'gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Tengah',
    tema: 'Kekayaan Kalimantan Tengah',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kalimantan Tengah?',
    daftarJawaban: ['Palangka Raya', 'Semarang', 'Palu', 'Sorong'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Palangka Raya adalah ibu kota Provinsi Kalimantan '
        'Tengah, yang termasuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Tengah',
    tema: 'Kekayaan Kalimantan Tengah',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kalimantan Tengah adalah...',
    daftarJawaban: ['TIWAH', 'PERESEAN', 'Ikrar Sumpah Pemuda', 'RANDAI'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TIWAH berasal dari Kalimantan Tengah dan tercatat dalam '
        'arsip Renjana pada kategori upacara dan tradisi adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Tengah',
    tema: 'Kekayaan Kalimantan Tengah',
    soal: 'Provinsi Kalimantan Tengah dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Tambun Bungai',
      'Bumi Lapago',
      'Bumi Rafflesia',
      'Kota Pahlawan',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Tambun Bungai melekat pada Provinsi '
        'Kalimantan Tengah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Tengah',
    tema: 'Kekayaan Kalimantan Tengah',
    soal: 'Provinsi Kalimantan Tengah termasuk dalam gugus pulau...',
    daftarJawaban: [
      'Kalimantan',
      'Sulawesi',
      'Sumatera',
      'Bali & Nusa Tenggara',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kalimantan Tengah '
        'masuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Selatan',
    tema: 'Kekayaan Kalimantan Selatan',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kalimantan Selatan?',
    daftarJawaban: ['Banjarbaru', 'Tanjung Selor', 'Kupang', 'Banda Aceh'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Banjarbaru adalah ibu kota Provinsi Kalimantan Selatan, '
        'yang termasuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Selatan',
    tema: 'Kekayaan Kalimantan Selatan',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kalimantan Selatan adalah...',
    daftarJawaban: [
      'MASJID SULTAN SURIANSYAH',
      'KERATON KESULTANAN TERNATE',
      'CANDI PRAMBANAN',
      'PAPEDA',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/borobudurB.jpg',
    penjelasan:
        '[Karangan] MASJID SULTAN SURIANSYAH berasal dari Kalimantan '
        'Selatan dan tercatat dalam arsip Renjana pada kategori situs dan '
        'bangunan bersejarah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Selatan',
    tema: 'Kekayaan Kalimantan Selatan',
    soal: 'Provinsi Kalimantan Selatan dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Lambung Mangkurat',
      'Bumi Siri na Pacce',
      'Bumi Meepago',
      'Bumi Sepucuk Jambi Sembilan Lurah',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Lambung Mangkurat melekat pada Provinsi '
        'Kalimantan Selatan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Selatan',
    tema: 'Kekayaan Kalimantan Selatan',
    soal: 'Provinsi Kalimantan Selatan termasuk dalam gugus pulau...',
    daftarJawaban: [
      'Kalimantan',
      'Sulawesi',
      'Sumatera',
      'Bali & Nusa Tenggara',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kalimantan Selatan '
        'masuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Timur',
    tema: 'Kekayaan Kalimantan Timur',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kalimantan Timur?',
    daftarJawaban: ['Samarinda', 'Palembang', 'Pontianak', 'Kendari'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Samarinda adalah ibu kota Provinsi Kalimantan Timur, '
        'yang termasuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Timur',
    tema: 'Kekayaan Kalimantan Timur',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kalimantan Timur adalah...',
    daftarJawaban: ['MANDAU', 'HONAI', 'WAYANG KULIT PURWA', 'KARAPAN SAPI'],
    jawabanBenar: 0,
    gambar: 'assets/images/kerisB.jpg',
    penjelasan:
        '[Karangan] MANDAU berasal dari Kalimantan Timur dan tercatat dalam '
        'arsip Renjana pada kategori senjata tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Timur',
    tema: 'Kekayaan Kalimantan Timur',
    soal: 'Provinsi Kalimantan Timur dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Etam',
      'Bumi Malaqbi',
      'Kota Injil',
      'Bunda Tanah Melayu',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Etam melekat pada Provinsi Kalimantan '
        'Timur.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Timur',
    tema: 'Kekayaan Kalimantan Timur',
    soal: 'Provinsi Kalimantan Timur termasuk dalam gugus pulau...',
    daftarJawaban: [
      'Kalimantan',
      'Sulawesi',
      'Sumatera',
      'Bali & Nusa Tenggara',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kalimantan Timur masuk '
        'gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Utara',
    tema: 'Kekayaan Kalimantan Utara',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Kalimantan Utara?',
    daftarJawaban: ['Tanjung Selor', 'Mamuju', 'Manokwari', 'Tanjungpinang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Tanjung Selor adalah ibu kota Provinsi Kalimantan '
        'Utara, yang termasuk gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Utara',
    tema: 'Kekayaan Kalimantan Utara',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Kalimantan Utara adalah...',
    daftarJawaban: ['TARI JUGIT', 'NGABEN', 'Garda Kedaulatan', 'RENDANG'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TARI JUGIT berasal dari Kalimantan Utara dan tercatat '
        'dalam arsip Renjana pada kategori tarian tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Utara',
    tema: 'Kekayaan Kalimantan Utara',
    soal: 'Provinsi Kalimantan Utara dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Benuanta',
      'Bumi Tambun Bungai',
      'Pulau Dewata',
      'Bumi Tabi',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Benuanta melekat pada Provinsi Kalimantan '
        'Utara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Kalimantan Utara',
    tema: 'Kekayaan Kalimantan Utara',
    soal: 'Provinsi Kalimantan Utara termasuk dalam gugus pulau...',
    daftarJawaban: [
      'Kalimantan',
      'Sulawesi',
      'Sumatera',
      'Bali & Nusa Tenggara',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Kalimantan Utara masuk '
        'gugus pulau Kalimantan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Utara',
    tema: 'Kekayaan Sulawesi Utara',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sulawesi Utara?',
    daftarJawaban: ['Manado', 'Jakarta', 'Tanjung Selor', 'Sofifi'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Manado adalah ibu kota Provinsi Sulawesi Utara, yang '
        'termasuk gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Utara',
    tema: 'Kekayaan Sulawesi Utara',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sulawesi Utara adalah...',
    daftarJawaban: [
      'TARI KABASARAN',
      'Detik Proklamasi',
      'BENTENG ROTTERDAM',
      'GAMBUS MELAYU',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TARI KABASARAN berasal dari Sulawesi Utara dan tercatat '
        'dalam arsip Renjana pada kategori tarian tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Utara',
    tema: 'Kekayaan Sulawesi Utara',
    soal: 'Provinsi Sulawesi Utara dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Nyiur Melambai',
      'Bumi Anim Ha',
      'Negeri Serumpun Sebalai',
      'Bumi Tambun Bungai',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Nyiur Melambai melekat pada Provinsi '
        'Sulawesi Utara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Utara',
    tema: 'Kekayaan Sulawesi Utara',
    soal: 'Provinsi Sulawesi Utara termasuk dalam gugus pulau...',
    daftarJawaban: ['Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara', 'Jawa'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sulawesi Utara masuk '
        'gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Gorontalo',
    tema: 'Kekayaan Gorontalo',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Gorontalo?',
    daftarJawaban: ['Gorontalo', 'Jambi', 'Yogyakarta', 'Mamuju'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Gorontalo adalah ibu kota Provinsi Gorontalo, yang '
        'termasuk gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Gorontalo',
    tema: 'Kekayaan Gorontalo',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Gorontalo adalah...',
    daftarJawaban: ['BILI\\', 'TARI ZAPIN', 'TARI KABASARAN', 'UKIRAN ASMAT'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] BILI\\ berasal dari Gorontalo dan tercatat dalam arsip '
        'Renjana pada kategori pakaian adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Gorontalo',
    tema: 'Kekayaan Gorontalo',
    soal: 'Provinsi Gorontalo dikenal dengan julukan...',
    daftarJawaban: [
      'Serambi Madinah',
      'Tatar Sunda',
      'Bumi Nyiur Melambai',
      'Bumi Raja-Raja',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Serambi Madinah melekat pada Provinsi '
        'Gorontalo.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Gorontalo',
    tema: 'Kekayaan Gorontalo',
    soal: 'Provinsi Gorontalo termasuk dalam gugus pulau...',
    daftarJawaban: ['Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara', 'Jawa'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Gorontalo masuk gugus '
        'pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tengah',
    tema: 'Kekayaan Sulawesi Tengah',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sulawesi Tengah?',
    daftarJawaban: ['Palu', 'Gorontalo', 'Sorong', 'Pekanbaru'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Palu adalah ibu kota Provinsi Sulawesi Tengah, yang '
        'termasuk gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tengah',
    tema: 'Kekayaan Sulawesi Tengah',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sulawesi Tengah adalah...',
    daftarJawaban: [
      'KAIN KULIT KAYU IVO',
      'PAPEDA',
      'DEBUS',
      'KERATON KESULTANAN TERNATE',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] KAIN KULIT KAYU IVO berasal dari Sulawesi Tengah dan '
        'tercatat dalam arsip Renjana pada kategori seni rupa dan kriya.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tengah',
    tema: 'Kekayaan Sulawesi Tengah',
    soal: 'Provinsi Sulawesi Tengah dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Tadulako',
      'Serambi Madinah',
      'Bumi Kasuari',
      'Bumi Lancang Kuning',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Tadulako melekat pada Provinsi Sulawesi '
        'Tengah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tengah',
    tema: 'Kekayaan Sulawesi Tengah',
    soal: 'Provinsi Sulawesi Tengah termasuk dalam gugus pulau...',
    daftarJawaban: ['Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara', 'Jawa'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sulawesi Tengah masuk '
        'gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Barat',
    tema: 'Kekayaan Sulawesi Barat',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sulawesi Barat?',
    daftarJawaban: ['Mamuju', 'Pontianak', 'Kendari', 'Wamena'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Mamuju adalah ibu kota Provinsi Sulawesi Barat, yang '
        'termasuk gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Barat',
    tema: 'Kekayaan Sulawesi Barat',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sulawesi Barat adalah...',
    daftarJawaban: ['RUMAH BOYANG', 'TIFA', 'BADIK SULAWESI', 'RUMAH BOLON'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] RUMAH BOYANG berasal dari Sulawesi Barat dan tercatat '
        'dalam arsip Renjana pada kategori rumah adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Barat',
    tema: 'Kekayaan Sulawesi Barat',
    soal: 'Provinsi Sulawesi Barat dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Malaqbi',
      'Pulau Dewata',
      'Bumi Tabi',
      'Bumi Sriwijaya',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Malaqbi melekat pada Provinsi Sulawesi '
        'Barat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Barat',
    tema: 'Kekayaan Sulawesi Barat',
    soal: 'Provinsi Sulawesi Barat termasuk dalam gugus pulau...',
    daftarJawaban: ['Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara', 'Jawa'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sulawesi Barat masuk '
        'gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tenggara',
    tema: 'Kekayaan Sulawesi Tenggara',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Sulawesi Tenggara?',
    daftarJawaban: ['Kendari', 'Serang', 'Samarinda', 'Kupang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Kendari adalah ibu kota Provinsi Sulawesi Tenggara, '
        'yang termasuk gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tenggara',
    tema: 'Kekayaan Sulawesi Tenggara',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi '
        'Sulawesi Tenggara adalah...',
    daftarJawaban: ['BENTENG KERATON BUTON', 'KARAPAN SAPI', 'MANDAU', 'HONAI'],
    jawabanBenar: 0,
    gambar: 'assets/images/borobudurB.jpg',
    penjelasan:
        '[Karangan] BENTENG KERATON BUTON berasal dari Sulawesi Tenggara '
        'dan tercatat dalam arsip Renjana pada kategori situs dan bangunan '
        'bersejarah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tenggara',
    tema: 'Kekayaan Sulawesi Tenggara',
    soal: 'Provinsi Sulawesi Tenggara dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Anoa',
      'Tatar Sunda',
      'Bumi Nyiur Melambai',
      'Bumi Raja-Raja',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Anoa melekat pada Provinsi Sulawesi '
        'Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Sulawesi Tenggara',
    tema: 'Kekayaan Sulawesi Tenggara',
    soal: 'Provinsi Sulawesi Tenggara termasuk dalam gugus pulau...',
    daftarJawaban: ['Sulawesi', 'Sumatera', 'Bali & Nusa Tenggara', 'Jawa'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Sulawesi Tenggara '
        'masuk gugus pulau Sulawesi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bali',
    tema: 'Kekayaan Bali',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Bali?',
    daftarJawaban: ['Denpasar', 'Pontianak', 'Makassar', 'Wamena'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Denpasar adalah ibu kota Provinsi Bali, yang termasuk '
        'gugus pulau Bali & Nusa Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bali',
    tema: 'Kekayaan Bali',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Bali '
        'adalah...',
    daftarJawaban: [
      'NGABEN',
      'TONGKONAN TORAJA',
      'TARI ZAPIN',
      'TARI KABASARAN',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] NGABEN berasal dari Bali dan tercatat dalam arsip '
        'Renjana pada kategori upacara dan tradisi adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bali',
    tema: 'Kekayaan Bali',
    soal: 'Provinsi Bali dikenal dengan julukan...',
    daftarJawaban: [
      'Pulau Dewata',
      'Bumi Moloku Kie Raha',
      'Tanah Batak',
      'Tanah Jawara',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan: '[Karangan] Julukan Pulau Dewata melekat pada Provinsi Bali.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Bali',
    tema: 'Kekayaan Bali',
    soal: 'Provinsi Bali termasuk dalam gugus pulau...',
    daftarJawaban: ['Bali & Nusa Tenggara', 'Kalimantan', 'Maluku', 'Papua'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Bali masuk gugus pulau '
        'Bali & Nusa Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Barat',
    tema: 'Kekayaan Nusa Tenggara Barat',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Nusa Tenggara Barat?',
    daftarJawaban: ['Mataram', 'Banda Aceh', 'Bandar Lampung', 'Banjarbaru'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Mataram adalah ibu kota Provinsi Nusa Tenggara Barat, '
        'yang termasuk gugus pulau Bali & Nusa Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Barat',
    tema: 'Kekayaan Nusa Tenggara Barat',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Nusa '
        'Tenggara Barat adalah...',
    daftarJawaban: ['PERESEAN', 'SANGKURIANG', 'TIWAH', 'TARI YOSPAN'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] PERESEAN berasal dari Nusa Tenggara Barat dan tercatat '
        'dalam arsip Renjana pada kategori permainan dan olahraga '
        'tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Barat',
    tema: 'Kekayaan Nusa Tenggara Barat',
    soal: 'Provinsi Nusa Tenggara Barat dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Gora',
      'Serambi Mekkah',
      'Sang Bumi Ruwa Jurai',
      'Bumi Lambung Mangkurat',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Gora melekat pada Provinsi Nusa Tenggara '
        'Barat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Barat',
    tema: 'Kekayaan Nusa Tenggara Barat',
    soal: 'Provinsi Nusa Tenggara Barat termasuk dalam gugus pulau...',
    daftarJawaban: ['Bali & Nusa Tenggara', 'Kalimantan', 'Maluku', 'Papua'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Nusa Tenggara Barat '
        'masuk gugus pulau Bali & Nusa Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Timur',
    tema: 'Kekayaan Nusa Tenggara Timur',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Nusa Tenggara Timur?',
    daftarJawaban: ['Kupang', 'Wamena', 'Bengkulu', 'Surabaya'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Kupang adalah ibu kota Provinsi Nusa Tenggara Timur, '
        'yang termasuk gugus pulau Bali & Nusa Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Timur',
    tema: 'Kekayaan Nusa Tenggara Timur',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Nusa '
        'Tenggara Timur adalah...',
    daftarJawaban: [
      'SASANDO',
      'LEMPAH KUNING',
      'NGABEN',
      'Ikrar Sumpah Pemuda',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] SASANDO berasal dari Nusa Tenggara Timur dan tercatat '
        'dalam arsip Renjana pada kategori alat musik dan lagu daerah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Timur',
    tema: 'Kekayaan Nusa Tenggara Timur',
    soal: 'Provinsi Nusa Tenggara Timur dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Flobamora',
      'Tatar Sunda',
      'Bumi Nyiur Melambai',
      'Bumi Raja-Raja',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Flobamora melekat pada Provinsi Nusa '
        'Tenggara Timur.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Nusa Tenggara Timur',
    tema: 'Kekayaan Nusa Tenggara Timur',
    soal: 'Provinsi Nusa Tenggara Timur termasuk dalam gugus pulau...',
    daftarJawaban: ['Bali & Nusa Tenggara', 'Kalimantan', 'Maluku', 'Papua'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Nusa Tenggara Timur '
        'masuk gugus pulau Bali & Nusa Tenggara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku Utara',
    tema: 'Kekayaan Maluku Utara',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Maluku Utara?',
    daftarJawaban: ['Sofifi', 'Kendari', 'Jayapura', 'Palembang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Sofifi adalah ibu kota Provinsi Maluku Utara, yang '
        'termasuk gugus pulau Maluku.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku Utara',
    tema: 'Kekayaan Maluku Utara',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Maluku '
        'Utara adalah...',
    daftarJawaban: [
      'KERATON KESULTANAN TERNATE',
      'TARI ZAPIN',
      'TARI KABASARAN',
      'UKIRAN ASMAT',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/borobudurB.jpg',
    penjelasan:
        '[Karangan] KERATON KESULTANAN TERNATE berasal dari Maluku Utara '
        'dan tercatat dalam arsip Renjana pada kategori situs dan bangunan '
        'bersejarah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku Utara',
    tema: 'Kekayaan Maluku Utara',
    soal: 'Provinsi Maluku Utara dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Moloku Kie Raha',
      'Kota Pahlawan',
      'Bumi Malaqbi',
      'Bumi Meepago',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Moloku Kie Raha melekat pada Provinsi '
        'Maluku Utara.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku Utara',
    tema: 'Kekayaan Maluku Utara',
    soal: 'Provinsi Maluku Utara termasuk dalam gugus pulau...',
    daftarJawaban: ['Maluku', 'Kalimantan', 'Papua', 'Sulawesi'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Maluku Utara masuk '
        'gugus pulau Maluku.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku',
    tema: 'Kekayaan Maluku',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Maluku?',
    daftarJawaban: ['Ambon', 'Manado', 'Sofifi', 'Padang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Ambon adalah ibu kota Provinsi Maluku, yang termasuk '
        'gugus pulau Maluku.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku',
    tema: 'Kekayaan Maluku',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Maluku '
        'adalah...',
    daftarJawaban: ['PAPEDA', 'SASANDO', 'Q-RIS', 'MALIN KUNDANG'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] PAPEDA berasal dari Maluku dan tercatat dalam arsip '
        'Renjana pada kategori kuliner tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku',
    tema: 'Kekayaan Maluku',
    soal: 'Provinsi Maluku dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Raja-Raja',
      'Tatar Sunda',
      'Bumi Nyiur Melambai',
      'Bumi Moloku Kie Raha',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Raja-Raja melekat pada Provinsi Maluku.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Maluku',
    tema: 'Kekayaan Maluku',
    soal: 'Provinsi Maluku termasuk dalam gugus pulau...',
    daftarJawaban: ['Maluku', 'Kalimantan', 'Papua', 'Sulawesi'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Maluku masuk gugus '
        'pulau Maluku.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat Daya',
    tema: 'Kekayaan Papua Barat Daya',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Papua Barat Daya?',
    daftarJawaban: ['Sorong', 'Jayapura', 'Palembang', 'Pontianak'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Sorong adalah ibu kota Provinsi Papua Barat Daya, yang '
        'termasuk gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat Daya',
    tema: 'Kekayaan Papua Barat Daya',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Papua '
        'Barat Daya adalah...',
    daftarJawaban: [
      'LUKISAN CADAS MISOOL',
      'KAIN KULIT KAYU IVO',
      'Runtuhnya Tirani',
      'TARI SAMAN ACEH',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/borobudurB.jpg',
    penjelasan:
        '[Karangan] LUKISAN CADAS MISOOL berasal dari Papua Barat Daya dan '
        'tercatat dalam arsip Renjana pada kategori situs dan bangunan '
        'bersejarah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat Daya',
    tema: 'Kekayaan Papua Barat Daya',
    soal: 'Provinsi Papua Barat Daya dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Kasuari',
      'Bumi Rafflesia',
      'Kota Pahlawan',
      'Bumi Malaqbi',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Kasuari melekat pada Provinsi Papua Barat '
        'Daya.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat Daya',
    tema: 'Kekayaan Papua Barat Daya',
    soal: 'Provinsi Papua Barat Daya termasuk dalam gugus pulau...',
    daftarJawaban: ['Papua', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Papua Barat Daya masuk '
        'gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat',
    tema: 'Kekayaan Papua Barat',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Papua Barat?',
    daftarJawaban: ['Manokwari', 'Kupang', 'Medan', 'Serang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Manokwari adalah ibu kota Provinsi Papua Barat, yang '
        'termasuk gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat',
    tema: 'Kekayaan Papua Barat',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Papua '
        'Barat adalah...',
    daftarJawaban: [
      'TARI YOSPAN',
      'LUKISAN CADAS MISOOL',
      'BOROBUDUR',
      'SANGKURIANG',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin3.jpg',
    penjelasan:
        '[Karangan] TARI YOSPAN berasal dari Papua Barat dan tercatat dalam '
        'arsip Renjana pada kategori tarian tradisional.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat',
    tema: 'Kekayaan Papua Barat',
    soal: 'Provinsi Papua Barat dikenal dengan julukan...',
    daftarJawaban: [
      'Kota Injil',
      'Bumi Moloku Kie Raha',
      'Ranah Minang',
      'Kota Metropolitan',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Kota Injil melekat pada Provinsi Papua Barat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Barat',
    tema: 'Kekayaan Papua Barat',
    soal: 'Provinsi Papua Barat termasuk dalam gugus pulau...',
    daftarJawaban: ['Papua', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Papua Barat masuk '
        'gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Tengah',
    tema: 'Kekayaan Papua Tengah',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Papua Tengah?',
    daftarJawaban: ['Nabire', 'Surabaya', 'Mamuju', 'Manokwari'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Nabire adalah ibu kota Provinsi Papua Tengah, yang '
        'termasuk gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Tengah',
    tema: 'Kekayaan Papua Tengah',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Papua '
        'Tengah adalah...',
    daftarJawaban: [
      'LEGENDA DANAU PANIAI',
      'TONGKONAN TORAJA',
      'TARI ZAPIN',
      'TARI KABASARAN',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/1308history.png',
    penjelasan:
        '[Karangan] LEGENDA DANAU PANIAI berasal dari Papua Tengah dan '
        'tercatat dalam arsip Renjana pada kategori cerita rakyat dan '
        'mitologi.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Tengah',
    tema: 'Kekayaan Papua Tengah',
    soal: 'Provinsi Papua Tengah dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Meepago',
      'Bumi Lapago',
      'Bumi Rafflesia',
      'Kota Pahlawan',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Meepago melekat pada Provinsi Papua '
        'Tengah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Tengah',
    tema: 'Kekayaan Papua Tengah',
    soal: 'Provinsi Papua Tengah termasuk dalam gugus pulau...',
    daftarJawaban: ['Papua', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Papua Tengah masuk '
        'gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Pegunungan',
    tema: 'Kekayaan Papua Pegunungan',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Papua Pegunungan?',
    daftarJawaban: ['Wamena', 'Kendari', 'Jayapura', 'Palembang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Wamena adalah ibu kota Provinsi Papua Pegunungan, yang '
        'termasuk gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Pegunungan',
    tema: 'Kekayaan Papua Pegunungan',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Papua '
        'Pegunungan adalah...',
    daftarJawaban: [
      'HONAI',
      'RUMAH BOYANG',
      'Malam Perumusan Naskah',
      'MASJID RAYA BAITURRAHMAN',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        '[Karangan] HONAI berasal dari Papua Pegunungan dan tercatat dalam '
        'arsip Renjana pada kategori rumah adat.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Pegunungan',
    tema: 'Kekayaan Papua Pegunungan',
    soal: 'Provinsi Papua Pegunungan dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Lapago',
      'Bumi Lambung Mangkurat',
      'Pulau Dewata',
      'Bumi Anim Ha',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Lapago melekat pada Provinsi Papua '
        'Pegunungan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Pegunungan',
    tema: 'Kekayaan Papua Pegunungan',
    soal: 'Provinsi Papua Pegunungan termasuk dalam gugus pulau...',
    daftarJawaban: ['Papua', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Papua Pegunungan masuk '
        'gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua',
    tema: 'Kekayaan Papua',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Papua?',
    daftarJawaban: ['Jayapura', 'Bandar Lampung', 'Banjarbaru', 'Denpasar'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Jayapura adalah ibu kota Provinsi Papua, yang termasuk '
        'gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua',
    tema: 'Kekayaan Papua',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Papua '
        'adalah...',
    daftarJawaban: ['TIFA', 'WAYANG KULIT PURWA', 'KARAPAN SAPI', 'MANDAU'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] TIFA berasal dari Papua dan tercatat dalam arsip '
        'Renjana pada kategori alat musik dan lagu daerah.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua',
    tema: 'Kekayaan Papua',
    soal: 'Provinsi Papua dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Tabi',
      'Bumi Tambun Bungai',
      'Bumi Anoa',
      'Bumi Lapago',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan: '[Karangan] Julukan Bumi Tabi melekat pada Provinsi Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua',
    tema: 'Kekayaan Papua',
    soal: 'Provinsi Papua termasuk dalam gugus pulau...',
    daftarJawaban: ['Papua', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Papua masuk gugus '
        'pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Selatan',
    tema: 'Kekayaan Papua Selatan',
    soal: 'Kota apa yang menjadi ibu kota Provinsi Papua Selatan?',
    daftarJawaban: ['Merauke', 'Manado', 'Sofifi', 'Padang'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Merauke adalah ibu kota Provinsi Papua Selatan, yang '
        'termasuk gugus pulau Papua.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Selatan',
    tema: 'Kekayaan Papua Selatan',
    soal:
        'Warisan budaya berikut yang tercatat berasal dari Provinsi Papua '
        'Selatan adalah...',
    daftarJawaban: [
      'UKIRAN ASMAT',
      'TIWAH',
      'LUKISAN CADAS MISOOL',
      'BOROBUDUR',
    ],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin2.jpg',
    penjelasan:
        '[Karangan] UKIRAN ASMAT berasal dari Papua Selatan dan tercatat '
        'dalam arsip Renjana pada kategori seni rupa dan kriya.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Selatan',
    tema: 'Kekayaan Papua Selatan',
    soal: 'Provinsi Papua Selatan dikenal dengan julukan...',
    daftarJawaban: [
      'Bumi Anim Ha',
      'Bumi Lapago',
      'Bumi Sriwijaya',
      'Bumi Khatulistiwa',
    ],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Julukan Bumi Anim Ha melekat pada Provinsi Papua '
        'Selatan.',
  ),
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
    subKategori: 'Papua Selatan',
    tema: 'Kekayaan Papua Selatan',
    soal: 'Provinsi Papua Selatan termasuk dalam gugus pulau...',
    daftarJawaban: ['Papua', 'Jawa', 'Kalimantan', 'Maluku'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        '[Karangan] Dalam pembagian wilayah Renjana, Papua Selatan masuk '
        'gugus pulau Papua.',
  ),
];

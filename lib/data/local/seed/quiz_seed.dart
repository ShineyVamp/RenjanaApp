// Bank soal awal yang diisikan ke tabel `quiz` saat database pertama
// kali dibuat. Bukan sumber data runtime: aplikasi membaca lewat
// QuizRepository.
import '../../models/quiz_model.dart';

final List<QuizSQLModel> defaultQuizList = [
  // ==========================================
  // SEJARAH - Tema: Perjalanan Revolusi
  // ==========================================
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

  // ==========================================
  // SEJARAH - Tema: Detik-Detik Kemerdekaan
  // ==========================================
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

  // ==========================================
  // BUDAYA - Tema: Cagar Budaya & Arsitektur
  // ==========================================
  QuizSQLModel(
    kategori: 'BUDAYA',
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
    tema: 'Cagar Budaya & Arsitektur',
    soal:
        'Rumah adat khas masyarakat suku Toraja yang beratap melengkung seperti haluan perahu dinamakan...',
    daftarJawaban: ['Tongkonan', 'Rumah Gadang', 'Joglo', 'Honai'],
    jawabanBenar: 0,
    gambar: 'assets/images/onboardin1.jpg',
    penjelasan:
        'Tongkonan adalah rumah adat suku Toraja yang berfungsi sebagai pusat kehidupan sosial dan ritual keluarga adat Toraja.',
  ),

  // ==========================================
  // BUDAYA - Tema: Tradisi & Mahakarya Leluhur
  // ==========================================
  QuizSQLModel(
    kategori: 'BUDAYA',
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

  // ==========================================
  // KEDAERAHAN - Tema: Kekayaan Sulawesi Selatan
  // ==========================================
  QuizSQLModel(
    kategori: 'KEDAERAHAN',
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
    tema: 'Kekayaan Sulawesi Selatan',
    soal:
        'Kuliner sup khas Makassar dengan kuah pekat berempah dan kacang tanah gurih adalah...',
    daftarJawaban: ['Coto Makassar', 'Rawon', 'Soto Betawi', 'Sop Saudara'],
    jawabanBenar: 0,
    gambar: null,
    penjelasan:
        'Coto Makassar dimasak menggunakan lebih dari 40 jenis rempah (Rampa Patangpulo) dan biasa disantap bersama ketupat.',
  ),

  // ==========================================
  // KEDAERAHAN - Tema: Pesona Nusantara
  // ==========================================
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
];

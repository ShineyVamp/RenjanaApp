// Data awal untuk tabel `budaya`, dipakai sekali saat database dibuat.
import 'package:renjana/features/budaya/data/models/budaya_model.dart';

final List<BudayaModel> defaultBudayaList = [
  const BudayaModel(
    kodeTag: 'BUD-SNJT-1',
    provinsi: 'DI Yogyakarta',
    jenis: 'SNJT',
    urutan: 1,
    judul: 'Q-RIS',
    kategoriLabel: 'SENJATA TRADISIONAL',
    tagline:
        'Sebilah logam yang menyimpan wibawa, dan garis leluhur pemiliknya.',
    deskripsi:
        'Lebih dari sekadar senjata, keris adalah mahakarya seni tempa, perwujudan '
        'doa, dan simbol identitas kultural yang mendalam. Pola pamornya '
        'mengisahkan filsafat alam semesta.',
    gambarUtama: 'assets/images/kerisB.jpg',
    maknaSpiritual:
        'Bagi masyarakat Nusantara, keris diyakini menyimpan kekuatan spiritual '
        'yang disebut tuah. Sebilah keris pusaka sering dirawat lewat ritual '
        'jamasan (pembersihan pusaka) setiap bulan Sura.',
    gambarMaknaSpiritual: 'assets/images/kerisB.jpg',
    konteksBudaya:
        'Dalam kehidupan tradisional Jawa dan Nusantara, keris menyertai berbagai '
        'peristiwa penting: dikenakan pengantin pria saat upacara adat pernikahan, '
        'hingga menjadi pusaka keluarga turun-temurun.',
    gambarKonteksBudaya: null,
  ),
  const BudayaModel(
    kodeTag: 'BUD-SRK-1-D',
    provinsi: 'Jawa Tengah',
    jenis: 'SRK',
    urutan: 1,
    judul: 'BOROBUDUR',
    kategoriLabel: 'SENI RUPA DAN KRIYA',
    tagline:
        'Monumen keagungan wangsa Syailendra di hamparan perbukitan Menoreh.',
    deskripsi:
        'Candi Borobudur merupakan mahakarya arsitektur batu terbesar di dunia '
        'yang dibangun pada abad ke-8. Ribuan panel relief memuat ajaran kehidupan '
        'dan filosofi pencapaian spiritual manusia.',
    gambarUtama: 'assets/images/borobudurB.jpg',
    maknaSpiritual:
        'Tiga tingkatan candi (Kamadhatu, Rupadhatu, dan Arupadhatu) melambangkan '
        'perjalanan spiritual pelepasan nafsu duniawi menuju pencerahan murni.',
    gambarMaknaSpiritual: 'assets/images/borobudurB.jpg',
    konteksBudaya:
        'Hingga kini, Borobudur menjadi simbol harmoni toleransi bangsa dan '
        'pusat perayaan Hari Raya Waisak berskala internasional.',
    gambarKonteksBudaya: null,
  ),
  const BudayaModel(
    kodeTag: 'BUD-SNJT-2',
    provinsi: 'Sulawesi Selatan',
    jenis: 'SNJT',
    urutan: 2,
    judul: 'BADIK SULAWESI',
    kategoriLabel: 'SENJATA TRADISIONAL',
    tagline:
        'Simbol keteguhan, kehormatan, dan pertahanan diri tanah Bugis-Makassar.',
    deskripsi:
        'Badik adalah pusaka tradisional masyarakat Bugis, Makassar, dan Mandar '
        'yang melambangkan harga diri (siri’ na pacce) serta keberanian dalam '
        'menjaga kedaulatan tanah leluhur.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual:
        'Pola pamor pada bilah badik dipercaya membawa tuah keselamatan, rezeki, '
        'dan wibawa kepemimpinan bagi sang pemilik.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Badik selalu diselipkan di pinggang kiri sebagai kelengkapan busana '
        'adat pria Bugis-Makassar dalam upacara-upacara resmi kebudayaan.',
    gambarKonteksBudaya: null,
  ),
  const BudayaModel(
    kodeTag: 'BUD-TRN-1',
    provinsi: 'Aceh',
    jenis: 'TRN',
    urutan: 1,
    judul: 'TARI SAMAN ACEH',
    kategoriLabel: 'TARIAN TRADISIONAL',
    tagline:
        'Harmoni gerak tepuk tangan serempak berkecepatan tinggi warisan Gayo.',
    deskripsi:
        'Tari Saman adalah tarian tradisional suku Gayo di Aceh yang dinobatkan '
        'sebagai Warisan Budaya Takbenda UNESCO. Menampilkan kekompakan dan '
        'pesan-pesan moral religius.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual:
        'Irama tepuk dada dan lantunan syair berisi doa keselamatan dan puji-pujian.',
    gambarMaknaSpiritual: 'assets/images/onboardin3.jpg',
    konteksBudaya:
        'Dipertunjukkan dalam perayaan hari-hari besar keagamaan dan penyambutan tamu agung.',
    gambarKonteksBudaya: null,
  ),
  const BudayaModel(
    kodeTag: 'BUD-RMH-1-D',
    provinsi: 'Sulawesi Selatan',
    jenis: 'RMH',
    urutan: 1,
    judul: 'TONGKONAN TORAJA',
    kategoriLabel: 'RUMAH ADAT',
    tagline:
        'Rumah adat berbentuk perahu simbol hubungan kosmis leluhur Toraja.',
    deskripsi:
        'Tongkonan adalah rumah adat masyarakat Toraja dengan atap melengkung '
        'menyerupai perahu serta ukiran kayu penuh makna filosofi persaudaraan.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual:
        'Orientasi rumah menghadap ke utara sebagai lambang asal mula kehidupan leluhur Puang Matua.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Pusat kegiatan upacara adat Rambu Solo (pemakaman) dan Rambu Tuka (syukuran).',
    gambarKonteksBudaya: null,
  ),
  const BudayaModel(
    kodeTag: 'BUD-MSK-1',
    provinsi: 'Jawa Tengah',
    jenis: 'MSK',
    urutan: 1,
    judul: 'GAMELAN JAWA',
    kategoriLabel: 'ALAT MUSIK DAN LAGU DAERAH',
    tagline: 'Ansambel musik perkusi tembaga pembawa ketenangan jiwa.',
    deskripsi:
        'Gamelan adalah orkestra tradisional Jawa dan Bali yang memadukan '
        'gong, kenong, saron, dan kendang dalam tangga nada pelog dan slendro.',
    gambarUtama: 'assets/images/1308history.png',
    maknaSpiritual:
        'Penyelarasan nada mengajarkan harmoni antara manusia, alam, dan Sang Pencipta.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Pengiring pagelaran wayang kulit, tarian keraton, dan upacara adat sekaten.',
    gambarKonteksBudaya: null,
  ),

  // Situs dan Bangunan Bersejarah
  const BudayaModel(
    kodeTag: 'BUD-SIT-1-D',
    provinsi: 'DI Yogyakarta',
    jenis: 'SIT',
    urutan: 1,
    judul: 'CANDI PRAMBANAN',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Kompleks candi Hindu terbesar di Indonesia, menjulang ramping '
        'ke langit Jawa.',
    deskripsi:
        'Prambanan adalah mahakarya arsitektur Hindu abad ke-9 dengan candi '
        'utama Siwa setinggi 47 meter. Dindingnya dipahat relief Ramayana '
        'yang dibaca searah jarum jam mengelilingi pelataran.',
    gambarUtama: 'assets/images/borobudurB.jpg',
    maknaSpiritual:
        'Tiga candi utama melambangkan Trimurti — Brahma sang pencipta, Wisnu '
        'sang pemelihara, dan Siwa sang pelebur — dengan Siwa di tengah '
        'sebagai penanda pemujaan utama masyarakat Mataram Kuno.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Setiap musim kemarau, pelataran candi menjadi panggung Sendratari '
        'Ramayana dengan latar candi yang disorot lampu.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': 'Sekitar 856 Masehi',
      'pendiri': 'Rakai Pikatan dari Wangsa Sanjaya',
      'gayaArsitektur': 'Candi Hindu Jawa Tengah bercorak Siwaistis',
      'fungsiAsli':
          'Candi kerajaan sekaligus tempat pemujaan Siwa Mahadewa dan '
          'penyimpanan abu jenazah raja-raja Mataram Kuno.',
      'kondisiSekarang':
          'Ditetapkan sebagai Situs Warisan Dunia UNESCO pada 1991. Sebagian '
          'candi perwara masih berupa tumpukan batu yang menunggu '
          'pemugaran.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SIT-2-D',
    provinsi: 'Sulawesi Selatan',
    jenis: 'SIT',
    urutan: 2,
    judul: 'BENTENG ROTTERDAM',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Benteng Gowa berbentuk penyu yang menyimpan luka Perjanjian '
        'Bongaya.',
    deskripsi:
        'Benteng Ujung Pandang dibangun Kerajaan Gowa menghadap Selat '
        'Makassar. Setelah kalah perang, benteng ini diserahkan kepada VOC '
        'dan dibangun ulang dengan nama Rotterdam.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Di salah satu selnya, Pangeran Diponegoro menjalani pengasingan '
        'selama 26 tahun hingga wafat pada 1855.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': '1545, dibangun ulang 1667',
      'pendiri': 'Raja Gowa IX Tunipalangga Ulaweng',
      'gayaArsitektur':
          'Benteng Gowa dari batu padas, direnovasi bergaya kolonial Belanda',
      'fungsiAsli':
          'Pertahanan pesisir Kerajaan Gowa, lalu berubah menjadi pusat '
          'pemerintahan dan gudang rempah VOC.',
      'kondisiSekarang':
          'Terawat baik dan menjadi kompleks Museum La Galigo yang menyimpan '
          'naskah serta koleksi budaya Sulawesi Selatan.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SIT-3-D',
    provinsi: 'Aceh',
    jenis: 'SIT',
    urutan: 3,
    judul: 'MASJID RAYA BAITURRAHMAN',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Kubah hitam yang bertahan saat gelombang tsunami meratakan '
        'Banda Aceh.',
    deskripsi:
        'Masjid kebanggaan Kesultanan Aceh Darussalam dengan tujuh kubah dan '
        'menara menjulang. Bangunannya menjadi saksi perang, kemerdekaan, '
        'hingga bencana besar 2004.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual:
        'Bagi warga Aceh, masjid ini bukan sekadar tempat ibadah melainkan '
        'lambang ketahanan iman yang tetap berdiri ketika kota di sekitarnya '
        'hancur.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Saat tsunami 26 Desember 2004, masjid ini menjadi tempat berlindung '
        'ribuan warga dan kemudian posko pengungsian utama.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': '1612, dibangun kembali 1881',
      'pendiri': 'Sultan Iskandar Muda',
      'gayaArsitektur': 'Perpaduan Mughal dan Moor dengan kubah hitam',
      'fungsiAsli':
          'Masjid kesultanan sekaligus pusat pendidikan agama dan pertemuan '
          'para ulama Aceh.',
      'kondisiSekarang':
          'Masih aktif digunakan dan telah diperluas dengan payung elektrik '
          'di pelataran menyerupai Masjid Nabawi.',
    },
  ),

  // Kuliner Tradisional
  const BudayaModel(
    kodeTag: 'BUD-KLN-1',
    provinsi: 'Sumatera Barat',
    jenis: 'KLN',
    urutan: 1,
    judul: 'RENDANG',
    kategoriLabel: 'KULINER TRADISIONAL',
    tagline:
        'Masakan yang dimasak berjam-jam hingga santan berubah menjadi '
        'minyak dan bumbu.',
    deskripsi:
        'Rendang adalah olahan daging khas Minangkabau yang dimasak perlahan '
        'dalam santan dan rempah sampai kering. Proses panjang itu membuatnya '
        'awet berminggu-minggu tanpa pendingin, bekal ideal bagi perantau.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Dalam adat Minang, rendang wajib hadir pada upacara adat dan '
        'penyambutan tamu kehormatan. Empat bahan utamanya melambangkan unsur '
        'masyarakat: daging untuk niniak mamak, kelapa untuk cadiak pandai, '
        'cabai untuk alim ulama, dan bumbu untuk keseluruhan masyarakat.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': [
        'Daging sapi bagian gandik 1 kg, potong melintang serat',
        'Santan kental dari 4 butir kelapa',
        'Asam kandis 3 buah',
      ],
      'bumbu': [
        'Cabai merah keriting 250 gram',
        'Bawang merah 15 siung dan bawang putih 8 siung',
        'Lengkuas, jahe, dan kunyit masing-masing seruas',
        'Serai 3 batang, memarkan',
        'Daun jeruk, daun kunyit, dan daun salam',
      ],
      'langkah': [
        'Haluskan cabai, bawang, jahe, kunyit, dan lengkuas hingga benar-benar lembut.',
        'Tumis bumbu halus bersama serai dan dedaunan sampai harum dan minyaknya keluar.',
        'Tuang santan, aduk searah terus-menerus agar santan tidak pecah.',
        'Masukkan daging dan asam kandis, masak dengan api kecil.',
        'Aduk berkala selama tiga sampai empat jam sampai kuah mengental dan berwarna cokelat gelap.',
        'Teruskan memasak sampai minyak keluar dan bumbu menempel kering pada daging.',
      ],
      'rasa': 'Gurih pekat, pedas berlapis, dengan sisa manis karamel santan',
      'penyajian':
          'Disajikan dengan nasi putih hangat dan daun singkong rebus. '
          'Rendang yang benar berwarna cokelat kehitaman dan kering, '
          'berbeda dari kalio yang masih berkuah.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-KLN-2',
    provinsi: 'Maluku',
    jenis: 'KLN',
    urutan: 2,
    judul: 'PAPEDA',
    kategoriLabel: 'KULINER TRADISIONAL',
    tagline:
        'Bubur sagu bening yang disantap tanpa dikunyah, langsung '
        'diseruput dari piring.',
    deskripsi:
        'Papeda adalah makanan pokok masyarakat Maluku dan Papua, dibuat dari '
        'pati sagu yang diseduh air mendidih hingga menjadi gel bening dan '
        'kenyal. Rasanya tawar, sehingga selalu dipasangkan dengan kuah ikan '
        'berbumbu kunyit.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Pohon sagu dianggap pohon kehidupan. Di beberapa daerah, pembukaan '
        'dusun sagu dan panen perdananya masih diiringi upacara adat serta '
        'pembagian hasil secara merata antarkeluarga.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': [
        'Tepung sagu basah 250 gram',
        'Air mendidih 1 liter',
        'Ikan kuah kuning sebagai pendamping',
      ],
      'bumbu': [
        'Kunyit, kemiri, dan bawang untuk kuah ikan',
        'Daun kemangi dan serai',
        'Perasan jeruk nipis dan garam',
      ],
      'langkah': [
        'Larutkan sagu dengan sedikit air dingin sampai tidak menggumpal.',
        'Tuang air mendidih sambil diaduk cepat searah menggunakan garpu kayu.',
        'Aduk terus sampai adonan berubah dari putih keruh menjadi bening dan liat.',
        'Angkat dengan gata-gata, sepasang tongkat kayu, lalu pindahkan ke piring saji.',
        'Siram kuah ikan kuning panas di sekelilingnya dan santap selagi hangat.',
      ],
      'rasa': 'Tawar dan kenyal, mengandalkan gurih asam dari kuah ikan',
      'penyajian':
          'Disantap dengan cara diseruput langsung dari piring tanpa dikunyah, '
          'berpasangan dengan ikan kuah kuning, kohu-kohu, atau sayur '
          'bunga pepaya.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-KLN-3',
    provinsi: 'DI Yogyakarta',
    jenis: 'KLN',
    urutan: 3,
    judul: 'GUDEG',
    kategoriLabel: 'KULINER TRADISIONAL',
    tagline:
        'Nangka muda yang dimasak semalaman hingga cokelat kemerahan '
        'oleh daun jati.',
    deskripsi:
        'Gudeg adalah olahan nangka muda yang dimasak berjam-jam dengan '
        'santan dan gula jawa. Daun jati yang dimasukkan ke dalam kuali '
        'memberi warna cokelat kemerahan yang menjadi ciri khasnya.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Nama gudeg berasal dari "hangudek", mengaduk, merujuk pada proses '
        'mengaduk kuali besar berjam-jam. Warung gudeg legendaris di '
        'Yogyakarta banyak yang buka lepas tengah malam.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': [
        'Nangka muda 1 kg, potong dadu',
        'Santan kental dari 2 butir kelapa',
        'Telur ayam rebus 6 butir',
        'Daun jati 3 lembar untuk pewarna alami',
      ],
      'bumbu': [
        'Gula jawa 150 gram',
        'Bawang merah, bawang putih, dan kemiri',
        'Ketumbar, lengkuas, dan daun salam',
      ],
      'langkah': [
        'Rebus nangka muda sampai empuk lalu tiriskan.',
        'Alasi dasar kuali dengan daun jati agar warnanya keluar merata.',
        'Susun nangka, telur, bumbu halus, dan gula jawa berlapis di dalam kuali.',
        'Tuang santan encer hingga terendam, masak dengan api kecil tanpa diaduk selama tiga jam.',
        'Tambahkan santan kental, lanjutkan memasak sampai kuah menyusut habis.',
      ],
      'rasa': 'Manis legit dengan gurih santan yang pekat',
      'penyajian':
          'Disajikan bersama nasi, krecek pedas, opor ayam, dan tahu bacem. '
          'Gudeg kering lebih awet, sedangkan gudeg basah masih berkuah '
          'areh.',
    },
  ),

  // Seni Pertunjukan dan Teater
  const BudayaModel(
    kodeTag: 'BUD-TTR-1',
    provinsi: 'Jawa Tengah',
    jenis: 'TTR',
    urutan: 1,
    judul: 'WAYANG KULIT PURWA',
    kategoriLabel: 'SENI PERTUNJUKAN DAN TEATER',
    tagline:
        'Bayangan kulit kerbau di balik kelir yang bercerita semalam '
        'suntuk.',
    deskripsi:
        'Wayang kulit purwa adalah teater bayangan yang dimainkan seorang '
        'dalang di balik layar kain. Satu orang menyuarakan puluhan tokoh, '
        'memimpin gamelan, dan menyisipkan kritik sosial lewat adegan '
        'goro-goro.',
    gambarUtama: 'assets/images/1308history.png',
    maknaSpiritual:
        'Kelir melambangkan dunia, blencong sebagai matahari, dan dalang '
        'sebagai penggerak takdir. Pertunjukan semalam suntuk menggambarkan '
        'perjalanan hidup manusia dari lahir hingga kembali.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Ditetapkan UNESCO sebagai Masterpiece of Oral and Intangible '
        'Heritage of Humanity pada 2003. Masih rutin digelar pada ruwatan, '
        'bersih desa, dan peringatan hari besar.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPemain': 'Satu dalang, satu sinden atau lebih, 15-20 pengrawit',
      'pengiring': 'Gamelan laras slendro dan pelog',
      'durasi': 'Semalam suntuk, sekitar 8 jam dari pukul 21.00 hingga subuh',
      'lakon': [
        'Bharatayuda — perang besar Pandawa melawan Kurawa',
        'Wahyu Cakraningrat — perebutan wahyu kepemimpinan',
        'Dewa Ruci — perjalanan Bima mencari air kehidupan',
        'Petruk Dadi Ratu — lakon carangan bernada satire',
      ],
      'jalanCerita':
          'Pertunjukan dibagi tiga babak mengikuti pathet. Babak pertama '
          'memperkenalkan persoalan, babak kedua berisi goro-goro dengan '
          'lawakan punakawan, dan babak terakhir menutup dengan perang '
          'serta penyelesaian.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-TTR-2',
    provinsi: 'Sumatera Barat',
    jenis: 'TTR',
    urutan: 2,
    judul: 'RANDAI',
    kategoriLabel: 'SENI PERTUNJUKAN DAN TEATER',
    tagline:
        'Teater melingkar yang berpindah adegan lewat tepukan celana '
        'galembong.',
    deskripsi:
        'Randai memadukan silat, musik, tari, dan drama dalam satu lingkaran '
        'pemain. Perpindahan adegan ditandai gerak silek dan tepukan pada '
        'celana longgar galembong yang menghasilkan bunyi bertalu.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Randai tumbuh dari surau dan lapau sebagai media pendidikan adat. '
        'Ceritanya diambil dari kaba, sastra lisan Minang yang dinyanyikan '
        'dengan dendang.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPemain': '14-25 orang berdiri melingkar',
      'pengiring': 'Talempong, saluang, rabab, dan bunyi tepukan galembong',
      'durasi': 'Tiga hingga empat jam',
      'lakon': [
        'Cindua Mato',
        'Malin Deman',
        'Sabai Nan Aluih',
        'Anggun Nan Tongga',
      ],
      'jalanCerita':
          'Pemain membentuk lingkaran dan bergerak searah jarum jam sambil '
          'berdendang. Ketika galembong ditepuk bersama, lingkaran '
          'membuka dan beberapa pemain masuk ke tengah memerankan adegan '
          'dialog, lalu lingkaran menutup kembali.',
    },
  ),

  // Permainan dan Olahraga Tradisional
  const BudayaModel(
    kodeTag: 'BUD-PRM-1',
    provinsi: 'Jawa Barat',
    jenis: 'PRM',
    urutan: 1,
    judul: 'CONGKLAK',
    kategoriLabel: 'PERMAINAN DAN OLAHRAGA TRADISIONAL',
    tagline:
        'Papan berlubang empat belas yang mengajarkan berhitung dan '
        'menahan diri.',
    deskripsi:
        'Congklak dimainkan dua orang di atas papan kayu berlubang, memakai '
        'biji sawo atau cangkang kerang. Pemain menyebar biji satu per satu '
        'searah jarum jam dan berusaha mengumpulkan biji terbanyak di lumbung '
        'sendiri.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Dikenal dengan banyak nama di Nusantara: dakon di Jawa, congkak di '
        'Melayu, dan mokaotan di Sulawesi Utara. Dahulu dimainkan gadis-gadis '
        'di halaman rumah sambil menunggu waktu panen.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPemain': '2 orang, duduk berhadapan',
      'alat': [
        'Papan congklak dengan 14 lubang kecil dan 2 lumbung besar',
        '98 biji sawo, kerang, atau batu kecil',
      ],
      'caraBermain': [
        'Isi setiap lubang kecil dengan tujuh biji, lumbung dibiarkan kosong.',
        'Pemain pertama mengambil seluruh biji dari salah satu lubang miliknya.',
        'Sebar biji satu per satu searah jarum jam, termasuk ke lumbung sendiri tetapi melewati lumbung lawan.',
        'Bila biji terakhir jatuh di lubang berisi, ambil semuanya dan lanjutkan menyebar.',
        'Bila biji terakhir jatuh di lumbung sendiri, pemain berhak jalan sekali lagi.',
        'Bila jatuh di lubang kosong milik sendiri, seluruh biji di lubang seberang menjadi miliknya dan giliran berpindah.',
      ],
      'nilai':
          'Melatih berhitung cepat, menyusun strategi beberapa langkah ke '
          'depan, serta kesabaran menunggu giliran dan menerima kekalahan.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-PRM-2',
    provinsi: 'Jawa Timur',
    jenis: 'PRM',
    urutan: 2,
    judul: 'KARAPAN SAPI',
    kategoriLabel: 'PERMAINAN DAN OLAHRAGA TRADISIONAL',
    tagline:
        'Sepasang sapi Madura memacu kaleles sejauh seratus meter dalam '
        'hitungan detik.',
    deskripsi:
        'Karapan sapi adalah lomba pacu sepasang sapi yang menarik kaleles, '
        'kereta kayu tempat joki berdiri. Lintasan sepanjang 100 meter '
        'ditempuh dalam sepuluh detik atau kurang.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Berawal dari tradisi membajak sawah yang berubah menjadi lomba '
        'seusai panen. Sapi juara berharga sangat mahal dan mengangkat '
        'martabat pemiliknya di mata masyarakat Madura.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPemain':
          'Satu joki per pasang sapi, diikuti puluhan pasang tiap turnamen',
      'alat': [
        'Sepasang sapi Madura terlatih',
        'Kaleles, kereta kayu tempat joki berdiri',
        'Pangonong, kayu penyatu leher kedua sapi',
        'Perlengkapan hias berupa kalung dan payung pengiring',
      ],
      'caraBermain': [
        'Sapi diarak keliling lapangan diiringi musik saronen sebelum lomba.',
        'Dua pasang sapi diadu pada lintasan lurus sepanjang 100 meter.',
        'Joki berdiri di atas kaleles dan menjaga keseimbangan sepanjang lintasan.',
        'Pemenang tiap babak maju ke babak berikutnya hingga tersisa juara.',
      ],
      'nilai':
          'Mengajarkan kerja keras merawat ternak, sportivitas, dan '
          'kebanggaan atas hasil kerja sendiri. Kini panitia menerapkan '
          'aturan larangan melukai sapi demi kesejahteraan hewan.',
    },
  ),

  // Cerita Rakyat dan Mitologi
  const BudayaModel(
    kodeTag: 'BUD-FKL-1',
    provinsi: 'Sumatera Barat',
    jenis: 'FKL',
    urutan: 1,
    judul: 'MALIN KUNDANG',
    kategoriLabel: 'CERITA RAKYAT DAN MITOLOGI',
    tagline:
        'Anak durhaka yang dikutuk menjadi batu di tepi Pantai Air '
        'Manis.',
    deskripsi:
        'Kisah paling terkenal dari Ranah Minang tentang seorang perantau '
        'miskin yang menjadi kaya, lalu menolak mengakui ibunya sendiri. '
        'Doa sang ibu yang terluka mengubahnya menjadi batu.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Cerita ini menjadi pengingat bagi tradisi merantau Minangkabau: '
        'sejauh apa pun pergi dan sebesar apa pun berhasil, seorang anak '
        'tetap wajib pulang menghormati kampung dan ibunya.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tokoh': [
        'Malin Kundang — anak perantau yang lupa asal',
        'Mande Rubayah — ibu Malin yang membesarkannya sendirian',
        'Istri Malin — putri saudagar kaya',
      ],
      'latar': 'Pantai Air Manis, Padang, Sumatera Barat',
      'ringkasanCerita':
          'Malin Kundang berlayar merantau meninggalkan ibunya yang miskin. '
          'Bertahun-tahun kemudian ia pulang sebagai saudagar kaya '
          'bersama istrinya. Ketika sang ibu menyambut dan memeluknya di '
          'dermaga, Malin malu mengakui perempuan tua berpakaian lusuh '
          'itu dan menghardiknya pergi. Hatinya hancur, sang ibu berdoa '
          'agar anaknya diberi pelajaran. Badai datang menghantam kapal, '
          'dan Malin beserta kapalnya membatu di tepi pantai.',
      'pesanMoral':
          'Keberhasilan tidak pernah menjadi alasan untuk melupakan orang '
          'yang membesarkan kita. Durhaka kepada orang tua adalah dosa '
          'yang balasannya datang di dunia.',
      'versiLain':
          'Kisah serupa muncul di banyak daerah: Si Tenggang di Malaysia, '
          'Batu Belah Batu Bertangkup di Riau, dan Sampuraga di Sumatera '
          'Utara yang membatu bersama danaunya.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-FKL-2',
    provinsi: 'Jawa Barat',
    jenis: 'FKL',
    urutan: 2,
    judul: 'SANGKURIANG',
    kategoriLabel: 'CERITA RAKYAT DAN MITOLOGI',
    tagline:
        'Perahu yang ditendang hingga tertelungkup, menjelma Gunung '
        'Tangkuban Perahu.',
    deskripsi:
        'Legenda Sunda tentang Sangkuriang yang tanpa sadar jatuh cinta '
        'kepada ibunya sendiri, Dayang Sumbi. Untuk menolak lamaran itu, sang '
        'ibu mengajukan syarat yang mustahil diselesaikan dalam semalam.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Cerita ini menjelaskan asal-usul bentang alam Bandung: Tangkuban '
        'Perahu dari perahu terbalik, dan dataran Bandung dari bekas danau '
        'purba yang memang terbukti pernah ada secara geologis.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tokoh': [
        'Sangkuriang — pemuda sakti yang tidak mengenali ibunya',
        'Dayang Sumbi — perempuan berparas awet muda',
        'Tumang — anjing jelmaan dewa, ayah Sangkuriang',
      ],
      'latar': 'Dataran tinggi Bandung, Jawa Barat',
      'ringkasanCerita':
          'Sangkuriang membunuh Tumang saat berburu tanpa tahu anjing itu '
          'ayahnya. Dayang Sumbi murka dan memukul kepalanya hingga '
          'terluka, lalu mengusirnya. Bertahun-tahun kemudian keduanya '
          'bertemu kembali dan saling jatuh cinta. Dayang Sumbi mengenali '
          'bekas luka di kepala pemuda itu dan mengajukan syarat: '
          'bendung Sungai Citarum dan buat sebuah perahu besar dalam satu '
          'malam. Ketika pekerjaan hampir selesai, ia menipu fajar agar '
          'terbit lebih awal. Murka karena gagal, Sangkuriang menendang '
          'perahu itu hingga tertelungkup.',
      'pesanMoral':
          'Amarah yang tidak dikendalikan menghancurkan apa yang sudah susah '
          'payah dibangun. Cerita ini juga menegaskan pantangan adat '
          'terhadap hubungan sedarah.',
      'versiLain':
          'Beberapa versi menyebut Dayang Sumbi menebarkan kain boeh rarang '
          'putih di timur untuk memalsukan fajar, sementara versi lain '
          'menyebut ia menumbuk lesung agar ayam berkokok lebih awal.',
    },
  ),

  // Arsip sementara berlabel [Karangan] untuk provinsi yang belum
  // punya arsip asli.
  const BudayaModel(
    kodeTag: 'BUD-RMH-2',
    provinsi: 'Sumatera Utara',
    jenis: 'RMH',
    urutan: 2,
    judul: '[Karangan] RUMAH BOLON',
    kategoriLabel: 'RUMAH ADAT',
    tagline:
        'Rumah panggung raja-raja Batak dengan atap melengkung menyerupai '
        'punggung kerbau.',
    deskripsi:
        'Rumah Bolon adalah rumah adat suku Batak yang berdiri di atas '
        'tiang setinggi dada orang dewasa. Seluruh sambungannya '
        'mengandalkan pasak kayu dan ikatan ijuk, tanpa sebatang paku pun.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual:
        'Ukiran gorga berwarna merah, putih, dan hitam pada dindingnya '
        'melambangkan tiga alam: dunia atas tempat pencipta, dunia tengah '
        'tempat manusia, dan dunia bawah.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Dahulu Rumah Bolon hanya dihuni raja beserta keluarganya. Tamu '
        'yang masuk harus menunduk melewati pintu rendah, cara halus '
        'mengajarkan hormat kepada pemilik rumah.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahanBangunan': 'Kayu ulin, ijuk aren, bambu, dan tali rotan',
      'strukturKhas':
          'Tiang bulatnya hanya diletakkan di atas batu datar, tidak ditanam ke '
          'tanah. Susunan ini membuat rumah bergoyang mengikuti getaran gempa '
          'alih-alih patah.',
      'bagianRumah': [
        'Tangga masuk di bagian depan, selalu berjumlah ganjil',
        'Ruang tengah tanpa sekat sebagai tempat berkumpul',
        'Para-para, loteng penyimpan hasil panen',
        'Kolong rumah untuk ternak dan alat pertanian',
      ],
      'fungsiSosial':
          'Ruang tengahnya dipakai musyawarah adat, penyelesaian sengketa, dan '
          'pesta pernikahan. Posisi duduk peserta menandai kedudukannya dalam '
          'marga.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-TRN-2',
    provinsi: 'Riau',
    jenis: 'TRN',
    urutan: 2,
    judul: '[Karangan] TARI ZAPIN',
    kategoriLabel: 'TARIAN TRADISIONAL',
    tagline:
        'Tarian Melayu bernapas Arab yang langkahnya rapat, kecil, dan tak '
        'pernah tergesa.',
    deskripsi:
        'Zapin tumbuh dari perjumpaan pedagang Arab dengan masyarakat '
        'Melayu pesisir. Gerakannya bertumpu pada langkah kaki yang rapat '
        'dan ayunan tangan yang ditahan sebatas pinggang.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Dahulu Zapin hanya ditarikan penari laki-laki dalam majelis, dan '
        'lagu pengiringnya berisi pujian serta nasihat. Baru pada abad '
        'ke-20 penari perempuan mulai ikut tampil di panggung umum.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPenari': 'Genap, umumnya 4 sampai 8 orang',
      'pengiring': 'Gambus, marwas, akordeon, dan rebana',
      'gerakUtama': [
        'Langkah biasa, kaki melangkah rapat ke depan dan belakang',
        'Langkah tahto, pembuka dan penutup sebagai tanda hormat',
        'Siku keluang, tangan berayun menyerupai kelelawar terbang',
        'Pusing tengah, penari berputar di tempat mengikuti ketukan marwas',
      ],
      'waktuPementasan':
          'Ditampilkan pada pesta pernikahan, khitanan, dan penyambutan tamu. '
          'Pementasan selalu dibuka dan ditutup dengan langkah tahto.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-MSK-2',
    provinsi: 'Kepulauan Riau',
    jenis: 'MSK',
    urutan: 2,
    judul: '[Karangan] GAMBUS MELAYU',
    kategoriLabel: 'ALAT MUSIK DAN LAGU DAERAH',
    tagline:
        'Alat petik berbadan cekung yang jadi nyawa setiap majelis Melayu.',
    deskripsi:
        'Gambus adalah alat musik petik berbadan seperti buah labu dibelah, '
        'berdawai enam sampai dua belas. Suaranya bulat dan rendah, dipakai '
        'memimpin irama dalam orkes Melayu.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Gambus dibawa pedagang dari Timur Tengah dan diterima masyarakat '
        'Melayu sebagai alat musik yang pantas mengiringi syair keagamaan. '
        'Di Kepulauan Riau, ia jadi penanda bahwa sebuah majelis resmi '
        'dimulai.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': 'Kayu nangka atau cempedak dengan penutup kulit kambing',
      'caraMemainkan':
          'Dipetik dengan plektrum dari tanduk sambil ditekan pada leher tanpa '
          'fret, sehingga pemain bisa menggeser nada secara halus.',
      'tanggaNada': 'Diatonis dengan cengkok khas Melayu',
      'repertoar': [
        'Lancang Kuning',
        'Pak Ngah Balik',
        'Zapin Bunga Tanjung',
        'Serampang Dua Belas',
      ],
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-BHS-1',
    provinsi: 'Jambi',
    jenis: 'BHS',
    urutan: 1,
    judul: '[Karangan] AKSARA INCUNG',
    kategoriLabel: 'BAHASA DAN SASTRA DAERAH',
    tagline:
        'Tulisan berbentuk goresan miring yang dipahat pada tanduk dan '
        'bambu.',
    deskripsi:
        'Incung adalah aksara masyarakat Kerinci yang bentuk hurufnya '
        'miring dan runcing karena ditoreh dengan pisau kecil. Naskahnya '
        'ditulis pada tanduk kerbau, ruas bambu, dan kulit kayu.',
    gambarUtama: 'assets/images/1308history.png',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Naskah Incung disimpan turun-temurun dalam keluarga dan hanya '
        'dibuka pada waktu tertentu. Isinya mencakup silsilah, hukum adat, '
        'mantra pengobatan, dan surat perjanjian antar-dusun.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'rumpunBahasa': 'Melayik, cabang Austronesia',
      'jumlahPenutur': 'Sekitar 300 ribu penutur bahasa Kerinci',
      'aksara': 'Incung, ditulis dari kiri ke kanan',
      'contohUngkapan': [
        'Sakti alam kerinci — kekuatan yang lahir dari tanah sendiri',
        'Adat bersendi syarak — adat berpijak pada aturan agama',
        'Idup dikanduang adat — hidup dijaga oleh adat',
      ],
      'karyaSastra':
          'Tambo Kerinci, kumpulan naskah yang memuat asal-usul dusun beserta '
          'hukum yang berlaku di dalamnya. Sebagian naskahnya kini disimpan di '
          'museum daerah.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-UPC-1',
    provinsi: 'Bengkulu',
    jenis: 'UPC',
    urutan: 1,
    judul: '[Karangan] TABOT',
    kategoriLabel: 'UPACARA DAN TRADISI ADAT',
    tagline:
        'Arak-arakan menara kayu yang berakhir dengan melarungnya ke laut.',
    deskripsi:
        'Tabot adalah upacara yang digelar sepuluh hari pertama bulan '
        'Muharam untuk mengenang gugurnya Husain di Karbala. Puncaknya '
        'adalah mengarak bangunan menara berhias ke tepi laut lalu '
        'membuangnya.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual:
        'Pelarungan Tabot dimaknai sebagai pelepasan duka. Yang dibuang '
        'bukan sekadar bangunan, melainkan kesedihan yang tidak boleh '
        'dibawa terus oleh yang hidup.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Tradisi ini dibawa pekerja dari Madras dan Bengali yang membangun '
        'Benteng Marlborough pada abad ke-18. Keturunan mereka, keluarga '
        'Tabot, memegang hak menyelenggarakannya sampai sekarang.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'waktuPelaksanaan': '1 sampai 10 Muharam',
      'pelaksana': 'Keluarga Tabot bersama pemerintah daerah',
      'tahapan': [
        'Mengambik tanah, pengambilan tanah keramat pada malam pertama',
        'Duduk penja, mencuci benda pusaka berbentuk telapak tangan',
        'Menjara, kunjungan antar-kelompok sambil menabuh dol',
        'Arak gedang, pawai menara Tabot keliling kota',
        'Tabot tebuang, melarung menara ke laut pada hari kesepuluh',
      ],
      'perlengkapan': [
        'Menara Tabot dari bambu, kertas warna, dan kayu ringan',
        'Dol, gendang besar dari bonggol kelapa',
        'Penja, replika telapak tangan dari kuningan',
        'Bunga melur dan kain putih',
      ],
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-KLN-4',
    provinsi: 'Sumatera Selatan',
    jenis: 'KLN',
    urutan: 4,
    judul: '[Karangan] PEMPEK',
    kategoriLabel: 'KULINER TRADISIONAL',
    tagline: 'Adonan ikan dan sagu yang tak lengkap tanpa kuah cuka hitam.',
    deskripsi:
        'Pempek adalah olahan daging ikan giling yang dicampur tepung sagu, '
        'direbus, lalu digoreng sebelum disajikan. Pendampingnya wajib '
        'cuko, kuah gelap berbahan gula aren, cabai, dan asam jawa.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Pempek lahir dari kebutuhan mengawetkan tangkapan ikan Sungai Musi '
        'yang berlimpah. Kini ia jadi penanda Palembang, dan setiap '
        'keluarga memegang takaran cuko masing-masing.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': [
        'Daging ikan tenggiri giling 500 gram',
        'Tepung sagu tani 300 gram',
        'Air es 200 mililiter',
        'Telur ayam untuk isian pempek kapal selam',
      ],
      'bumbu': [
        'Garam dan penyedap secukupnya',
        'Bawang putih halus 4 siung',
        'Gula aren 250 gram untuk cuko',
        'Cabai rawit, asam jawa, dan ebi untuk cuko',
      ],
      'langkah': [
        'Campur ikan giling dengan air es, garam, dan bawang putih sampai '
            'rata.',
        'Masukkan tepung sagu sedikit demi sedikit, aduk asal tercampur '
            'agar tidak keras.',
        'Bentuk adonan menjadi lenjer panjang atau kantong untuk kapal '
            'selam.',
        'Rebus dalam air mendidih sampai pempek mengapung, lalu tiriskan.',
        'Goreng sebentar dalam minyak panas sebelum disajikan.',
        'Rebus gula aren, asam, cabai, dan ebi hingga mengental menjadi '
            'cuko.',
      ],
      'rasa': 'Gurih ikan berpadu kuah asam pedas manis',
      'penyajian':
          'Dipotong serong lalu disiram cuko, ditaburi mentimun cincang dan mi '
          'kuning. Cuko disajikan terpisah bagi yang tidak kuat pedas.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-KLN-5',
    provinsi: 'Kepulauan Bangka Belitung',
    jenis: 'KLN',
    urutan: 5,
    judul: '[Karangan] LEMPAH KUNING',
    kategoriLabel: 'KULINER TRADISIONAL',
    tagline: 'Gulai ikan berkuah kunyit yang rasanya asam segar, bukan santan.',
    deskripsi:
        'Lempah kuning adalah masakan berkuah kunyit berisi ikan laut dan '
        'nanas muda. Kuahnya bening dan tajam karena sama sekali tidak '
        'memakai santan.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Masakan ini muncul dari kebiasaan nelayan memasak tangkapan '
        'langsung di perahu dengan bahan seadanya. Nanas dipakai bukan '
        'sebagai pemanis, melainkan untuk menghilangkan bau amis.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': [
        'Ikan tenggiri atau kakap 600 gram',
        'Nanas muda setengah buah, potong juring',
        'Air 1 liter',
        'Belimbing wuluh 5 buah',
      ],
      'bumbu': [
        'Kunyit seruas dan lengkuas seruas',
        'Cabai merah 10 buah dan bawang merah 8 siung',
        'Terasi bakar setengah sendok teh',
        'Garam dan gula secukupnya',
      ],
      'langkah': [
        'Haluskan kunyit, cabai, bawang merah, dan terasi.',
        'Didihkan air bersama bumbu halus dan lengkuas yang dimemarkan.',
        'Masukkan nanas dan belimbing wuluh, masak sampai kuah berwarna '
            'kuning pekat.',
        'Masukkan potongan ikan, masak sebentar agar dagingnya tidak '
            'hancur.',
        'Cicipi dan sesuaikan asin serta asamnya sebelum diangkat.',
      ],
      'rasa': 'Asam segar dengan pedas yang tajam',
      'penyajian':
          'Disantap panas bersama nasi putih dan sambal terasi. Kuahnya sengaja '
          'dibuat banyak agar bisa disiramkan ke atas nasi.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-PKN-1',
    provinsi: 'Lampung',
    jenis: 'PKN',
    urutan: 1,
    judul: '[Karangan] KAIN TAPIS',
    kategoriLabel: 'PAKAIAN ADAT',
    tagline: 'Kain tenun bersulam benang emas yang dikerjakan berbulan-bulan.',
    deskripsi:
        'Tapis adalah kain sarung tenun khas Lampung yang permukaannya '
        'disulam benang emas dan perak. Sehelai tapis halus bisa memakan '
        'waktu tiga sampai enam bulan pengerjaan.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Dahulu tapis hanya boleh dikenakan pada upacara adat, dan ragam '
        'sulamannya menandai kedudukan pemakainya. Perempuan Lampung dahulu '
        'belajar menenun tapis sebagai syarat sebelum menikah.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': 'Benang kapas tenunan tangan dengan sulam benang emas',
      'bagianBusana': [
        'Tapis, kain sarung bersulam sebagai bagian utama',
        'Siger, mahkota kuningan bertanduk untuk pengantin perempuan',
        'Selappai, baju tanpa lengan berhias tapis',
        'Buah jukum, rangkaian kalung berbentuk bunga',
      ],
      'warnaDominan': 'Cokelat kemerahan dengan kilau emas',
      'pemakaian':
          'Dikenakan pada pernikahan adat, pengangkatan gelar, dan penyambutan '
          'tamu agung. Motif tertentu hanya boleh dipakai keturunan penyimbang '
          'adat.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-TTR-3',
    provinsi: 'Banten',
    jenis: 'TTR',
    urutan: 3,
    judul: '[Karangan] DEBUS',
    kategoriLabel: 'SENI PERTUNJUKAN DAN TEATER',
    tagline:
        'Pertunjukan kekebalan tubuh yang lahir dari latihan bela diri dan '
        'zikir.',
    deskripsi:
        'Debus adalah seni pertunjukan yang menampilkan ketahanan tubuh '
        'terhadap benda tajam dan api. Peserta menjalani puasa dan wirid '
        'panjang sebelum diizinkan tampil.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual:
        'Debus dipahami bukan sebagai pameran kesaktian, melainkan bukti '
        'kepasrahan. Yang ditonjolkan adalah ketenangan pelaku, bukan '
        'lukanya.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Debus berkembang pada masa Kesultanan Banten abad ke-16 sebagai '
        'cara membangkitkan keberanian pasukan. Setelah masa perang usai, '
        'ia bertahan sebagai pertunjukan rakyat.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPemain': '8 sampai 15 orang termasuk penabuh',
      'pengiring': 'Tambur, gendang, kecrek, dan lantunan zikir',
      'durasi': 'Sekitar 60 menit',
      'lakon': [
        'Beubeur, mengiris lengan dengan golok tanpa terluka',
        'Gedebus, menusuk perut dengan almadad',
        'Nyusuk, menembus pipi dengan jarum besar',
        'Ngagurah, berjalan di atas bara api',
      ],
      'jalanCerita':
          'Pertunjukan dibuka dengan zikir bersama, dilanjutkan atraksi yang '
          'menaik tingkat bahayanya, dan ditutup doa penutup. Pemimpin kelompok '
          'selalu tampil terakhir.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-RMH-3',
    provinsi: 'Kalimantan Barat',
    jenis: 'RMH',
    urutan: 3,
    judul: '[Karangan] RUMAH RADAKNG',
    kategoriLabel: 'RUMAH ADAT',
    tagline:
        'Rumah panjang Dayak yang satu bangunannya memuat puluhan keluarga.',
    deskripsi:
        'Radakng adalah rumah betang suku Dayak Kanayatn yang panjangnya '
        'bisa mencapai seratus meter. Satu bangunan dihuni banyak keluarga '
        'yang masing-masing memiliki bilik sendiri.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Hidup di bawah satu atap membuat keputusan penting selalu diambil '
        'bersama di beranda panjang. Pendatang yang menginap wajib '
        'diperkenalkan lebih dulu kepada seluruh penghuni.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahanBangunan': 'Kayu belian, papan ulin, dan atap sirap kayu',
      'strukturKhas':
          'Bangunan berdiri di atas tiang setinggi tiga sampai lima meter dan '
          'memanjang sejajar sungai. Beranda terbuka membentang di sepanjang '
          'sisi depan.',
      'bagianRumah': [
        'Sami, beranda panjang tempat berkumpul dan bermusyawarah',
        'Bilik keluarga yang berderet di sisi belakang',
        'Pene, ruang terbuka untuk menjemur padi',
        'Tangga tunggal dari batang kayu bertakik',
      ],
      'fungsiSosial':
          'Beranda panjangnya menjadi ruang sidang adat, tempat menerima tamu, '
          'dan lokasi upacara panen. Setiap keluarga wajib menjaga bagian atap '
          'di atas biliknya.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-UPC-2',
    provinsi: 'Kalimantan Tengah',
    jenis: 'UPC',
    urutan: 2,
    judul: '[Karangan] TIWAH',
    kategoriLabel: 'UPACARA DAN TRADISI ADAT',
    tagline:
        'Upacara mengantar tulang leluhur ke tempat peristirahatan '
        'terakhir.',
    deskripsi:
        'Tiwah adalah upacara kematian tingkat akhir dalam kepercayaan '
        'Kaharingan. Tulang yang telah lama dimakamkan digali kembali, '
        'dibersihkan, lalu disimpan di sandung.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual:
        'Tiwah dipercaya mengantar liau, jiwa orang yang meninggal, menuju '
        'Lewu Tatau. Sebelum tiwah dilaksanakan, jiwa itu dianggap masih '
        'berkeliaran di antara yang hidup.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Karena biayanya besar, tiwah sering dilakukan sekaligus untuk '
        'banyak keluarga dan dapat berlangsung berminggu-minggu. '
        'Persiapannya kadang memakan waktu bertahun-tahun.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'waktuPelaksanaan': 'Musim kemarau, setelah panen',
      'pelaksana': 'Basir, pemimpin ritual Kaharingan',
      'tahapan': [
        'Pembuatan sandung dan sapundu di halaman rumah',
        'Penggalian dan pembersihan tulang dari makam lama',
        'Balian, pembacaan mantra pengantar selama beberapa malam',
        'Penyembelihan hewan kurban di tiang sapundu',
        'Penempatan tulang ke dalam sandung',
      ],
      'perlengkapan': [
        'Sandung, rumah kecil penyimpan tulang',
        'Sapundu, patung kayu bergambar wajah leluhur',
        'Gong dan garantung sebagai pengiring',
        'Tuak dan sesaji dari beras ketan',
      ],
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SIT-4-D',
    provinsi: 'Kalimantan Selatan',
    jenis: 'SIT',
    urutan: 4,
    judul: '[Karangan] MASJID SULTAN SURIANSYAH',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Masjid tertua Kalimantan Selatan yang atapnya bertingkat tanpa '
        'kubah.',
    deskripsi:
        'Masjid ini dibangun pada masa Sultan Suriansyah, raja Banjar '
        'pertama yang memeluk Islam. Atapnya bertumpang tiga dari sirap '
        'kayu, sama sekali tanpa kubah maupun menara tinggi.',
    gambarUtama: 'assets/images/borobudurB.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Bentuknya memperlihatkan bagaimana Islam masuk tanpa menghapus '
        'bentuk bangunan setempat. Mihrabnya beratap sendiri, terpisah dari '
        'bangunan utama, ciri yang jarang ditemukan di masjid lain.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': 'Sekitar 1526',
      'pendiri': 'Sultan Suriansyah',
      'gayaArsitektur': 'Tradisional Banjar beratap tumpang',
      'fungsiAsli':
          'Masjid kerajaan sekaligus tempat pengangkatan sultan dan pusat '
          'pengajaran agama bagi penduduk Banjar Kuala.',
      'kondisiSekarang':
          'Masih dipakai untuk salat lima waktu dan terbuka bagi pengunjung. '
          'Kompleksnya mencakup makam Sultan Suriansyah beserta kerabatnya.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SNJT-3',
    provinsi: 'Kalimantan Timur',
    jenis: 'SNJT',
    urutan: 3,
    judul: '[Karangan] MANDAU',
    kategoriLabel: 'SENJATA TRADISIONAL',
    tagline: 'Parang Dayak yang bilahnya sengaja dibuat tidak simetris.',
    deskripsi:
        'Mandau adalah senjata utama suku Dayak berupa parang panjang '
        'dengan satu sisi tajam. Bilahnya sedikit melengkung dan salah satu '
        'sisinya dibiarkan cekung.',
    gambarUtama: 'assets/images/kerisB.jpg',
    maknaSpiritual:
        'Ukiran dan tempelan rambut pada gagangnya dipercaya menjaga '
        'pemiliknya. Mandau pusaka tidak boleh dicabut sembarangan tanpa '
        'alasan.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Mandau bukan sekadar alat, melainkan penanda kedewasaan laki-laki '
        'Dayak. Sarungnya dilengkapi pisau kecil bernama langgei puai untuk '
        'pekerjaan halus.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': 'Besi mantikei, tanduk rusa, dan rotan',
      'teknikPembuatan':
          'Bilah ditempa berulang dari batu gunung yang mengandung besi, lalu '
          'disepuh dengan air perasan tumbuhan agar tidak mudah berkarat.',
      'bagianSenjata': [
        'Bilah dengan satu sisi tajam dan satu sisi cekung',
        'Hulu dari tanduk rusa berukir kepala burung enggang',
        'Kumpang, sarung kayu berhias manik dan bulu',
        'Langgei puai, pisau kecil yang menyatu dengan sarung',
      ],
      'fungsi':
          'Dipakai membuka ladang, berburu, dan mempertahankan diri. Mandau '
          'berukir halus disimpan sebagai pusaka dan hanya dikeluarkan pada '
          'upacara adat.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-TRN-3',
    provinsi: 'Kalimantan Utara',
    jenis: 'TRN',
    urutan: 3,
    judul: '[Karangan] TARI JUGIT',
    kategoriLabel: 'TARIAN TRADISIONAL',
    tagline: 'Tarian istana Bulungan yang gerakannya ditahan pelan sekali.',
    deskripsi:
        'Jugit adalah tarian keraton Kesultanan Bulungan yang dibawakan '
        'penari perempuan dengan gerak sangat lambat. Kelambatan itulah '
        'ukuran keberhasilannya.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Jugit terbagi dua: Jugit Paman yang boleh disaksikan umum, dan '
        'Jugit Demaring yang dahulu hanya boleh ditarikan di hadapan '
        'sultan. Penarinya dipilih dari kalangan kerabat istana.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPenari': '4 sampai 8 penari perempuan',
      'pengiring': 'Gambang, gong, dan gendang keraton',
      'gerakUtama': [
        'Sembah pembuka dengan lutut menyentuh lantai',
        'Ayunan tangan setinggi bahu yang ditahan lambat',
        'Langkah geser tanpa mengangkat telapak kaki',
        'Putaran badan setengah lingkaran sebagai penutup',
      ],
      'waktuPementasan':
          'Dipentaskan pada penobatan sultan, pernikahan kerabat istana, dan '
          'penyambutan tamu kehormatan. Di luar acara resmi, tarian ini jarang '
          'ditampilkan.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-TRN-4',
    provinsi: 'Sulawesi Utara',
    jenis: 'TRN',
    urutan: 4,
    judul: '[Karangan] TARI KABASARAN',
    kategoriLabel: 'TARIAN TRADISIONAL',
    tagline:
        'Tarian perang Minahasa dengan mata penari yang sengaja '
        'dibelalakkan.',
    deskripsi:
        'Kabasaran adalah tarian perang suku Minahasa yang dibawakan penari '
        'laki-laki berpakaian merah sambil menghunus pedang. Wajah penari '
        'dibuat garang dengan mata membelalak sepanjang tarian.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Dahulu tarian ini mengiringi keberangkatan dan kepulangan pasukan. '
        'Kini Kabasaran tampil pada penyambutan tamu dan upacara adat, '
        'tetapi busananya tetap merah darah seperti dulu.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPenari': '6 sampai 30 penari laki-laki',
      'pengiring': 'Tambur bertalu cepat dan gong kecil',
      'gerakUtama': [
        'Cakalele, gerak menyerang dengan pedang terangkat',
        'Kumbasaran, hentakan kaki serempak mengikuti tambur',
        'Lalaya\'an, gerak berputar sambil memutar tameng',
        'Sembah penutup kepada pemimpin adat',
      ],
      'waktuPementasan':
          'Ditampilkan pada upacara adat, penyambutan tamu, dan peringatan hari '
          'besar daerah. Penari harus berasal dari keturunan yang leluhurnya '
          'pernah menjadi waranei.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-PKN-2',
    provinsi: 'Gorontalo',
    jenis: 'PKN',
    urutan: 2,
    judul: '[Karangan] BILI\'U',
    kategoriLabel: 'PAKAIAN ADAT',
    tagline:
        'Busana pengantin Gorontalo yang setiap helainya punya nama dan '
        'aturan.',
    deskripsi:
        'Bili\'u adalah pakaian adat pengantin Gorontalo yang dikenakan pada '
        'puncak upacara pernikahan. Setiap kelengkapannya memiliki nama '
        'tersendiri dan urutan pemakaian yang tidak boleh dibalik.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual:
        'Warna busana menandai kedudukan: kuning keemasan untuk keturunan '
        'bangsawan, ungu dan hijau untuk golongan lain. Aturan ini masih '
        'dipegang pada upacara adat resmi.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Pengantin yang mengenakan bili\'u tidak boleh berjalan sendiri; ia '
        'dituntun pemangku adat sepanjang upacara. Prosesi pemakaiannya '
        'sendiri bisa memakan waktu dua jam.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': 'Kain satin bersulam benang emas dan hiasan kuningan',
      'bagianBusana': [
        'Baju bili\'u berlengan panjang dengan sulaman dada',
        'Buluwa, mahkota bertingkat bagi pengantin perempuan',
        'Tuhi-tuhi, hiasan kepala menjuntai dari kuningan',
        'Etango, ikat pinggang lebar berukir',
      ],
      'warnaDominan': 'Kuning keemasan dan ungu',
      'pemakaian':
          'Dikenakan hanya pada puncak akad dan resepsi adat. Di luar itu, '
          'busana ini disimpan dan dirawat oleh pemangku adat, bukan oleh '
          'keluarga pengantin.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SRK-2',
    provinsi: 'Sulawesi Tengah',
    jenis: 'SRK',
    urutan: 2,
    judul: '[Karangan] KAIN KULIT KAYU IVO',
    kategoriLabel: 'SENI RUPA DAN KRIYA',
    tagline:
        'Kain yang dibuat bukan dengan ditenun, melainkan dipukul sampai '
        'melebar.',
    deskripsi:
        'Kain ivo dibuat dari kulit bagian dalam pohon beringin atau nunu '
        'yang dipukul berjam-jam sampai seratnya melebar menjadi lembaran. '
        'Tidak ada benang dan tidak ada alat tenun sama sekali.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Kain kulit kayu adalah tekstil tertua di Sulawesi Tengah, dipakai '
        'jauh sebelum kapas dikenal. Bunyi pukulan ike yang bersahutan dulu '
        'jadi penanda bahwa sebuah kampung sedang menyiapkan upacara.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'medium': 'Kulit bagian dalam pohon nunu',
      'teknik':
          'Kulit direndam beberapa hari lalu dipukul dengan batu beralur '
          'bernama ike sampai seratnya merenggang dan melebar berkali lipat, '
          'kemudian dijemur dan diwarnai.',
      'motifKhas': [
        'Garis geometris berulang berwarna cokelat tanah',
        'Titik-titik menyerupai biji yang disusun berbaris',
        'Motif sulur tumbuhan menjalar di tepi kain',
        'Bidang polos yang sengaja dibiarkan kosong',
      ],
      'maknaMotif':
          'Motif geometris melambangkan keteraturan hidup bermasyarakat, '
          'sedangkan bidang kosong dibiarkan sebagai pengakuan bahwa tidak ada '
          'yang sempurna.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-RMH-4',
    provinsi: 'Sulawesi Barat',
    jenis: 'RMH',
    urutan: 4,
    judul: '[Karangan] RUMAH BOYANG',
    kategoriLabel: 'RUMAH ADAT',
    tagline:
        'Rumah panggung Mandar yang tinggi tiangnya menandai derajat '
        'pemiliknya.',
    deskripsi:
        'Boyang adalah rumah adat suku Mandar berbentuk panggung dengan '
        'atap pelana. Jumlah anak tangga dan tinggi tiangnya dahulu '
        'menandai kedudukan pemilik rumah.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Bagian depan rumah selalu menghadap laut karena masyarakat Mandar '
        'hidup dari pelayaran. Ruang tamu dibuat luas agar cukup menampung '
        'kerabat yang datang saat musim melaut usai.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahanBangunan': 'Kayu bitti, papan jati, dan atap rumbia',
      'strukturKhas':
          'Bangunan ditopang tiang yang berdiri di atas batu, dengan lantai '
          'dibuat bertingkat rendah untuk memisahkan ruang tamu dari ruang '
          'keluarga.',
      'bagianRumah': [
        'Lotang, ruang depan untuk menerima tamu',
        'Tangnga boyang, ruang tengah keluarga',
        'Bui boyang, ruang belakang tempat perempuan bekerja',
        'Naung boyang, kolong untuk menyimpan perahu kecil dan jala',
      ],
      'fungsiSosial':
          'Ruang depannya dipakai musyawarah kampung dan pembacaan doa selamat '
          'sebelum melaut. Perempuan menerima tamunya di ruang belakang, '
          'terpisah dari ruang depan.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SIT-5-D',
    provinsi: 'Sulawesi Tenggara',
    jenis: 'SIT',
    urutan: 5,
    judul: '[Karangan] BENTENG KERATON BUTON',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Benteng batu karang terluas di dunia yang di dalamnya masih ada '
        'kampung.',
    deskripsi:
        'Benteng Keraton Buton adalah tembok pertahanan sepanjang lebih '
        'dari dua kilometer yang mengelilingi pusat Kesultanan Buton. Di '
        'dalam temboknya sampai kini masih berdiri permukiman penduduk.',
    gambarUtama: 'assets/images/borobudurB.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Temboknya disusun dari batu karang yang direkatkan campuran kapur '
        'dan putih telur. Dua belas gerbangnya dulu dijaga terpisah oleh '
        'kelompok masyarakat yang berbeda.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': 'Abad ke-16',
      'pendiri': 'Sultan Buton ketiga, La Sangaji',
      'gayaArsitektur': 'Benteng batu karang bertembok keliling',
      'fungsiAsli':
          'Melindungi istana, masjid agung, dan permukiman keluarga sultan dari '
          'serangan laut sekaligus menjadi batas wilayah kekuasaan.',
      'kondisiSekarang':
          'Sebagian besar tembok masih utuh dan bisa ditelusuri berkeliling. Di '
          'dalamnya terdapat masjid tua, makam sultan, dan rumah penduduk yang '
          'masih dihuni.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-UPC-3',
    provinsi: 'Bali',
    jenis: 'UPC',
    urutan: 3,
    judul: '[Karangan] NGABEN',
    kategoriLabel: 'UPACARA DAN TRADISI ADAT',
    tagline: 'Upacara membakar jenazah yang justru digelar tanpa tangis.',
    deskripsi:
        'Ngaben adalah upacara pembakaran jenazah dalam agama Hindu Bali. '
        'Keluarga diminta menahan tangis karena kesedihan dipercaya menahan '
        'perjalanan jiwa yang dilepas.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual:
        'Api dipahami sebagai perwujudan Dewa Brahma yang mengembalikan '
        'lima unsur tubuh ke asalnya. Abu yang tersisa kemudian dilarung ke '
        'laut atau sungai.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Karena biayanya besar, banyak keluarga menunggu ngaben massal yang '
        'ditanggung bersama satu banjar. Jenazah dimakamkan sementara '
        'sampai waktunya tiba.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'waktuPelaksanaan': 'Hari baik menurut kalender Bali',
      'pelaksana': 'Pedanda bersama warga banjar',
      'tahapan': [
        'Ngulapin, memanggil kembali roh dari tempat meninggalnya',
        'Nyiramin, memandikan jenazah di halaman rumah',
        'Ngaskara, penyucian roh oleh pedanda',
        'Pengarakan bade menuju kuburan sambil diputar di persimpangan',
        'Pembakaran jenazah dan pelarungan abu ke laut',
      ],
      'perlengkapan': [
        'Bade, menara pengusung jenazah bertingkat',
        'Lembu kayu sebagai wadah pembakaran',
        'Kain kafan dan bunga sesaji',
        'Tirta, air suci dari beberapa pura',
      ],
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-PRM-3',
    provinsi: 'Nusa Tenggara Barat',
    jenis: 'PRM',
    urutan: 3,
    judul: '[Karangan] PERESEAN',
    kategoriLabel: 'PERMAINAN DAN OLAHRAGA TRADISIONAL',
    tagline: 'Adu rotan antar-lelaki Sasak yang darahnya dianggap doa hujan.',
    deskripsi:
        'Peresean adalah pertarungan dua laki-laki bersenjata tongkat rotan '
        'dan berperisai kulit kerbau. Pemenang ditentukan bukan oleh '
        'jatuhnya lawan, melainkan oleh lecetnya kulit.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual:
        'Tetesan darah pepadu dipercaya sebagai persembahan agar hujan '
        'turun. Karena itu peresean dulu digelar justru pada puncak musim '
        'kering.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Peresean dahulu dipakai menguji keberanian calon prajurit. Meski '
        'keras, kedua petarung wajib berjabat tangan setelah pertandingan '
        'dan dilarang menyimpan dendam.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPemain': '2 pepadu, dipandu 3 pekembar',
      'alat': [
        'Penjalin, tongkat rotan sepanjang satu meter',
        'Ende, perisai dari kulit kerbau tebal',
        'Ikat kepala dan kain pinggang adat',
        'Gamelan gendang beleq sebagai pengiring',
      ],
      'caraBermain': [
        'Pekembar memilih dua petarung yang seimbang dari penonton.',
        'Kedua pepadu saling berhadapan dan memberi hormat.',
        'Pertandingan berlangsung lima ronde, masing-masing pendek.',
        'Pukulan hanya sah bila mengenai punggung atau bahu.',
        'Pertandingan dihentikan begitu salah satu berdarah di kepala.',
      ],
      'nilai':
          'Peresean mengajarkan keberanian menerima sakit tanpa mengeluh dan '
          'kemampuan berhenti bermusuhan begitu pertandingan usai.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-MSK-3',
    provinsi: 'Nusa Tenggara Timur',
    jenis: 'MSK',
    urutan: 3,
    judul: '[Karangan] SASANDO',
    kategoriLabel: 'ALAT MUSIK DAN LAGU DAERAH',
    tagline:
        'Alat petik berbadan daun lontar yang senarnya melingkari tabung '
        'bambu.',
    deskripsi:
        'Sasando adalah alat musik petik dari Pulau Rote dengan tabung '
        'bambu di tengah dan senar yang melingkarinya. Wadah setengah '
        'lingkaran dari anyaman daun lontar berfungsi sebagai pemantul '
        'suara.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Ganjalan kecil di bawah setiap senar bisa digeser untuk mengubah '
        'nada, sehingga satu sasando dapat disetel ke berbagai tangga nada. '
        'Pemainnya memetik dengan kedua tangan dari dua sisi tabung.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': 'Bambu, daun lontar kering, dan senar kawat',
      'caraMemainkan':
          'Dipetik dengan jari kedua tangan yang bekerja dari sisi berlawanan; '
          'tangan kiri memainkan melodi sementara tangan kanan mengisi iringan.',
      'tanggaNada': 'Dapat disetel pentatonis maupun diatonis',
      'repertoar': ['Bolelebo', 'Ofalangga', 'Lisoi', 'Tebe Onana'],
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SIT-6-D',
    provinsi: 'Maluku Utara',
    jenis: 'SIT',
    urutan: 6,
    judul: '[Karangan] KERATON KESULTANAN TERNATE',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Istana berbentuk singa duduk yang menghadap langsung ke Gunung '
        'Gamalama.',
    deskripsi:
        'Keraton Kesultanan Ternate dibangun pada abad ke-19 di atas bukit '
        'menghadap laut. Denahnya dirancang menyerupai seekor singa yang '
        'sedang duduk, dengan bagian depan sebagai kepala.',
    gambarUtama: 'assets/images/borobudurB.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Ternate adalah pusat perdagangan cengkih yang membuat bangsa Eropa '
        'berdatangan sejak abad ke-16. Keraton ini menyimpan mahkota '
        'berambut yang menurut kepercayaan setempat rambutnya terus tumbuh.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': '1813',
      'pendiri': 'Sultan Muhammad Ali',
      'gayaArsitektur': 'Perpaduan Eropa dan Maluku Utara',
      'fungsiAsli':
          'Kediaman sultan sekaligus pusat pemerintahan dan penyimpanan pusaka '
          'kesultanan yang menguasai perdagangan cengkih.',
      'kondisiSekarang':
          'Sebagian bangunan menjadi museum yang memamerkan mahkota, senjata, '
          'dan naskah kuno. Sultan beserta keluarganya masih menempati bagian '
          'dalam keraton.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SIT-7-D',
    provinsi: 'Papua Barat Daya',
    jenis: 'SIT',
    urutan: 7,
    judul: '[Karangan] LUKISAN CADAS MISOOL',
    kategoriLabel: 'SITUS DAN BANGUNAN BERSEJARAH',
    tagline:
        'Cap tangan berusia ribuan tahun di tebing karang yang hanya bisa '
        'dicapai dengan perahu.',
    deskripsi:
        'Di tebing-tebing karang Misool terdapat lukisan cadas berupa cap '
        'tangan, ikan, dan perahu yang dibuat dengan pewarna merah dari '
        'oker. Sebagian berada tepat di atas permukaan laut.',
    gambarUtama: 'assets/images/borobudurB.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Lukisan ini diperkirakan berumur ribuan tahun dan menjadi jejak '
        'paling awal kehidupan manusia di kawasan Raja Ampat. Posisinya '
        'yang menggantung di atas air membuatnya sulit dijangkau dan justru '
        'terjaga.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tahunBerdiri': 'Diperkirakan 3.000 sampai 5.000 tahun lalu',
      'pendiri': 'Penghuni awal kepulauan Misool',
      'gayaArsitektur': 'Lukisan cadas pada dinding karang',
      'fungsiAsli':
          'Diduga menjadi penanda wilayah sekaligus bagian dari upacara yang '
          'berkaitan dengan laut dan perjalanan melautnya penduduk awal.',
      'kondisiSekarang':
          'Masih terlihat jelas dan dilindungi sebagai bagian kawasan '
          'konservasi. Pengunjung hanya boleh mendekat dengan perahu, tanpa '
          'menyentuh dinding.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-TRN-5',
    provinsi: 'Papua Barat',
    jenis: 'TRN',
    urutan: 5,
    judul: '[Karangan] TARI YOSPAN',
    kategoriLabel: 'TARIAN TRADISIONAL',
    tagline:
        'Tarian pergaulan Papua yang gerakannya meniru pesawat lepas '
        'landas.',
    deskripsi:
        'Yospan adalah gabungan dua tarian, Yosim dan Pancar. Sebagian '
        'gerakannya meniru manuver pesawat terbang yang dilihat penduduk '
        'pada pertengahan abad ke-20.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Berbeda dari tarian adat yang penuh aturan, Yospan adalah tarian '
        'pergaulan yang boleh diikuti siapa saja. Lingkaran penari kerap '
        'membesar sendiri karena penonton ikut masuk.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'jumlahPenari': 'Tidak dibatasi, biasanya lebih dari 10 orang',
      'pengiring': 'Ukulele, tifa, bas gitar, dan stem bass',
      'gerakUtama': [
        'Pancar gas, langkah cepat maju seperti pesawat berlari',
        'Gale-gale, langkah bergoyang mengikuti irama',
        'Jef, gerak melompat ringan dengan kedua kaki',
        'Pacul tiga, tiga hentakan kaki berulang',
      ],
      'waktuPementasan':
          'Ditampilkan pada penyambutan tamu, pesta rakyat, dan perayaan '
          'sekolah. Tidak ada pantangan waktu, sehingga Yospan bisa dibawakan '
          'kapan saja.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-FKL-3',
    provinsi: 'Papua Tengah',
    jenis: 'FKL',
    urutan: 3,
    judul: '[Karangan] LEGENDA DANAU PANIAI',
    kategoriLabel: 'CERITA RAKYAT DAN MITOLOGI',
    tagline: 'Cerita tentang danau yang lahir dari janji yang dilanggar.',
    deskripsi:
        'Legenda ini menceritakan asal-usul Danau Paniai di dataran tinggi '
        'Papua Tengah. Danau itu dikisahkan muncul setelah seorang pemuda '
        'melanggar pantangan yang ia setujui sendiri.',
    gambarUtama: 'assets/images/1308history.png',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Cerita ini dituturkan turun-temurun oleh masyarakat Mee dan biasa '
        'disampaikan orang tua kepada anak menjelang tidur. Versi lisannya '
        'berbeda-beda antar-kampung.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'tokoh': [
        'Pemuda Mee yang menemukan mata air',
        'Perempuan penjaga air yang muncul dari kabut',
        'Tetua kampung yang memberi peringatan',
        'Warga kampung di lembah',
      ],
      'latar': 'Lembah pegunungan tengah Papua',
      'ringkasanCerita':
          'Seorang pemuda menemukan mata air yang tak pernah kering dan '
          'dijanjikan air itu akan terus mengalir asalkan ia tidak '
          'menceritakannya kepada siapa pun. Ketika kampung dilanda kemarau, ia '
          'melanggar janji dan membawa warga ke sana. Air lalu menyembur tanpa '
          'henti sampai seluruh lembah tergenang menjadi danau.',
      'pesanMoral':
          'Cerita ini mengajarkan bahwa janji yang diucapkan sendiri harus '
          'ditepati, dan bahwa kebaikan yang dipaksakan tanpa perhitungan bisa '
          'berubah menjadi bencana.',
      'versiLain':
          'Versi lain menyebut air itu muncul dari tangisan perempuan penjaga '
          'yang kecewa, bukan dari mata air yang meluap.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-RMH-5',
    provinsi: 'Papua Pegunungan',
    jenis: 'RMH',
    urutan: 5,
    judul: '[Karangan] HONAI',
    kategoriLabel: 'RUMAH ADAT',
    tagline:
        'Rumah bulat beratap jerami yang di dalamnya api tak pernah '
        'dibiarkan padam.',
    deskripsi:
        'Honai adalah rumah adat suku Dani berbentuk bulat dengan atap '
        'jerami mengerucut hampir menyentuh tanah. Pintunya rendah dan '
        'tidak ada satu pun jendela.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    maknaSpiritual: null,
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Ketiadaan jendela bukan kelalaian melainkan perhitungan: udara '
        'pegunungan yang dingin ditahan di dalam, dan asap perapian di '
        'tengah ruangan menghangatkan sekaligus mengawetkan atap jerami.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahanBangunan': 'Kayu, jerami alang-alang, dan tali dari kulit kayu',
      'strukturKhas':
          'Dinding kayu disusun melingkar dengan atap kerucut yang menjuntai '
          'rendah. Bagian dalam dibagi dua tingkat, dengan perapian tepat di '
          'tengah lantai bawah.',
      'bagianRumah': [
        'Pintu rendah tunggal yang mengharuskan penghuni menunduk',
        'Perapian di tengah lantai bawah',
        'Lantai atas dari papan sebagai tempat tidur',
        'Para-para di bawah atap untuk menyimpan alat berburu',
      ],
      'fungsiSosial':
          'Honai laki-laki dan perempuan dipisah, dan honai laki-laki menjadi '
          'tempat mengajarkan adat kepada anak lelaki yang sudah cukup umur.',
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-MSK-4',
    provinsi: 'Papua',
    jenis: 'MSK',
    urutan: 4,
    judul: '[Karangan] TIFA',
    kategoriLabel: 'ALAT MUSIK DAN LAGU DAERAH',
    tagline:
        'Gendang kayu berbentuk jam pasir yang tak boleh sembarang ditabuh.',
    deskripsi:
        'Tifa adalah gendang tabung dari kayu yang dilubangi dengan membran '
        'kulit rusa atau biawak pada satu sisi. Badannya diukir dan '
        'sebagian dilengkapi pegangan.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual:
        'Pada beberapa marga, tifa tertentu hanya boleh ditabuh pemiliknya '
        'dan ukirannya menandai asal-usul keluarga pemiliknya.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Tifa mengiringi hampir seluruh upacara di Papua, dari penyambutan '
        'tamu sampai pesta panen. Sebelum ditabuh, membrannya dipanaskan di '
        'dekat api agar suaranya nyaring.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'bahan': 'Kayu lenggua dengan membran kulit rusa',
      'caraMemainkan':
          'Ditabuh dengan telapak tangan pada bagian tepi dan tengah membran '
          'untuk menghasilkan dua warna bunyi yang berbeda.',
      'tanggaNada': 'Tidak bernada tetap, berfungsi sebagai pengatur irama',
      'repertoar': ['Yamko Rambe Yamko', 'Apuse', 'Sajojo', 'E Mambo Simbo'],
    },
  ),
  const BudayaModel(
    kodeTag: 'BUD-SRK-3',
    provinsi: 'Papua Selatan',
    jenis: 'SRK',
    urutan: 3,
    judul: '[Karangan] UKIRAN ASMAT',
    kategoriLabel: 'SENI RUPA DAN KRIYA',
    tagline: 'Patung kayu yang dipahat tanpa sketsa dan tanpa diukur.',
    deskripsi:
        'Ukiran Asmat adalah seni pahat kayu yang dikerjakan tanpa gambar '
        'rancangan lebih dulu. Pemahatnya, disebut wowipits, langsung '
        'membentuk kayu mengikuti bayangan di kepalanya.',
    gambarUtama: 'assets/images/onboardin2.jpg',
    maknaSpiritual:
        'Setiap patung mewakili kerabat yang telah meninggal, dan '
        'pembuatannya dianggap sebagai cara melunasi utang kepada leluhur.',
    gambarMaknaSpiritual: null,
    konteksBudaya:
        'Kayu yang dipakai umumnya bitanggur atau ketapang yang tumbuh di '
        'rawa. Karya besar seperti tiang bisu dikerjakan berbulan-bulan dan '
        'hanya boleh dibuat setelah upacara tertentu.',
    gambarKonteksBudaya: null,
    detailKategori: {
      'medium': 'Kayu bitanggur dan kayu besi rawa',
      'teknik':
          'Kayu dipahat langsung dengan kapak batu atau pahat besi tanpa '
          'sketsa, lalu diwarnai dengan kapur putih, tanah merah, dan arang '
          'hitam.',
      'motifKhas': [
        'Bisj, tiang tinggi berisi susunan tokoh leluhur',
        'Sosok manusia berjongkok dengan kepala membesar',
        'Burung dan kuskus sebagai perlambang perantara',
        'Perisai berukir garis melingkar berulang',
      ],
      'maknaMotif':
          'Sosok manusia melambangkan kerabat yang meninggal dan belum '
          'dibalaskan, sedangkan burung menandai perpindahan jiwa dari dunia '
          'hidup ke dunia leluhur.',
    },
  ),
];

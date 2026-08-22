// Data awal untuk tabel `budaya`, dipakai sekali saat database dibuat.
import '../../models/budaya_model.dart';

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
];

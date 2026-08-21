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
];

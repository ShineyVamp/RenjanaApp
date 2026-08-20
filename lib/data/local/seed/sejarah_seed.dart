// Data awal sejarah yang diisikan ke tabel `sejarah` saat database
// pertama kali dibuat. Bukan sumber data runtime: setelah tersimpan,
// aplikasi selalu membaca lewat SejarahRepository.
import '../../models/sejarah_model.dart';

final List<SejarahModel> defaultSejarahList = [
  const SejarahModel(
    kodeTag: 'HIS-170845-1',
    tanggalKey: '170845',
    urutan: 1,
    judul: 'Detik Proklamasi',
    subtitle: '17.08.45',
    ringkasan:
        'Proklamasi Kemerdekaan Indonesia, yang dibacakan pada 17 Agustus 1945, '
        'menandai deklarasi resmi kedaulatan Republik Indonesia. Disusun di kediaman '
        'Laksamana Maeda dan diketik oleh Sayuti Melik.',
    gambarUtama: 'assets/images/170845history.png',
    alurPeristiwa: [
      TimelineItemModel(
        date: '16 AGUSTUS 1945 · 03:00 WIB',
        title: 'Peristiwa\nRengasdengklok',
        desc:
            'Golongan muda menculik Soekarno dan Hatta ke Rengasdengklok untuk '
            'menjauhkan mereka dari pengaruh Jepang.',
        imgPath: 'assets/images/rengasdengklok.jpg',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '16 AGUSTUS 1945 · 23:00 WIB',
        title: 'Perumusan Naskah',
        desc:
            'Di rumah Laksamana Maeda, Soekarno, Hatta, dan Ahmad Soebardjo '
            'merumuskan teks proklamasi kemerdekaan.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '17 AGUSTUS 1945 · 10:00 WIB',
        title: 'Pembacaan Proklamasi',
        desc:
            'Di Jalan Pegangsaan Timur No. 56, naskah dibacakan dan Bendera '
            'Merah Putih jahitan Ibu Fatmawati dikibarkan.',
        imgPath: 'assets/images/perumusan.jpg',
        hasImage: true,
      ),
    ],
  ),
  const SejarahModel(
    kodeTag: 'HIS-150845-1',
    tanggalKey: '150845',
    urutan: 1,
    judul: 'Runtuhnya Tirani',
    subtitle: '15.08.45',
    ringkasan:
        '15 Agustus 1945: Saat kekosongan kekuasaan dunia membuka jalan '
        'keberanian bagi para pendiri bangsa untuk merapatkan barisan dan '
        'memproklamasikan kemerdekaan sejati.',
    gambarUtama: 'assets/images/1308history.png',
    alurPeristiwa: [
      TimelineItemModel(
        date: '15 AGUSTUS 1945 · 12:00 WIB',
        title: 'Kaisar Hirohito Menyerah',
        desc:
            'Melalui siaran radio Gyokuon-hoso, Kaisar Jepang Hirohito mengumumkan '
            'penyerahan tanpa syarat kepada Sekutu.',
        imgPath: 'assets/images/1308history.png',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '15 AGUSTUS 1945 · 20:00 WIB',
        title: 'Rapat Pemuda Pegangsaan',
        desc:
            'Chaeroel Saleh memimpin rapat pemuda di Gedung Lembaga Bakteriologi '
            'mendesak percepatan proklamasi.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),
  const SejarahModel(
    kodeTag: 'HIS-160845-1',
    tanggalKey: '160845',
    urutan: 1,
    judul: 'Penculikan Rengasdengklok',
    subtitle: '16.08.45',
    ringkasan:
        '16 Agustus 1945: Aksi dramatis para pemuda pejuang yang membawa Bung Karno '
        'dan Bung Hatta ke Rengasdengklok guna memutus campur tangan militer Jepang.',
    gambarUtama: 'assets/images/rengasdengklok.jpg',
    alurPeristiwa: [
      TimelineItemModel(
        date: '16 AGUSTUS 1945 · 04:00 WIB',
        title: 'Tiba di Rumah Djiaw Kie Siong',
        desc:
            'Rombongan Soekarno-Hatta tiba dan berdiskusi intensif di rumah petani Tionghoa.',
        imgPath: 'assets/images/rengasdengklok.jpg',
        hasImage: true,
      ),
    ],
  ),
  const SejarahModel(
    kodeTag: 'HIS-160845-2',
    tanggalKey: '160845',
    urutan: 2,
    judul: 'Malam Perumusan Naskah',
    subtitle: '16.08.45',
    ringkasan:
        '16 Agustus 1945 (Malam): Perumusan naskah otentik proklamasi di kediaman '
        'Laksamana Maeda di bawah tekanan waktu demi fajar kemerdekaan.',
    gambarUtama: 'assets/images/perumusan.jpg',
    alurPeristiwa: [
      TimelineItemModel(
        date: '16 AGUSTUS 1945 · 23:30 WIB',
        title: 'Pengetikan Teks Proklamasi',
        desc:
            'Sayuti Melik mengetik naskah proklamasi yang telah disepakati bersama para tokoh bangsa.',
        imgPath: 'assets/images/perumusan.jpg',
        hasImage: true,
      ),
    ],
  ),
  const SejarahModel(
    kodeTag: 'HIS-200845-1',
    tanggalKey: '200845',
    urutan: 1,
    judul: 'Garda Kedaulatan',
    subtitle: '20.08.45',
    ringkasan:
        '20 Agustus 1945: Pembentukan Badan Keamanan Rakyat (BKR) untuk menyatukan '
        'laskar pejuang pemuda ex-PETA dan Heiho menjaga keutuhan Republik.',
    gambarUtama: 'assets/images/onboardin1.jpg',
    alurPeristiwa: [
      TimelineItemModel(
        date: '20 AGUSTUS 1945 · 09:00 WIB',
        title: 'Maklumat BKR',
        desc:
            'Seruan pembentukan pertahanan sipil dan pos-pos keamanan rakyat.',
        imgPath: 'assets/images/onboardin1.jpg',
        hasImage: true,
      ),
    ],
  ),
  const SejarahModel(
    kodeTag: 'HIS-281028-1',
    tanggalKey: '281028',
    urutan: 1,
    judul: 'Ikrar Sumpah Pemuda',
    subtitle: '28.10.28',
    ringkasan:
        '28 Oktober 1928: Kongres Pemuda II yang melahirkan ikrar persatuan '
        'Satu Tanah Air, Satu Bangsa, dan Satu Bahasa Indonesia.',
    gambarUtama: 'assets/images/onboardin3.jpg',
    alurPeristiwa: [
      TimelineItemModel(
        date: '28 OKTOBER 1928 · 19:00 WIB',
        title: 'Pembacaan Ikrar',
        desc: 'Soegondo Djojopoespito memimpin pembacaan putusan ikrar pemuda.',
        imgPath: 'assets/images/onboardin3.jpg',
        hasImage: true,
      ),
    ],
  ),
];

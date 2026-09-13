// Data awal untuk tabel `sejarah`, dipakai sekali saat database dibuat.
import 'package:renjana/features/sejarah/data/models/sejarah_model.dart';

final List<SejarahModel> defaultSejarahList = [
// 1. PERANG PUPUTAN KLUNGKUNG (28 APRIL 1908)
  SejarahModel(
    kodeTag: 'HIS-28041908-1',
    tanggalKey: '28041908',
    urutan: 1,
    judul: 'PERANG PUPUTAN KLUNGKUNG',
    subtitle: '28.04.1908 · Perlawanan Habis-habisan Kerajaan Klungkung Melawan Kolonial Belanda',
    ringkasan:
        'Puputan Klungkung merupakan perang puputan terakhir yang berkobar di Bali sebagai bentuk perlawanan bersenjata pamungkas dari kerajaan tradisional Bali terhadap ekspansi militer pemerintah kolonial Hindia Belanda. Ketegangan memuncak saat Belanda berusaha menegakkan monopoli candu dan menuntut kedaulatan penuh atas wilayah Klungkung, yang secara tegas ditolak oleh penguasa tertinggi monarki di Bali tersebut.\n\nPada 28 April 1908, pasukan KNIL yang dipimpin oleh Jenderal van Heutsz melancarkan bombardemen artileri berat ke jantung istana Semarapura. Menghadapi gempuran senjata modern tanpa gentar, Raja Ida I Dewa Agung Jambe II bersama keluarga kerajaan, punggawa, dan segenap rakyat mengenakan pakaian serba putih untuk menyongsong musuh dalam ritual puputan—bertempur hingga tetes darah penghabisan demi mempertahankan martabat kedaulatan tanah leluhur.\n\nGugurnya Raja Klungkung beserta permaisuri dan ratusan pengikut setianya di medan laga menandai keruntuhan kerajaan berdaulat terakhir di Bali. Peristiwa heroik ini secara resmi mengakhiri kemerdekaan politik tradisional Bali dan menempatkan seluruh Pulau Dewata di bawah kekuasaan mutlak birokrasi kolonial Hindia Belanda.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018543/renjana/sejarah/puputan_klungkung_cover.webp',
    provinsi: 'Bali',
    periode: 'KLN',
    jenisPeristiwa: 'PRG',
    detailPeristiwa: {
      'pihakTerlibat': [
        'Kerajaan Klungkung (Laskar Semarapura)',
        'Tentara Kolonial Hindia Belanda (KNIL)',
      ],
      'lokasi': 'Puri Semarapura, Klungkung, Bali',
      'hasil':
          'Raja Ida I Dewa Agung Jambe II gugur bersama keluarga istana; seluruh wilayah Bali resmi jatuh di bawah kendali administratif Hindia Belanda.',
      'korban':
          'Ratusan bangsawan dan pejuang Klungkung gugur; puluhan serdadu KNIL tewas dan luka-luka.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '16 APRIL 1908 · 08:00 WITA',
        title: 'Penolakan Ultimatum Kedaulatan',
        desc:
            'Raja Ida I Dewa Agung Jambe II menolak tegas ultimatum Belanda untuk menyerahkan kedaulatan kepabeanan dan mematuhi monopoli candu pemerintah kolonial.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018544/renjana/sejarah/puputan_klungkung_ultimatum.webp',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '28 APRIL 1908 · 06:00 WITA',
        title: 'Bombardemen Artileri Meriam Belanda',
        desc:
            'Armada artileri KNIL mengepung Puri Semarapura dan melepaskan tembakan meriam yang menghancurkan benteng pertahanan keraton Klungkung.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '28 APRIL 1908 · 09:30 WITA',
        title: 'Iring-iringan Puputan Serba Putih',
        desc:
            'Raja Dewa Agung Jambe II memimpin permaisuri, putra mahkota, serta laskar istana keluar dari puri mengenakan pakaian putih suci bersenjatakan keris pusaka.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018545/renjana/sejarah/puputan_klungkung_laskar.webp',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '28 APRIL 1908 · 11:00 WITA',
        title: 'Gugurnya Raja dan Jatuhnya Klungkung',
        desc:
            'Raja wafat di medan tempur akibat terjangan peluru musuh, disusul permaisuri dan segenap punggawa, menandai akhir perlawanan fisik di Bali.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 2. PENDIRIAN BOEDI OETOMO (20 MEI 1908)
  SejarahModel(
    kodeTag: 'HIS-20051908-1',
    tanggalKey: '20051908',
    urutan: 1,
    judul: 'PENDIRIAN BOEDI OETOMO',
    subtitle: '20.05.1908 · Tonggak Awal Kebangkitan Nasional Indonesia Modern',
    ringkasan:
        'Organisasi Boedi Oetomo didirikan pada hari Rabu, 20 Mei 1908, di ruang anatomi gedung School tot Opleiding van Inlandsche Artsen (STOVIA), Batavia. Didorong oleh kampanye penggalangan dana pendidikan (studiefonds) yang digagas Dr. Wahidin Soedirohoesodo, para pelajar kedokteran bumiputra sepakat mendirikan perkumpulan modern yang bertujuan mengangkat derajat bangsa melalui kemajuan pendidikan, budaya, dan perekonomian rakyat.\n\nKelahiran organisasi ini dipimpin oleh Soetomo bersama kawan-kawan sekampusnya, seperti Soeraji Tirtonegoro dan Goenawan Mangoenkoesoemo. Boedi Oetomo menjadi perintis gerakan modern pertama di tanah air yang berlandaskan struktur organisasi rasional lengkap dengan anggaran dasar, cabang keanggotaan, dan kepengurusan terstruktur, menggantikan perlawanan berbasis kedaerahan yang selama berabad-abad bersifat sporadis.\n\nMeski pada awalnya membatasi keanggotaan pada wilayah Jawa dan Madura serta bersikap moderat terhadap pemerintah kolonial, Boedi Oetomo berhasil menyalakan kesadaran kolektif bumiputra sebagai entitas yang bersatu. Tanggal berdirinya organisasi ini di kemudian hari diresmikan oleh Presiden Soekarno sebagai Hari Kebangkitan Nasional Republik Indonesia.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018547/renjana/sejarah/pendirian_boedi_oetomo_cover.jpg',
    provinsi: 'DKI Jakarta',
    periode: 'NAS',
    jenisPeristiwa: 'ORG',
    detailPeristiwa: {
      'pendiri': [
        'Dr. Soetomo',
        'Soeraji Tirtonegoro',
        'Goenawan Mangoenkoesoemo',
      ],
      'tahunBerdiri': '1908, Gedung STOVIA Batavia',
      'tujuan':
          'Memajukan pengajaran, pertanian, peternakan, perdagangan, teknik, industri, serta menghidupkan kembali kebudayaan bangsa.',
      'tokohPenting': [
        'Dr. Wahidin Soedirohoesodo',
        'Dr. Soetomo',
        'Goenawan Mangoenkoesoemo',
        'Raden Mas Adipati Tirtokoesoemo',
      ],
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '20 MEI 1908 · 09:00 WIB',
        title: 'Pertemuan di Ruang Kuliah STOVIA',
        desc:
            'Soetomo dan puluhan siswa STOVIA berkumpul di Batavia untuk menindaklanjuti gagasan dana pendidikan yang diutarakan Dr. Wahidin Soedirohoesodo.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018549/renjana/sejarah/pendirian_boedi_oetomo_pertemuan.webp',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '20 MEI 1908 · 11:30 WIB',
        title: 'Pemberian Nama Boedi Oetomo',
        desc:
            'Soeraji mengusulkan nama "Boedi Oetomo" (budi yang utama) sebagai perwujudan akhlak luhur untuk membebaskan rakyat dari kebodohan dan keterbelakangan.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018550/renjana/sejarah/pendirian_boedi_oetomo_pemberian.webp',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '05 OKTOBER 1908 · 08:00 WIB',
        title: 'Kongres Pertama di Yogyakarta',
        desc:
            'Boedi Oetomo menggelar kongres perdananya di Yogyakarta dan menetapkan Adipati Karanganyar, R.M.A. Tirtokoesoemo, sebagai ketua umum pertama.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018552/renjana/sejarah/pendirian_boedi_oetomo_kongres.webp',
        hasImage: true,
      ),
    ],
  ),

  // 3. TRANSFORMASI SAREKAT ISLAM (10 SEPTEMBER 1912)
  SejarahModel(
    kodeTag: 'HIS-10091912-1',
    tanggalKey: '10091912',
    urutan: 1,
    judul: 'TRANSFORMASI SAREKAT ISLAM',
    subtitle: '10.09.1912 · Peletakan Akta Hukum Organisasi Massa Bumiputra Terbesar',
    ringkasan:
        'Sarekat Islam (SI) bertransformasi dari Sarekat Dagang Islam (SDI) yang didirikan oleh Haji Samanhudi di Solo pada tahun 1905. Atas usulan Hadji Oemar Said (H.O.S.) Tjokroaminoto, kata "Dagang" ditanggalkan guna memperluas spektrum pergerakan dari sekadar serikat pedagang batik menjadi pergerakan massa kerakyatan yang memperjuangkan dimensi politik, sosial, dan agama di seluruh wilayah Hindia Belanda.\n\nPada 10 September 1912, akta notaris resmi Sarekat Islam disusun di hadapan Notaris B. ter Kuile di Surabaya. Langkah hukum ini diambil agar organisasi memperoleh status badan hukum (rechtspersoon) resmi dari Gubernur Jenderal Hindia Belanda, sekaligus melegalkan pembentukan cabang-cabang kepengurusan di berbagai kota besar di Pulau Jawa dan Sumatra.\n\nDi bawah kepemimpinan kharismatik H.O.S. Tjokroaminoto, Sarekat Islam berkembang pesat menjadi organisasi massa modern terbesar pertama di Indonesia dengan ratusan ribu kader. Gerakan ini secara vokal mengkritik eksploitasi kapitalisme kolonial dan menuntut pemerintahan mandiri (zelfbestuur) bagi rakyat bumiputra.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018558/renjana/sejarah/sarekat_islam_cover.jpg',
    provinsi: 'Jawa Timur',
    periode: 'NAS',
    jenisPeristiwa: 'ORG',
    detailPeristiwa: {
      'pendiri': [
        'H.O.S. Tjokroaminoto',
        'Haji Samanhudi',
      ],
      'tahunBerdiri': '1912, Surabaya',
      'tujuan':
          'Memajukan perdagangan bumiputra, memperkuat ikatan persaudaraan umat Islam, serta memperjuangkan keadilan sosial politik bagi rakyat jajahan.',
      'tokohPenting': [
        'H.O.S. Tjokroaminoto',
        'Haji Samanhudi',
        'H. Agus Salim',
        'Abdoel Moeis',
      ],
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '10 SEPTEMBER 1912 · 10:00 WIB',
        title: 'Pencatatan Akta Notaris di Surabaya',
        desc:
            'H.O.S. Tjokroaminoto menandatangani Anggaran Dasar Sarekat Islam di hadapan Notaris B. ter Kuile guna meresmikan status kelembagaan pergerakan.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '26 JANUARI 1913 · 09:00 WIB',
        title: 'Kongres Pertama SI di Surabaya',
        desc:
            'Tjokroaminoto memaparkan platform perjuangan organisasi di hadapan puluhan ribu anggota dan menegaskan komitmen membela martabat rakyat kecil.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018560/renjana/sejarah/sarekat_islam_pidato.webp',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '29 MARET 1913 · 14:00 WIB',
        title: 'Pemberian Izin Bersyarat oleh Kolonial',
        desc:
            'Gubernur Jenderal Idenburg menolak status badan hukum sentral namun mengizinkan status badan hukum lokal bagi masing-masing cabang afdeling SI.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 4. PENDIRIAN INDISCHE PARTIJ (25 DESEMBER 1912)
  SejarahModel(
    kodeTag: 'HIS-25121912-1',
    tanggalKey: '25121912',
    urutan: 1,
    judul: 'PENDIRIAN INDISCHE PARTIJ',
    subtitle: '25.12.1912 · Deklarasi Partai Politik Radikal Multietnis Pertama di Nusantara',
    ringkasan:
        'Indische Partij (IP) didirikan di Bandung pada 25 Desember 1912 oleh tiga serangkai tokoh nasional: E.F.E. Douwes Dekker (Danudirja Setiabudi), Dr. Tjipto Mangoenkoesoemo, dan R.M. Soewardi Soerjaningrat (Ki Hadjar Dewantara). IP merupakan partai politik pertama di Hindia Belanda yang secara tegas dan terbuka mencantumkan kemerdekaan politik (Indië los van Holland) dalam anggaran dasarnya.\n\nPartai ini mengusung ideologi nasionalisme inklusif (Indische nationalisme) yang merangkul seluruh penduduk tanah jajahan tanpa memandang ras atau keturunan, baik bumiputra, Indo-Eropa, Tionghoa, maupun Arab. Dengan semboyan radikal "Indië voor Indiërs" (Hindia untuk orang Hindia), Indische Partij mendobrak stratifikasi sosial kolonial yang memecah-belah masyarakat.\n\nSikap tegas dan kritik tajam partai terhadap penguasa imperialis membuat pemerintah kolonial Hindia Belanda menolak memberikan status badan hukum pada 4 Maret 1913. Tak berselang lama, partai ini dibubarkan secara paksa dan ketiga tokoh pendirinya diasingkan ke Belanda karena dinilai membahayakan keamanan negara.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018563/renjana/sejarah/indische_partij_cover.jpg',
    provinsi: 'Jawa Barat',
    periode: 'NAS',
    jenisPeristiwa: 'ORG',
    detailPeristiwa: {
      'pendiri': [
        'E.F.E. Douwes Dekker (Danudirja Setiabudi)',
        'Dr. Tjipto Mangoenkoesoemo',
        'R.M. Soewardi Soerjaningrat (Ki Hadjar Dewantara)',
      ],
      'tahunBerdiri': '1912, Bandung',
      'tujuan':
          'Membangkitkan patriotisme seluruh rakyat Hindia untuk membebaskan tanah air dari penjajahan Belanda menuju Indonesia merdeka.',
      'tokohPenting': [
        'E.F.E. Douwes Dekker',
        'Dr. Tjipto Mangoenkoesoemo',
        'R.M. Soewardi Soerjaningrat',
      ],
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '25 DESEMBER 1912 · 10:00 WIB',
        title: 'Deklarasi Pendirian di Bandung',
        desc:
            'Tiga Serangkai memproklamasikan berdirinya Indische Partij di hadapan ratusan pendukung bumiputra dan Indo di Bandung.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018565/renjana/sejarah/indische_partij_deklarasi.jpg',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '04 MARET 1913 · 11:00 WIB',
        title: 'Penolakan Badan Hukum oleh Belanda',
        desc:
            'Gubernur Jenderal Idenburg menolak permohonan badan hukum IP atas pertimbangan asas tujuannya dianggap menghasut pembangkangan pada kekuasaan kolonial.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '18 AGUSTUS 1913 · 08:30 WIB',
        title: 'Keputusan Pengasingan Tiga Serangkai',
        desc:
            'Pemerintah Hindia Belanda mengeluarkan surat pengasingan resmi bagi Douwes Dekker, Tjipto Mangoenkoesoemo, dan Soewardi Soerjaningrat ke Eropa.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018567/renjana/sejarah/indische_partij_pengasingan.jpg',
        hasImage: true,
      ),
    ],
  ),

  // 5. PENERBITAN RISALAH "ALS IK EENS NEDERLANDER WAS" (13 JULI 1913)
  SejarahModel(
    kodeTag: 'HIS-13071913-1',
    tanggalKey: '13071913',
    urutan: 1,
    judul: 'PENERBITAN RISALAH “ALS IK EENS NEDERLANDER WAS”',
    subtitle: '13.07.1913 · Pamflet Satire Suwardi Suryaningrat Mengguncang Kolonialisme',
    ringkasan:
        'Pada 13 Juli 1913, harian De Express di Bandung menerbitkan selebaran risalah politik bertajuk "Als ik eens Nederlander was" (Seandainya Aku Seorang Belanda) yang ditulis oleh Raden Mas Soewardi Soerjaningrat. Tulisan bernada satire tajam ini disusun untuk mengecam rencana pemerintah kolonial yang hendak merayakan peringatan 100 tahun kemerdekaan Belanda dari kekuasaan Prancis secara mewah di tanah Hindia Belanda.\n\nDalam risalah tersebut, Suwardi mengecam ironi moral bangsa penjajah yang memungut sumbangan wajib dari rakyat jajahan yang miskin untuk membiayai pesta kebebasan bangsa yang menindas mereka. Tulisan tersebut secara gamblang menyatakan bahwa bila ia terlahir sebagai seorang Belanda, ia tidak akan pernah mengadakan pesta kemerdekaan di negeri orang lain yang kemerdekaannya telah dirampas.\n\nRisalah ini mengguncang ketenangan otoritas kolonial di Batavia dan langsung memicu kemarahan pejabat Hindia Belanda. Penerbitan naskah bersejarah ini berujung pada penangkapan langsung terhadap Suwardi, disusul pembelaan berani dari Tjipto Mangoenkoesoemo dan Douwes Dekker melalui tulisan "Kracht of Vrees?" yang mempercepat pengasingan Tiga Serangkai.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018601/renjana/sejarah/als_ik_eens_nederlander_was_cover.jpg',
    provinsi: 'Jawa Barat',
    periode: 'NAS',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis': 'Raden Mas Soewardi Soerjaningrat (Ki Hadjar Dewantara)',
      'tahun': '13 Juli 1913, Bandung',
      'isiPokok':
          'Kritik sarkas terhadap peringatan 100 tahun kemerdekaan Belanda yang dibiayai menggunakan uang pungutan rakyat jajahan yang hak kemerdekaannya justru dirampas.',
      'tempatSimpan':
          'Museum Kebangkitan Nasional / Arsip Nasional Republik Indonesia (ANRI), Jakarta',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '13 JULI 1913 · 07:00 WIB',
        title: 'Penerbitan Risalah di De Express',
        desc:
            'Surat kabar harian De Express mencetak naskah asli tulisan Suwardi Suryaningrat dan menyebarkannya secara kilat ke seantero Pulau Jawa.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018602/renjana/sejarah/als_ik_eens_cetak.jpg',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '19 JULI 1913 · 14:00 WIB',
        title: 'Penyitaan Dokumen oleh Otoritas Batavia',
        desc:
            'Polisi kolonial melakukan razia dan penyitaan terhadap seluruh pamflet serta terjemahan bahasa Melayunya yang diterbitkan Komite Bumiputra.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '30 JULI 1913 · 09:00 WIB',
        title: 'Penangkapan Suwardi Suryaningrat',
        desc:
            'Aparat kejaksaan kolonial menangkap Suwardi atas dakwaan delik pers dan penghasutan massa melawan pemerintah Hindia Belanda.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 6. PENDIRIAN PERSERIKATAN NASIONAL INDONESIA (04 JULI 1927)
  SejarahModel(
    kodeTag: 'HIS-04071927-1',
    tanggalKey: '04071927',
    urutan: 1,
    judul: 'PENDIRIAN PERSERIKATAN NASIONAL INDONESIA',
    subtitle: '04.07.1927 · Konsolidasi Kekuatan Nasionalis Radikal Non-Kooperasi',
    ringkasan:
        'Perserikatan Nasional Indonesia didirikan pada 4 Juli 1927 dalam sebuah pertemuan di Jl. Dewi Sartika No. 22 Bandung oleh Ir. Soekarno bersama para intelektual muda yang tergabung dalam Algemeene Studieclub (ASC), termasuk Mr. Iskaq Tjokrohadisoerjo, Mr. Sartono, dan Mr. Soenario. Pada kongres pertamanya di Surabaya tahun 1928, nama organisasi ini disempurnakan menjadi Partai Nasional Indonesia (PNI).\n\nPNI lahir sebagai respon atas kekosongan kepemimpinan pergerakan radikal pasca-kegagalan pemberontakan komunis 1926. Berbeda dengan pergerakan terdahulu yang bersifat kooperatif di dalam dewan kolonial Volksraad, PNI menetapkan strategi non-kooperasi mutlak terhadap pemerintah kolonial Hindia Belanda dengan mengusung asas mandiri (self-help) dan kekuatan sendiri (zelfvertrouwen).\n\nMelalui retorika politik Bung Karno yang memukau dan konsep ideologi Marhaenisme, PNI membakar semangat persatuan nasional di kalangan massa akar rumput. Popularitas kilat partai ini dinilai sebagai ancaman terbesar bagi penguasa Hindia Belanda, yang pada akhirnya memicu penangkapan Bung Karno beserta pimpinan PNI lainnya pada akhir Desember 1929.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018605/renjana/sejarah/pendirian_pni_cover.webp',
    provinsi: 'Jawa Barat',
    periode: 'NAS',
    jenisPeristiwa: 'ORG',
    detailPeristiwa: {
      'pendiri': [
        'Ir. Soekarno',
        'Mr. Iskaq Tjokrohadisoerjo',
        'Mr. Soenario',
        'Dr. Tjipto Mangoenkoesoemo',
      ],
      'tahunBerdiri': '1927, Bandung',
      'tujuan':
          'Mencapai kemerdekaan penuh bagi Indonesia melalui persatuan nasional, kemandirian rakyat, dan perlawanan tanpa kompromi terhadap kolonialisme.',
      'tokohPenting': [
        'Ir. Soekarno',
        'Mr. Sartono',
        'Mr. Iskaq Tjokrohadisoerjo',
        'Mr. Ali Sastroamidjojo',
      ],
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '04 JULI 1927 · 19:30 WIB',
        title: 'Rapat Pembentukan di Bandung',
        desc:
            'Ir. Soekarno memimpin sidang pembentukan Perserikatan Nasional Indonesia di kediaman Mr. Iskaq Tjokrohadisoerjo bersama anggota Algemeene Studieclub.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018606/renjana/sejarah/pendirian_pni_rapat.jpg',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '27 MEI 1928 · 09:00 WIB',
        title: 'Kongres I PNI di Surabaya',
        desc:
            'Kongres resmi mengubah nama menjadi Partai Nasional Indonesia, menetapkan lambang banteng merah-putih, dan menegaskan tujuan kemerdekaan penuh.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018608/renjana/sejarah/pendirian_pni_kongres.jpg',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '29 DESEMBER 1929 · 05:00 WIB',
        title: 'Penangkapan Pimpinan PNI di Yogyakarta',
        desc:
            'Polisi rahasia kolonial (PID) menangkap Ir. Soekarno dan kawan-kawan seusai rapat umum di Yogyakarta sebelum dijebloskan ke Penjara Banceuy.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 7. IKRAR SUMPAH PEMUDA (28 OKTOBER 1928 - URUTAN 1)
  SejarahModel(
    kodeTag: 'HIS-28101928-1',
    tanggalKey: '28101928',
    urutan: 1,
    judul: 'IKRAR SUMPAH PEMUDA',
    subtitle: '28.10.1928 · Penetapan Naskah Ikrar Persatuan Bangsa pada Kongres Pemuda II',
    ringkasan:
        'Pada hari Minggu malam, 28 Oktober 1928, Kongres Pemuda II yang berlangsung di Gedung Indonesische Clubgebouw, Kramat Raya 106 Batavia, resmi menetapkan sebuah ikrar kebangsaan monumental yang dikenal sebagai Sumpah Pemuda. Naskah ikrar ini dirumuskan secara cermat oleh Mohammad Yamin di atas secarik kertas sebelum diserahkan kepada pimpinan sidang, Soegondo Djojopoespito, untuk disetujui bersama para perwakilan organisasi pemuda daerah se-Nusantara.\n\nKongres yang diprakarsai oleh Perhimpunan Pelajar-Pelajar Indonesia (PPPI) ini menyatukan berbagai elemen kepemudaan yang semula tersekat primordialisme, seperti Jong Java, Jong Sumatranen Bond, Jong Bataks Bond, Jong Islamieten Bond, Jong Celebes, Jong Ambon, Pemuda Kaum Betawi, dan Sekar Roekoen. Seluruh peserta kongres bermufakat mengikrarkan tiga tonggak persatuan: satu tumpah darah (tanah air Indonesia), satu bangsa (bangsa Indonesia), dan menjunjung bahasa persatuan (bahasa Indonesia).\n\nSumpah Pemuda menjadi cetak biru konseptual paling revolusioner bagi lahirnya identitas nasional Indonesia. Peristiwa ini meluruhkan sekat-sekat etnisitas maupun kedaerahan sempit dan mengkristalisasikannya menjadi satu kesadaran geopolitik tunggal yang menopang perjuangan menuju proklamasi kemerdekaan.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018610/renjana/sejarah/sumpah_pemuda_cover.webp',
    provinsi: 'DKI Jakarta',
    periode: 'NAS',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis': 'Mohammad Yamin (perumus naskah ikrar)',
      'tahun': '28 Oktober 1928, Gedung Indonesische Clubgebouw Batavia',
      'isiPokok':
          'Ikrar bertumpah darah yang satu, tanah Indonesia; berbangsa yang satu, bangsa Indonesia; dan menjunjung bahasa persatuan, bahasa Indonesia.',
      'tempatSimpan':
          'Museum Sumpah Pemuda / Arsip Nasional Republik Indonesia (ANRI), Jakarta',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '28 OKTOBER 1928 · 17:30 WIB',
        title: 'Perumusan Draf oleh Mohammad Yamin',
        desc:
            'Di tengah pidato Mr. Soenario, Mohammad Yamin menuliskan rumusan tiga butir ikrar di atas secarik kertas lalu menyodorkannya kepada Soegondo Djojopoespito.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018613/renjana/sejarah/sumpah_pemuda_perumusan.png',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '28 OKTOBER 1928 · 21:00 WIB',
        title: 'Pembacaan Resolusi Kongres',
        desc:
            'Soegondo Djojopoespito membacakan keputusan resolusi kongres di hadapan ratusan delegasi pemuda yang memadati gedung pertemuan Kramat 106.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018614/renjana/sejarah/sumpah_pemuda_pembacaan.jpg',
        hasImage: true,
      ),
      TimelineItemModel(
        date: '28 OKTOBER 1928 · 22:00 WIB',
        title: 'Pengesahan dan Ikrar Bersama',
        desc:
            'Seluruh perwakilan organisasi pemuda berdiri menyambut naskah ikrar dengan antusiasme bulat, meresmikan kelahiran identitas nasional bangsa Indonesia.',
        imgPath: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018615/renjana/sejarah/sumpah_pemuda_ikrar.jpg',
        hasImage: true,
      ),
    ],
  ),

  // 8. PERDENGARAN PERDANA INDONESIA RAYA OLEH W.R. SOEPRATMAN (28 OKTOBER 1928 - URUTAN 2)
  SejarahModel(
    kodeTag: 'HIS-28101928-2',
    tanggalKey: '28101928',
    urutan: 2,
    judul: 'PERDENGARAN PERDANA LAGU INDONESIA RAYA OLEH W.R. SOEPRATMAN',
    subtitle: '28.10.1928 · Gesekan Biola Penggetar Jiwa Nasionalisme di Kongres Pemuda II',
    ringkasan:
        'Pada sesi penutupan Kongres Pemuda II tanggal 28 Oktober 1928 di Gedung Indonesische Clubgebouw Batavia, seorang jurnalis harian Sin Po sekaligus komponis muda bernama Wage Rudolf Soepratman memperdengarkan untuk pertama kalinya gubahan lagu ciptaannya yang berjudul "Indonesia Raya". Karena aula kongres diawasi ketat oleh dinas intelijen rahasia kolonial Belanda (PID), Soegondo Djojopoespito meminta Soepratman membawakan lagu tersebut tanpa lirik vokal.\n\nW.R. Soepratman menaiki podium kongres dan memainkan aransemen lagu kebangsaan itu secara instrumental menggunakan instrumen biola kesayangannya. Gesekan dawai biolanya yang mengalun khidmat dan heroik seketika menghipnotis seluruh delegasi pemuda yang memadati ruangan, menciptakan keheningan haru yang kemudian meledak menjadi gemuruh tepuk tangan dan seruan kemerdekaan.\n\nPerdengaran perdana lagu "Indonesia Raya" menandai lahirnya simbol identitas musikal kebangsaan yang mengikat rasa persaudaraan lintas kepulauan. Notasi dan lirik lengkap lagu ini kemudian segera dicetak di surat kabar Sin Po dan pamflet-pamflet pergerakan nasional, menjelma menjadi lagu kebangsaan abadi Negara Kesatuan Republik Indonesia.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018617/renjana/sejarah/wr_soepratman_cover.jpg',
    provinsi: 'DKI Jakarta',
    periode: 'NAS',
    jenisPeristiwa: 'TKH',
    detailPeristiwa: {
      'namaLengkap': 'Wage Rudolf Soepratman',
      'lahir': 'Jatinegara, Batavia, 09 Maret 1903',
      'wafat': 'Surabaya, 17 Agustus 1938',
      'peran':
          'Wartawan harian Sin Po dan komponis pencipta lagu kebangsaan "Indonesia Raya" yang pertama kali memperdengarkannya secara instrumental pada Kongres Pemuda II.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '28 OKTOBER 1928 · 20:30 WIB',
        title: 'Izin Penampilan Instrumental Tanpa Vokal',
        desc:
            'Soegondo Djojopoespito meminta W.R. Soepratman memainkan lagunya secara instrumental murni demi mengelabui aparat polisi PID Belanda yang mengawasi kongres.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '28 OKTOBER 1928 · 21:30 WIB',
        title: 'Gesekan Biola Indonesia Raya Bergema',
        desc:
            'W.R. Soepratman memainkan alunan nada Indonesia Raya dengan biolanya di hadapan kongres, disambut keheningan khidmat seluruh peserta rapat.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '10 NOVEMBER 1928 · 09:00 WIB',
        title: 'Publikasi Partitur di Harian Sin Po',
        desc:
            'Partitur not balok dan lirik lengkap tiga bait lagu Indonesia Raya diterbitkan secara luas untuk pertama kali pada edisi mingguan surat kabar Sin Po.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),
  //anjay
  SejarahModel(
    kodeTag: 'HIS-01010000-1',
    tanggalKey: '01010000',
    urutan: 1,
    judul: 'EKSKAVASI SITUS PURBAKALA SANGIRAN',
    subtitle: '01.01.0000 · Jejak Kehidupan Manusia Purba Pleistosen di Lembah Bengawan Solo',
    ringkasan:
        'Situs Purbakala Sangiran merupakan kawasan cagar budaya pra-sejarah terpenting di Asia Tenggara yang terletak di lembah Sungai Bengawan Solo, Jawa Tengah. Kawasan seluas kurang lebih 56 kilometer persegi ini menyimpan lapisan stratigrafi tanah purba berumur antara 2 juta hingga 100.000 tahun yang lalu (Formasi Kalibeng, Pucangan, Grenjengan/Kabuh, dan Notopuro), yang memuat rekaman evolusi biologis manusia, fauna, flora, serta lingkungan hidup secara utuh.\n\nPenelitian sistematis pertama kali dirintis oleh G.H.R. von Koenigswald pada dekade 1930-an yang berhasil menyingkap fosil rahang dan tengkorak hominid Homo erectus beserta perkakas serpih batu paleolitik. Fosil-fosil dari Sangiran merepresentasikan lebih dari separuh populasi temuan fosil Homo erectus di seluruh dunia, menjadikannya rujukan kunci para antropolog internasional dalam merekonstruksi garis silsilah evolusi manusia purba.\n\nAtas signifikansi akademis dan nilai sejarah peradabannya yang luar biasa bagi umat manusia, UNESCO secara resmi menetapkan Situs Purbakala Sangiran sebagai Warisan Budaya Dunia (World Heritage Site) Nomor 593 pada tahun 1996. Hingga kini, Sangiran terus menjadi pusat riset paleoantropologi terkemuka di tingkat global.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018621/renjana/sejarah/situs_sangiran_cover.png',
    provinsi: 'Jawa Tengah',
    periode: 'PRS',
    jenisPeristiwa: 'STS',
    detailPeristiwa: {
      'lokasi': 'Kecamatan Kalijambe, Kabupaten Sragen dan Karanganyar, Jawa Tengah',
      'tahun': 'Sekitar 1,5 juta hingga 100.000 tahun yang lalu (Kala Pleistosen Bawah–Tengah)',
      'kondisiSekarang':
          'Terawat sangat baik sebagai Situs Warisan Dunia UNESCO dengan Klaster Museum Krikilan, Dayu, Bukuran, Ngebung, dan Manyarejo.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: 'KALA PLEISTOSEN BAWAH · c. 1,5 JUTA TAHUN LALU',
        title: 'Pembentukan Formasi Pucangan dan Endapan Aluvial',
        desc:
            'Aktivitas vulkanik purba dan pergeseran danau air tawar membentuk endapan lempung hitam yang menjadi habitat awal kelompok Homo erectus tertua di Sangiran.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: 'KALA PLEISTOSEN TENGAH · c. 700.000 TAHUN LALU',
        title: 'Perkembangan Peradaban Alat Serpih Batu',
        desc:
            'Populasi Homo erectus tipik memproduksi alat-alat batu serpih kalsedon dan jasper untuk berburu serta mengolah fauna vertebrata purba.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '06 DESEMBER 1996 · 10:00 UTC',
        title: 'Penetapan Warisan Dunia oleh UNESCO',
        desc:
            'Komite Warisan Dunia UNESCO mengesahkan Sangiran Early Man Site ke dalam daftar situs warisan dunia budaya nomor urut 593 di Merida, Meksiko.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 2. PENETAPAN PRASASTI KEDUKAN BUKIT (PERIODE: HND / HINDU-BUDDHA)
  SejarahModel(
    kodeTag: 'HIS-16050682-1',
    tanggalKey: '16050682',
    urutan: 1,
    judul: 'PENETAPAN PRASASTI KEDUKAN BUKIT',
    subtitle: '16.05.0682 · Piagam Proklamasi Pendirian Wanua Kerajaan Sriwijaya',
    ringkasan:
        'Prasasti Kedukan Bukit dipahat di atas batu andesit bulat berukuran 45 kali 80 sentimeter pada tanggal 16 Mei 682 Masehi (23 Waisaka 604 Saka). Prasasti ini ditemukan di tepi Sungai Tatang, anak Sungai Musi di kawasan Kedukan Bukit, Palembang. Guratan aksara Pallawa berbahasa Melayu Kuno ini merupakan piagam tertua yang mencatat keberadaan sebuah imperium talasokrasi adidaya di Nusantara bernama Sriwijaya.\n\nIsi pokok prasasti mengisahkan perjalanan suci spiritual-militer (siddhayatra) yang dipimpin oleh penguasa tertinggi, Dapunta Hyang Sri Jayanasa. Sang baginda bertolak dari Minanga Tamwan menggunakan perahu dengan membawa armada tempur berkekuatan 20.000 personel tentara dan 312 peti perbekalan, hingga tiba di wilayah Mukha Upang dan berhasil menaklukkan kawasan sekitarnya.\n\nKeberhasilan ekspedisi maritim tersebut ditandai dengan pendirian sebuah wanua (kota permukiman/keraton) yang makmur, aman, dan sentosa. Prasasti ini menjadi tonggak sejarah tertulis paling sahih mengenai lahirnya Kedatuan Sriwijaya yang selama berabad-abad mendominasi jalur perdagangan Selat Malaka.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018623/renjana/sejarah/prasasti_kedukan_bukit_cover.jpg',
    provinsi: 'Sumatera Selatan',
    periode: 'HND',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis': 'Dapunta Hyang Sri Jayanasa (Penguasa Sriwijaya)',
      'tahun': '16 Mei 682 M (23 Waisaka 604 Saka), Palembang',
      'isiPokok':
          'Catatan perjalanan siddhayatra Dapunta Hyang bersama 20.000 prajurit untuk mendirikan wanua Sriwijaya yang makmur dan penuh berkah.',
      'tempatSimpan': 'Museum Nasional Indonesia, Jakarta (Nomor Inventaris D.1)',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '23 APRIL 682 M · 06:00 WIB',
        title: 'Keberangkatan Ekspedisi Siddhayatra',
        desc:
            'Dapunta Hyang bertolak dari Minanga Tamwan membawa perahu armada tempur dan perlengkapan logistik perang dalam misi suci maritim.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '19 MEI 682 M · 11:00 WIB',
        title: 'Tiba di Mukha Upang dan Penaklukan Wilayah',
        desc:
            'Armada Sriwijaya mendarat di Mukha Upang dan berhasil mengamankan stabilitas rute sungai strategis di lembah Musi.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '16 JUNI 682 M · 09:00 WIB',
        title: 'Pemahatan Prasasti Batu di Kedukan Bukit',
        desc:
            'Dapunta Hyang menitahkan para juru pahat kerajaan menuliskan piagam kemenangan dan pendirian wanua Sriwijaya di atas batu sungai.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 3. PEMBEBASAN SUNDA KELAPA OLEH FATAHILLAH (PERIODE: ISL / ISLAM)
  SejarahModel(
    kodeTag: 'HIS-22061527-1',
    tanggalKey: '22061527',
    urutan: 1,
    judul: 'PERANG PEMBEBASAN SUNDA KELAPA OLEH FATAHILLAH',
    subtitle: '22.06.1527 · Pengusiran Armada Portugis dan Penetapan Nama Jayakarta',
    ringkasan:
        'Pertempuran memperebutkan pelabuhan Sunda Kelapa mencapai puncaknya pada 22 Juni 1527. Konflik ini berakar dari perjanjian persahabatan antara Kerajaan Pajajaran dan pihak Portugis di Malaka pada tahun 1522, yang mengizinkan bangsa Eropa tersebut mendirikan loji dagang dan benteng pertahanan di muara Sungai Ciliwung demi membendung ekspansi politik kesultanan-kesultanan Islam di Pulau Jawa.\n\nSultan Trenggana dari Kesultanan Demak memandang aliansi militer Pajajaran-Portugis sebagai ancaman langsung terhadap kedaulatan Nusantara. Oleh karena itu, diutuslah bala tentara gabungan Demak dan Cirebon di bawah pimpinan panglima perang ulung, Fatahillah (Fadhillah Khan). Ketika armada kapal perang Portugis pimpinan Laksamana Francisco de Sá berlabuh di Sunda Kelapa tanpa menyadari pelabuhan telah dikuasai laskar Demak, pertempuran laut dan pantai meletus dengan hebat.\n\nPasukan gabungan Islam berhasil memukul mundur serdadu Portugis, menghancurkan kapal-kapal mereka, dan menggagalkan ambisi kolonialisme Eropa di barat Jawa. Usai kemenangan mutlak tersebut, Fatahillah secara resmi mengganti nama Sunda Kelapa menjadi Jayakarta yang bermakna “Kemenangan yang Sempurna”—peristiwa yang kelak diabadikan sebagai hari lahir Kota Jakarta.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018626/renjana/sejarah/pembebasan_sunda_kelapa_cover.jpg',
    provinsi: 'DKI Jakarta',
    periode: 'ISL',
    jenisPeristiwa: 'PRG',
    detailPeristiwa: {
      'pihakTerlibat': [
        'Laskar Gabungan Kesultanan Demak dan Cirebon (pimpinan Fatahillah)',
        'Armada Kerajaan Portugis (pimpinan Francisco de Sá)',
      ],
      'lokasi': 'Muara Sungai Ciliwung, Pelabuhan Sunda Kelapa',
      'hasil':
          'Kemenangan mutlak laskar Fatahillah; Portugis terusir dan nama Sunda Kelapa resmi diubah menjadi Jayakarta.',
      'korban':
          'Puluhan awak kapal Portugis tewas karam; sisa armada Portugis lari mundur menuju Malaka.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '01 JANUARI 1527 · 07:00 WIB',
        title: 'Pemberangkatan Pasukan Gabungan dari Cirebon',
        desc:
            'Fatahillah memimpin ribuan prajurit gabungan Demak-Cirebon bergerak melalui pesisir utara menuju pelabuhan Sunda Kelapa.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '22 JUNI 1527 · 08:00 WIB',
        title: 'Serbuan Mendadak terhadap Armada Portugis',
        desc:
            'Kapal-kapal perang pimpinan Francisco de Sá disergap artileri meriam laskar pesisir saat mendekati muara pelabuhan.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '22 JUNI 1527 · 16:00 WIB',
        title: 'Deklarasi Pendirian Jayakarta',
        desc:
            'Fatahillah memimpin sujud syukur atas kemenangan penuh dan memproklamasikan nama baru pelabuhan menjadi Jayakarta.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 4. PENANDATANGANAN PERJANJIAN GIYANTI (PERIODE: KLN / KOLONIAL - TAMBAHAN 1)
  SejarahModel(
    kodeTag: 'HIS-13021755-1',
    tanggalKey: '13021755',
    urutan: 1,
    judul: 'PENANDATANGANAN PERJANJIAN GIYANTI',
    subtitle: '13.02.1755 · Pembagian Kerajaan Mataram Islam Menjadi Dua Wangsa Monarki',
    ringkasan:
        'Perjanjian Giyanti disahkan pada tanggal 13 Februari 1755 di Desa Giyanti (kini Dukuh Kerten, Kelurahan Jantiharjo, Karanganyar). Perjanjian diplomatik ini dimediasi oleh pejabat VOC, Nicolaas Hartingh, guna mengakhiri perang saudara perebutan takhta Kesultanan Mataram yang telah menguras kas kompeni Belanda selama lebih dari satu dekade.\n\nKonflik bermula dari perlawanan sengit Pangeran Mangkubumi dan Raden Mas Said (Pangeran Sambernyawa) terhadap Sunan Pakubuwana II yang dinilai tunduk pada dominasi kolonial VOC. Menyadari ketidakmampuannya menumpas kekuatan militer Mangkubumi di medan laga, Gubernur VOC di Semarang mengambil siasat diplomasi adu domba (*devide et impera*) dengan menawarkan perdamaian separatis kepada sang pangeran.\n\nBerdasarkan traktat Giyanti, wangsa Mataram secara yuridis dibelah menjadi dua entitas monarki: belahan barat diserahkan kepada Pangeran Mangkubumi yang dinobatkan sebagai Sri Sultan Hamengkubuwana I (Kasultanan Ngayogyakarta Hadiningrat), sedangkan belahan timur tetap di bawah kekuasaan Sunan Pakubuwana III (Kasunanan Surakarta Hadiningrat). Perjanjian ini menandai berakhirnya keutuhan kedaulatan Mataram di bawah bayang-bayang intervensi Belanda.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018627/renjana/sejarah/perjanjian_giyanti_cover.jpg',
    provinsi: 'Jawa Tengah',
    periode: 'KLN',
    jenisPeristiwa: 'PRJ',
    detailPeristiwa: {
      'tempat': 'Desa Giyanti, Karesidenan Surakarta (kini Kabupaten Karanganyar, Jawa Tengah)',
      'penandatangan': [
        'Pangeran Mangkubumi (Sri Sultan Hamengkubuwana I)',
        'Gubernur VOC untuk Pantai Timur Jawa (Nicolaas Hartingh)',
        'Sunan Pakubuwana III (Kasunanan Surakarta)',
      ],
      'isiPokok':
          'Pembelahan wilayah Kerajaan Mataram menjadi Kasunanan Surakarta dan Kasultanan Ngayogyakarta Hadiningrat serta pengakuan monopoli dagang VOC.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '22 SEPTEMBER 1754 · 10:00 WIB',
        title: 'Perundingan Pendahuluan di Pedagangan',
        desc:
            'Nicolaas Hartingh bertemu diam-diam dengan Pangeran Mangkubumi untuk menyusun konsesi pembagian takhta tanah Mataram.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '13 FEBRUARI 1755 · 11:30 WIB',
        title: 'Penandatanganan Naskah Traktat Perdamaian',
        desc:
            'Mangkubumi dan delegasi VOC membubuhkan tanda tangan resmi di hadapan para saksi keraton di pesanggrahan Giyanti.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '15 FEBRUARI 1755 · 09:00 WIB',
        title: 'Proklamasi Hamengkubuwana I di Jatingaleh',
        desc:
            'Pangeran Mangkubumi secara terbuka mendeklarasikan dirinya bertakhta dengan gelar Sampeyan Dalem Ingkang Sinuwun Kanjeng Sultan Hamengkubuwana I.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 5. PELEPASAN PERANG DIPONEGORO DI TEGALREJO (PERIODE: KLN / KOLONIAL - TAMBAHAN 2)
  SejarahModel(
    kodeTag: 'HIS-20071825-1',
    tanggalKey: '20071825',
    urutan: 1,
    judul: 'PELEPASAN PERANG DIPONEGORO DI TEGALREJO',
    subtitle: '20.07.1825 · Meletusnya Perang Jawa Menentang Tirani Kolonial Belanda',
    ringkasan:
        'Pengepungan kediaman Bendara Pangeran Harya Diponegoro di Tegalrejo, Yogyakarta, pada tanggal 20 Juli 1825 menjadi percikan api yang menyulut Perang Jawa (1825–1830). Amarah sang pangeran tersulut oleh kesewenang-wenangan Residen Belanda A.H. Smissaert dan Patih Danureja IV yang memancang tonggak-tonggak patok pembangunan jalan melintasi tanah pemakaman leluhur Diponegoro tanpa izin.\n\nPemerintah kolonial Hindia Belanda mengerahkan pasukan gabungan kavaleri dan infanteri KNIL untuk menangkap Pangeran Diponegoro secara paksa. Pangeran bersama pamannya, Pangeran Mangkubumi, serta para santri dan pengikut setianya berhasil meloloskan diri dari kepungan api serdadu Belanda dengan menjebol tembok belakang puri Tegalrejo menuju perbukitan Selarong.\n\nDari Selarong, Pangeran Diponegoro mendeklarasikan perang suci (Perang Sabil) melawan penindasan penjajah. Konflik ini membakar seluruh Jawa Tengah dan Timur selama lima tahun berturut-turut, merenggut ratusan ribu korban jiwa, dan menjadi salah satu perang paling mahal serta mematikan yang pernah dihadapi pemerintah kolonial Belanda.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018629/renjana/sejarah/perang_diponegoro_cover.jpg',
    provinsi: 'D.I. Yogyakarta',
    periode: 'KLN',
    jenisPeristiwa: 'PRG',
    detailPeristiwa: {
      'pihakTerlibat': [
        'Laskar Pejuang Pangeran Diponegoro (Bangsawan Keraton, Santri, dan Rakyat Jawa)',
        'Tentara Kolonial Hindia Belanda (KNIL) dan Pasukan Patih Danureja IV',
      ],
      'lokasi': 'Puri Tegalrejo, Yogyakarta',
      'hasil':
          'Kediaman Tegalrejo dibakar Belanda, namun Pangeran Diponegoro lolos ke Gua Selarong untuk mendirikan markas komando gerilya.',
      'korban':
          'Awal dari perang besar 5 tahun yang menewaskan 200.000 rakyat Jawa dan 15.000 serdadu militer kolonial Belanda.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '20 JULI 1825 · 14:00 WIB',
        title: 'Pengepungan Pasukan Gabungan Hindia Belanda',
        desc:
            'Serdadu berkuda Belanda dan laskar kepatihan mengepung komplek perumahan Tegalrejo dari segala penjuru.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '20 JULI 1825 · 16:30 WIB',
        title: 'Baku Tembak dan Penembusan Pagar Puri',
        desc:
            'Pangeran Diponegoro bersama pengawal intinya membalas tembakan musuh lalu menjebol dinding batu keraton sisi barat daya untuk menerobos keluar.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '21 JULI 1825 · 05:00 WIB',
        title: 'Pendirian Markas Gerilya di Selarong',
        desc:
            'Rombongan Diponegoro tiba di perbukitan kapur Gua Selarong, Bantul, dan mulai mengonsolidasikan laskar gerilya dari berbagai pelosok desa.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 6. PROKLAMASI KEMERDEKAAN INDONESIA (PERIODE: NAS / PERGERAKAN NASIONAL)
  SejarahModel(
    kodeTag: 'HIS-17081945-1',
    tanggalKey: '17081945',
    urutan: 1,
    judul: 'PROKLAMASI KEMERDEKAAN INDONESIA',
    subtitle: '17.08.1945 · Lahirnya Negara Kesatuan Republik Indonesia Merdeka dan Berdaulat',
    ringkasan:
        'Pada hari Jumat legi tanggal 17 Agustus 1945 tepat pukul 10.00 pagi di serambi depan rumah Jalan Pegangsaan Timur Nomor 56, Cikini, Jakarta Pusat, Ir. Soekarno didampingi Drs. Mohammad Hatta membacakan naskah Proklamasi Kemerdekaan Indonesia. Peristiwa ini memuncak setelah masa kekosongan kekuasaan (*vacuum of power*) pasca-menyerahnya Kekaisaran Jepang kepada tentara Sekutu dalam Perang Pasifik.\n\nNaskah proklamasi yang singkat namun berbobot historis tersebut dirumuskan pada dini hari menjelang fajar di kediaman perwira Angkatan Laut Kekaisaran Jepang, Laksamana Tadashi Maeda, di Jalan Imam Bonjol Nomor 1. Rumusan teks ditulis tangan langsung oleh Bung Karno dengan sumbangsih kalimat dari Bung Hatta dan Mr. Achmad Soebardjo, sebelum disempurnakan dan diketik bersih menggunakan mesin tik oleh Sayuti Melik.\n\nUpacara proklamasi berlangsung secara khidmat tanpa protokol megah. Usai pembacaan naskah kemerdekaan, bendera pusaka Sang Saka Merah Putih yang dijahit tangan oleh Ibu Fatmawati dikibarkan oleh Latief Hendraningrat dan Suhud Sastrokusumo, diiringi lagu kebangsaan Indonesia Raya yang dinyanyikan spontan oleh hadirin. Momen ini secara resmi merobek belenggu kolonialisme asing dan menandai berdirinya Republik Indonesia.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018631/renjana/sejarah/proklamasi_kemerdekaan_cover.jpg',
    provinsi: 'DKI Jakarta',
    periode: 'NAS',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis':
          'Ir. Soekarno dan Drs. Mohammad Hatta (disusun bersama Mr. Achmad Soebardjo, diketik oleh Sayuti Melik)',
      'tahun': '17 Agustus 1945, Pegangsaan Timur 56, Jakarta',
      'isiPokok':
          'Pernyataan kemerdekaan bangsa Indonesia serta pemindahan kekuasaan yang diselenggarakan secara saksama dan dalam tempo sesingkat-singkatnya.',
      'tempatSimpan':
          'Arsip Nasional Republik Indonesia (ANRI), Jakarta (Naskah Proklamasi Klad & Otentik)',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '17 AGUSTUS 1945 · 03:00 WIB',
        title: 'Perumusan Teks di Rumah Laksamana Maeda',
        desc:
            'Bung Karno menuliskan draf naskah di secarik kertas bersama Bung Hatta dan Achmad Soebardjo di ruang makan Maeda.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '17 AGUSTUS 1945 · 04:30 WIB',
        title: 'Pengetikan Naskah oleh Sayuti Melik',
        desc:
            'Sayuti Melik mengetik naskah proklamasi dengan sedikit perubahan kata serta ejaan, lalu ditandatangani oleh Soekarno dan Hatta atas nama bangsa Indonesia.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '17 AGUSTUS 1945 · 10:00 WIB',
        title: 'Pembacaan Teks Proklamasi di Pegangsaan Timur',
        desc:
            'Ir. Soekarno membacakan naskah kemerdekaan di hadapan rakyat, dilanjutkan pengibaran Sang Saka Merah Putih oleh Latief Hendraningrat dan Suhud.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 7. PERTEMPURAN SURABAYA (PERIODE: REV / REVOLUSI KEMERDEKAAN)
  SejarahModel(
    kodeTag: 'HIS-10111945-1',
    tanggalKey: '10111945',
    urutan: 1,
    judul: 'PERTEMPURAN SURABAYA 10 NOVEMBER 1945',
    subtitle: '10.11.1945 · Perlawanan Semesta Arek-Arek Suroboyo Menggempur Sekutu',
    ringkasan:
        'Pertempuran Surabaya yang meletus pada 10 November 1945 merupakan palagan pertempuran bersenjata paling berdarah dalam sejarah Revolusi Kemerdekaan Indonesia. Ketegangan berdarah dipicu oleh tewasnya perwira tinggi militer Inggris, Brigadir Jenderal A.W.S. Mallaby, dalam insiden baku tembak di sekitar Jembatan Merah pada 30 Oktober 1945.\n\nPengganti Mallaby, Mayor Jenderal E.C. Mansergh, mengeluarkan ultimatum sepihak yang menghina martabat rakyat Indonesia: memerintahkan seluruh laskar pejuang dan rakyat Surabaya menyerahkan senjata tanpa syarat paling lambat 10 November pukul 06.00 pagi. Ultimatum tersebut ditolak mentah-mentah oleh Gubernur Suryo bersama seluruh elemen pejuang. Melalui corong Radio Pemberontakan, orasi berapi-api Sutomo (Bung Tomo) mengumandangkan takbir dan memompa keberanian puluhan ribu pemuda untuk menyongsong serangan musuh.\n\nInggris mengerahkan armada kapal tempur Angkatan Laut, jet pengebom Mosquito RAF, tank Sherman, dan puluhan ribu serdadu terlatih. Kendati kota Surabaya luluh lantak akibat bombardemen, daya tahan pejuang republik di perkotaan selama tiga pekan mengguncang gengsi militer Britania Raya serta membuka mata dunia internasional bahwa Republik Indonesia berdiri kokoh dan siap mati demi mempertahankan kemerdekaannya.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018674/renjana/sejarah/pertempuran_surabaya_cover.jpg',
    provinsi: 'Jawa Timur',
    periode: 'REV',
    jenisPeristiwa: 'PRG',
    detailPeristiwa: {
      'pihakTerlibat': [
        'Tentara Keamanan Rakyat (TKR), Barisan Pemberontakan Rakyat Indonesia (BPRI), dan Arek-Arek Suroboyo',
        'Tentara Sekutu / Angkatan Bersenjata Kerajaan Inggris (Divisi Infanteri India ke-23 & Brigade Infanteri India ke-123)',
      ],
      'lokasi': 'Kota Surabaya, Jawa Timur',
      'hasil':
          'Sekutu menduduki reruntuhan kota setelah pertempuran sengit selama 3 minggu; heroisme rakyat mengukuhkan pengakuan kedaulatan de facto RI di mata dunia.',
      'korban':
          'Diperkirakan 6.000–16.000 pejuang dan rakyat sipil Indonesia gugur; sekitar 600–2.000 serdadu tentara Sekutu tewas dan luka-luka.',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '09 NOVEMBER 1945 · 23:00 WIB',
        title: 'Pidato Penolakan Ultimatum oleh Gubernur Suryo',
        desc:
            'Gubernur Suryo melalui siaran radio resmi menegaskan rakyat Surabaya menolak menyerah dan siap melawan agresi tentara Sekutu.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '10 NOVEMBER 1945 · 06:00 WIB',
        title: 'Serangan Udara dan Artileri Laut Sekutu',
        desc:
            'Pasukan Inggris melancarkan tembakan meriam kapal perang dan serangan bom udara serentak menghantam instalasi pertahanan kota.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '10 NOVEMBER 1945 · 08:30 WIB',
        title: 'Pekik Takbir Bung Tomo Mengudara',
        desc:
            'Bung Tomo membakar semangat tempur arek-arek Suroboyo melalui corong radio pemancar gerilya dari sudut kota.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 8. PEMBACAAN DEKRIT PRESIDEN 5 JULI 1959 (PERIODE: ORL / ORDE LAMA)
  SejarahModel(
    kodeTag: 'HIS-05071959-1',
    tanggalKey: '05071959',
    urutan: 1,
    judul: 'PEMBACAAN DEKRIT PRESIDEN 5 JULI 1959',
    subtitle: '05.07.1959 · Pembubaran Konstituante dan Pemberlakuan Kembali UUD 1945',
    ringkasan:
        'Pada hari Minggu sore tanggal 5 Juli 1959 pukul 17.00 WIB, Presiden Soekarno mengeluarkan keputusan hukum ketatanegaraan yang monumental melalui Dekrit Presiden dalam sebuah upacara resmi di hadapan Istana Merdeka, Jakarta. Tindakan darurat ini diambil setelah lembaga pembuat konstitusi, Majelis Konstituante, gagal mencapai kata sepakat mengenai dasar negara baru akibat pertentangan tajam antarblok politik parlemen.\n\nKebuntuan berkepanjangan di dalam Konstituante dipandang membahayakan keutuhan Republik yang saat itu tengah diguncang sejumlah pergolakan daerah bersenjata (PRRI/Permesta) serta instabilitas kabinet parlementer. Didukung penuh oleh Kepala Staf Angkatan Darat (KSAD) Letnan Jenderal A.H. Nasution, Bung Karno memutuskan menempuh hukum keadaan darurat negara (*staatsnoodrecht*).\n\nDekrit Presiden 5 Juli 1959 memuat tiga keputusan utama: membubarkan Konstituante, memberlakukan kembali Undang-Undang Dasar 1945 serta menyatakan tidak berlakunya lagi Undang-Undang Dasar Sementara (UUDS) 1950, dan membentuk Majelis Permusyawaratan Rakyat Sementara (MPRS) serta Dewan Pertimbangan Agung Sementara (DPAS). Dekrit ini secara resmi mengakhiri era Demokrasi Parlementer/Liberal dan membuka babak Demokrasi Terpimpin.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018676/renjana/sejarah/dekrit_presiden_1959_cover.jpg',
    provinsi: 'DKI Jakarta',
    periode: 'ORL',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis': 'Ir. Soekarno (Presiden/Panglima Tertinggi Angkatan Perang RI)',
      'tahun': '05 Juli 1959, Istana Merdeka, Jakarta',
      'isiPokok':
          'Pembubaran Konstituante, berlakunya kembali UUD 1945 dan tidak berlakunya UUDS 1950, serta pembentukan MPRS dan DPAS.',
      'tempatSimpan':
          'Arsip Nasional Republik Indonesia (ANRI), Jakarta (Naskah Asli Keputusan Presiden No. 150 Tahun 1959)',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '02 JUNI 1959 · 10:00 WIB',
        title: 'Pemungutan Suara Terakhir Konstituante Gagal',
        desc:
            'Sidang Konstituante di Bandung gagal mencapai kuorum dua pertiga suara untuk menetapkan kembali UUD 1945.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '05 JULI 1959 · 17:00 WIB',
        title: 'Pidato Pembacaan Dekrit di Istana Merdeka',
        desc:
            'Presiden Soekarno membacakan piagam Dekrit Presiden di hadapan ribuan rakyat dan jajaran menteri kabinet.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '22 JULI 1959 · 09:30 WIB',
        title: 'Dukungan Aklamasi DPR Terhadap Dekrit',
        desc:
            'Dewan Perwakilan Rakyat menyatakan persetujuannya secara aklamasi untuk terus bekerja di bawah naungan UUD 1945.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 9. PENERBITAN SUPERSEMAR (PERIODE: ORB / ORDE BARU)
  SejarahModel(
    kodeTag: 'HIS-11031966-1',
    tanggalKey: '11031966',
    urutan: 1,
    judul: 'PENERBITAN SURAT PERINTAH SEBELAS MARET',
    subtitle: '11.03.1966 · Transisi Kekuasaan Politik Nasional Menuju Rezim Orde Baru',
    ringkasan:
        'Surat Perintah Sebelas Maret (Supersemar) diterbitkan pada 11 Maret 1966 di Istana Bogor di tengah memuncaknya krisis politik dan ekonomi nasional pasca-peristiwa G30S/PKI 1965. Demonstrasi besar-besaran mahasiswa yang tergabung dalam KAMI/KAPI menuntut Tritura (Tri Tuntutan Rakyat), bersamaan dengan kepungan pasukan tanpa tanda pengenal di luar Istana Merdeka, memaksa Presiden Soekarno menyingkir ke Bogor.\n\nTiga jenderal Angkatan Darat—Brigjen M. Jusuf, Mayjen Basuki Rachmat, dan Brigjen Amir Machmud—menyusul ke Istana Bogor untuk menyampaikan pesan Menteri/Panglima Angkatan Darat Letnan Jenderal Soeharto. Usai perundingan tertutup, Presiden Soekarno menandatangani surat mandat yang memberikan wewenang kepada Letjen Soeharto untuk mengambil segala tindakan yang dianggap perlu guna memulihkan keamanan dan ketertiban umum.\n\nDengan mandat Supersemar, Letjen Soeharto bergerak cepat: sehari setelahnya, tepatnya 12 Maret 1966, Partai Komunis Indonesia (PKI) resmi dibubarkan dan dinyatakan sebagai organisasi terlarang. Surat perintah ini menjadi instrumen politik utama yang menggeser hegemoni kekuasaan Bung Karno dan meletakkan fondasi berdirinya rezim Orde Baru.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018678/renjana/sejarah/supersemar_cover.jpg',
    provinsi: 'Jawa Barat',
    periode: 'ORB',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis': 'Ir. Soekarno (Mandat ditujukan kepada Letjen Soeharto)',
      'tahun': '11 Maret 1966, Istana Bogor, Jawa Barat',
      'isiPokok':
          'Pemberian mandat wewenang kepada Letjen Soeharto untuk mengambil segala tindakan yang dianggap perlu demi kestabilan jalannya pemerintahan dan revolusi.',
      'tempatSimpan':
          'Arsip Nasional Republik Indonesia (ANRI), Jakarta (Menyimpan berbagai versi dokumen arsip)',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '11 MARET 1966 · 10:30 WIB',
        title: 'Sidang Kabinet Dwikora Dikejutkan Pasukan Liar',
        desc:
            'Presiden Soekarno meninggalkan sidang kabinet di Jakarta menuju Bogor setelah menerima laporan adanya pasukan tak dikenal mengepung istana.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '11 MARET 1966 · 19:30 WIB',
        title: 'Penandatanganan Naskah di Istana Bogor',
        desc:
            'Setelah berdiskusi alot dengan tiga jenderal utusan AD, Bung Karno menandatangani draf surat perintah pengamanan negara.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '12 MARET 1966 · 06:00 WIB',
        title: 'Pembubaran PKI Menggunakan Mandat Supersemar',
        desc:
            'Letjen Soeharto menerbitkan Keputusan Presiden No. 1/3/1966 untuk membubarkan Partai Komunis Indonesia beserta ormas-ormasnya di seluruh tanah air.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),

  // 10. PERNYATAAN BERHENTI PRESIDEN SOEHARTO (PERIODE: REF / REFORMASI)
  SejarahModel(
    kodeTag: 'HIS-21051998-1',
    tanggalKey: '21051998',
    urutan: 1,
    judul: 'PERNYATAAN BERHENTI PRESIDEN SOEHARTO',
    subtitle: '21.05.1998 · Berakhirnya 32 Tahun Rezim Orde Baru dan Kelahiran Era Reformasi',
    ringkasan:
        'Pada hari Kamis pagi, 21 Mei 1998 pukul 09.05 WIB di Credential Room Istana Merdeka, Jakarta, Presiden Soeharto secara langsung membacakan naskah pengunduran dirinya dari kursi kepresidenan Republik Indonesia. Pernyataan bersejarah ini menandai runtuhnya kekuasaan Orde Baru yang telah bertakhta selama 32 tahun, sekaligus membuka lembaran baru era Reformasi.\n\nLangkah pelepasan jabatan ini dipicu oleh krisis moneter Asia 1997 yang melumpuhkan sendi-sendi perekonomian nasional, lonjakan harga bahan pokok, serta gelombang demonstrasi mahasiswa berskala masif yang menduduki Gedung DPR/MPR RI. Tekanan kian memuncak menyusul Tragedi Trisakti pada 12 Mei, kerusuhan rasial di Jakarta, serta mundurnya 14 menteri bidang ekonomi dan industri di bawah koordinasi Ginandjar Kartasasmita pada 20 Mei malam.\n\nDengan menyatakan berhenti sebagai Presiden berdasarkan Pasal 8 UUD 1945, Soeharto menyerahkan tampuk kepemimpinan nasional kepada Wakil Presiden Prof. Dr. Ing. B.J. Habibie yang langsung diambil sumpahnya di tempat yang sama di hadapan pimpinan Mahkamah Agung. Peristiwa ini menjadi tonggak terpenting dalam demokratisasi modern Indonesia.',
    gambarUtama: 'https://res.cloudinary.com/yykabu7v/image/upload/f_auto,q_auto/v1789018682/renjana/sejarah/mundurnya_soeharto_cover.jpg',
    provinsi: 'DKI Jakarta',
    periode: 'REF',
    jenisPeristiwa: 'NSK',
    detailPeristiwa: {
      'penulis': 'H.M. Soeharto (Presiden ke-2 Republik Indonesia)',
      'tahun': '21 Mei 1998, Credential Room Istana Merdeka, Jakarta',
      'isiPokok':
          'Pernyataan resmi pengunduran diri Soeharto dari jabatan Presiden RI serta pengalihan jabatan kepala negara kepada Wapres B.J. Habibie.',
      'tempatSimpan':
          'Arsip Nasional Republik Indonesia (ANRI) / Museum Kepresidenan RI Balai Kirti, Bogor',
    },
    alurPeristiwa: [
      TimelineItemModel(
        date: '20 MEI 1998 · 20:00 WIB',
        title: 'Penolakan Masuk Kabinet oleh 14 Menteri',
        desc:
            'Sebanyak 14 menteri kabinet menandatangani surat penolakan bersama di Bappenas untuk bergabung dalam rencana Komite Reformasi bentukan Soeharto.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '21 MEI 1998 · 09:05 WIB',
        title: 'Pembacaan Pidato Pengunduran Diri di Istana Merdeka',
        desc:
            'Soeharto membacakan naskah pernyataan berhenti dari jabatan Presiden RI di hadapan puluhan wartawan dan hakim Mahkamah Agung.',
        imgPath: null,
        hasImage: false,
      ),
      TimelineItemModel(
        date: '21 MEI 1998 · 09:15 WIB',
        title: 'Pengucapan Sumpah Jabatan B.J. Habibie',
        desc:
            'B.J. Habibie mengucapkan sumpah jabatan sebagai Presiden ke-3 Republik Indonesia di depan Ketua Mahkamah Agung Sarwata.',
        imgPath: null,
        hasImage: false,
      ),
    ],
  ),
];



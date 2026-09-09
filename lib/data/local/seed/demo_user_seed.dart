import 'dart:convert';
import 'package:sqflite/sqflite.dart';

// akun demo
class DemoUserSeed {
  static const String email = 'arya.penjelajah@renjana.id';
  static const String nama = 'Arya Daniswara';
  static const String username = 'aryadaniswara';
  static const String password = 'renjana123';

  static Future<void> seedDemoUser(Database db) async {
    try {
      // cek atau buat user
      final userQuery = await db.query(
        'user',
        where: 'LOWER(email) = ? OR LOWER(username) = ?',
        whereArgs: [email.toLowerCase(), username.toLowerCase()],
        limit: 1,
      );

      int userId;
      if (userQuery.isNotEmpty) {
        userId = userQuery.first['id'] as int;
        await db.update(
          'user',
          {
            'nama': nama,
            'username': username,
            'password': password,
            'role': 'user',
          },
          where: 'id = ?',
          whereArgs: [userId],
        );
      } else {
        userId = await db.insert('user', {
          'nama': nama,
          'username': username,
          'email': email,
          'password': password,
          'fotoProfil': null,
          'role': 'user',
        });
      }

      final kini = DateTime.now();
      final msKini = kini.millisecondsSinceEpoch;

      // 2. Kunjungan / Streak 35 Hari Berturut-turut sampai Hari Ini
      for (int i = 34; i >= 0; i--) {
        final d = kini.subtract(Duration(days: i));
        final bulan = d.month.toString().padLeft(2, '0');
        final hari = d.day.toString().padLeft(2, '0');
        final tanggalKey = '${d.year}-$bulan-$hari';

        await db.insert(
          'kunjungan',
          {
            'userId': userId,
            'userEmail': email,
            'tanggal': tanggalKey,
            'beku': 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 3. Rekap dan Rekor Kuis
      await db.insert(
        'kuis_rekap',
        {
          'userId': userId,
          'percobaan': 24,
          'totalSoal': 240,
          'totalBenar': 232,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final daftarRekorKuis = [
        {
          'tema': 'Rumah Adat Nusantara',
          'kategori': 'Budaya',
          'subKategori': 'Arsitektur',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 42,
        },
        {
          'tema': 'Tokoh Perjuangan Kemerdekaan',
          'kategori': 'Sejarah',
          'subKategori': 'Kemerdekaan',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 38,
        },
        {
          'tema': 'Senjata Tradisional Nusantara',
          'kategori': 'Budaya',
          'subKategori': 'Pusaka',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 48,
        },
        {
          'tema': 'Seni Tari 38 Provinsi',
          'kategori': 'Budaya',
          'subKategori': 'Tarian',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 40,
        },
        {
          'tema': 'Kerajaan Kuno Nusantara',
          'kategori': 'Sejarah',
          'subKategori': 'Kerajaan',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 52,
        },
        {
          'tema': 'Pakaian & Wastra Nusantara',
          'kategori': 'Budaya',
          'subKategori': 'Busana',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 45,
        },
        {
          'tema': 'Alat Musik Tradisional',
          'kategori': 'Budaya',
          'subKategori': 'Musik',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 39,
        },
        {
          'tema': 'Kuliner & Makanan Khas Daerah',
          'kategori': 'Budaya',
          'subKategori': 'Kuliner',
          'jumlahSoal': 10,
          'benar': 10,
          'salah': 0,
          'detik': 35,
        },
      ];

      for (int i = 0; i < daftarRekorKuis.length; i++) {
        final item = daftarRekorKuis[i];
        final waktuSelesai = msKini - (i * 86400000);

        await db.insert(
          'kuis_rekor',
          {
            'userId': userId,
            'tema': item['tema'],
            'kategori': item['kategori'],
            'subKategori': item['subKategori'],
            'jumlahSoal': item['jumlahSoal'],
            'benar': item['benar'],
            'salah': item['salah'],
            'detik': item['detik'],
            'selesaiPada': waktuSelesai,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await db.insert(
          'kuis_riwayat',
          {
            'userId': userId,
            'userEmail': email,
            'tema': item['tema'],
            'kategori': item['kategori'],
            'subKategori': item['subKategori'],
            'jumlahSoal': item['jumlahSoal'],
            'benar': item['benar'],
            'salah': item['salah'],
            'detik': item['detik'],
            'selesaiPada': waktuSelesai,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 4. Usulan / Kontribusi Konten (5 Disetujui, 2 Menunggu)
      final usulanList = [
        {
          'jenis': 'budaya',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Riau',
          'judul': 'Tari Zapin Tradisional',
          'isi': jsonEncode({
            'kategori': 'TAR',
            'judul': 'Tari Zapin Tradisional',
            'tagline': 'Tarian rumpun Melayu penuh kesantunan dan ritme marwas.',
            'deskripsi':
                'Tari Zapin adalah khazanah tarian Melayu yang mengutamakan kelincahan gerak kaki dan harmoni nada petikan gambus.',
          }),
          'status': 'disetujui',
          'catatanAdmin': 'Materi sangat lengkap dan sesuai dengan kaidah PPKD.',
          'kodeTagHasil': 'BUD-TAR-12',
          'dibuatPada': msKini - 86400000 * 20,
          'diperbaruiPada': msKini - 86400000 * 18,
        },
        {
          'jenis': 'budaya',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Sumatera Selatan',
          'judul': 'Rumah Limas Palembang',
          'isi': jsonEncode({
            'kategori': 'RMH',
            'judul': 'Rumah Limas Palembang',
            'tagline': 'Arsitektur bertingkat kekijing simbol strata kearifan lokal.',
            'deskripsi':
                'Rumah Limas mencerminkan keagungan arsitektur tradisional Sumatera Selatan dengan ornamen ukiran emas khas Palembang.',
          }),
          'status': 'disetujui',
          'catatanAdmin': 'Telah diverifikasi dan diterbitkan.',
          'kodeTagHasil': 'BUD-RMH-14',
          'dibuatPada': msKini - 86400000 * 16,
          'diperbaruiPada': msKini - 86400000 * 14,
        },
        {
          'jenis': 'budaya',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Kalimantan Selatan',
          'judul': 'Kain Sasirangan Khas Banjar',
          'isi': jsonEncode({
            'kategori': 'PAK',
            'judul': 'Kain Sasirangan Khas Banjar',
            'tagline': 'Wastra jelujur dengan ragam motif magis dan filosofi luhur.',
            'deskripsi':
                'Sasirangan adalah kain adat suku Banjar yang dibuat melalui teknik perintangan jelujur dengan aneka warna alami.',
          }),
          'status': 'disetujui',
          'catatanAdmin': 'Deskripsi sangat mendalam.',
          'kodeTagHasil': 'BUD-PAK-15',
          'dibuatPada': msKini - 86400000 * 12,
          'diperbaruiPada': msKini - 86400000 * 10,
        },
        {
          'jenis': 'sejarah',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Bali',
          'judul': 'Puputan Margarana 1946',
          'isi': jsonEncode({
            'judul': 'Puputan Margarana 1946',
            'subtitle': 'Perjuangan Habis-habisan Pasukan Ciung Wanara',
            'tanggalKey': '20.11.46',
            'ringkasan':
                'Pertempuran heroik I Gusti Ngurah Rai bersama pasukan Ciung Wanara mempertahankan kemerdekaan di tanah Tabanan Bali.',
          }),
          'status': 'disetujui',
          'catatanAdmin': 'Data sejarah tervalidasi.',
          'kodeTagHasil': 'HIS-20.11.46-1',
          'dibuatPada': msKini - 86400000 * 8,
          'diperbaruiPada': msKini - 86400000 * 6,
        },
        {
          'jenis': 'budaya',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Nusa Tenggara Timur',
          'judul': 'Alat Musik Tradisional Sasando',
          'isi': jsonEncode({
            'kategori': 'MSK',
            'judul': 'Alat Musik Tradisional Sasando',
            'tagline': 'Petikan dawai bambu berpadu keanggunan daun lontar.',
            'deskripsi':
                'Sasando merupakan instrumen musik petik berdawai asal Pulau Rote dengan resonator alami dari anyaman daun lontar.',
          }),
          'status': 'disetujui',
          'catatanAdmin': 'Disetujui untuk terbit.',
          'kodeTagHasil': 'BUD-MSK-10',
          'dibuatPada': msKini - 86400000 * 5,
          'diperbaruiPada': msKini - 86400000 * 4,
        },
        {
          'jenis': 'budaya',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Jawa Barat',
          'judul': 'Upacara Adat Seren Taun Kasepuhan',
          'isi': jsonEncode({
            'kategori': 'UPC',
            'judul': 'Upacara Adat Seren Taun Kasepuhan',
            'tagline': 'Rasa syukur panen padi masyarakat adat agraris Sunda.',
            'deskripsi':
                'Seren Taun adalah upacara penyerahan hasil panen padi ke leuit adat sebagai wujud syukur dan pelestarian ketahanan pangan.',
          }),
          'status': 'menunggu',
          'catatanAdmin': '',
          'kodeTagHasil': '',
          'dibuatPada': msKini - 86400000 * 2,
          'diperbaruiPada': msKini - 86400000 * 2,
        },
        {
          'jenis': 'sejarah',
          'maksud': 'baru',
          'targetKodeTag': '',
          'provinsi': 'Jambi',
          'judul': 'Kompleks Percandian Muaro Jambi',
          'isi': jsonEncode({
            'judul': 'Kompleks Percandian Muaro Jambi',
            'subtitle': 'Pusat Peradaban dan Pendidikan Buddha Kuno',
            'tanggalKey': '01.07.07',
            'ringkasan':
                'Kompleks percandian bata merah terluas di Asia Tenggara peninggalan Kerajaan Melayu Kuno dan Sriwijaya.',
          }),
          'status': 'menunggu',
          'catatanAdmin': '',
          'kodeTagHasil': '',
          'dibuatPada': msKini - 86400000 * 1,
          'diperbaruiPada': msKini - 86400000 * 1,
        },
      ];

      // Bersihkan usulan demo lama agar tidak dobel
      await db.delete('usulan', where: 'userId = ?', whereArgs: [userId]);
      for (final u in usulanList) {
        await db.insert('usulan', {
          'userId': userId,
          'jenis': u['jenis'],
          'maksud': u['maksud'],
          'targetKodeTag': u['targetKodeTag'],
          'provinsi': u['provinsi'],
          'judul': u['judul'],
          'isi': u['isi'],
          'status': u['status'],
          'catatanAdmin': u['catatanAdmin'],
          'kodeTagHasil': u['kodeTagHasil'],
          'dibuatPada': u['dibuatPada'],
          'diperbaruiPada': u['diperbaruiPada'],
        });
      }

      // 5. Arsip yang Dibaca (58 Arsip lintas berbagai Provinsi)
      await db.delete('arsip_dibaca', where: 'userId = ?', whereArgs: [userId]);
      final semuaBudaya = await db.query('budaya', columns: ['kodeTag']);
      final semuaSejarah = await db.query('sejarah', columns: ['kodeTag']);

      int hitungDibaca = 0;
      for (final b in semuaBudaya) {
        final kode = b['kodeTag'] as String?;
        if (kode != null && kode.isNotEmpty) {
          await db.insert(
            'arsip_dibaca',
            {
              'userId': userId,
              'ref': 'budaya|$kode',
              'dibacaPada': msKini - (hitungDibaca * 3600000),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          hitungDibaca++;
        }
      }

      for (final s in semuaSejarah) {
        final kode = s['kodeTag'] as String?;
        if (kode != null && kode.isNotEmpty) {
          await db.insert(
            'arsip_dibaca',
            {
              'userId': userId,
              'ref': 'sejarah|$kode',
              'dibacaPada': msKini - (hitungDibaca * 3600000),
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          hitungDibaca++;
        }
      }

      // 6. Lencana Terbuka (20 Lencana -> Gelar Sejarawan)
      // 3 Lencana Disematkan (disematkan = 1)
      final lencanaTerbuka = [
        {'kode': 'RTN-30', 'disematkan': 1}, // Sebulan Setia (Pin 1)
        {'kode': 'KUS-5', 'disematkan': 1}, // Lima Tema Sempurna (Pin 2)
        {'kode': 'KTB-5', 'disematkan': 1}, // Penjaga Warisan (Pin 3)
        {'kode': 'RTN-3', 'disematkan': 0},
        {'kode': 'RTN-7', 'disematkan': 0},
        {'kode': 'KUS-1', 'disematkan': 0},
        {'kode': 'ARS-10', 'disematkan': 0},
        {'kode': 'ARS-25', 'disematkan': 0},
        {'kode': 'ARS-50', 'disematkan': 0},
        {'kode': 'KTB-1', 'disematkan': 0},
        {'kode': 'KAT-PAK', 'disematkan': 0},
        {'kode': 'KAT-RMH', 'disematkan': 0},
        {'kode': 'KAT-TAR', 'disematkan': 0},
        {'kode': 'KAT-SNJ', 'disematkan': 0},
        {'kode': 'KAT-MSK', 'disematkan': 0},
        {'kode': 'KAT-UPC', 'disematkan': 0},
        {'kode': 'KAT-KUL', 'disematkan': 0},
        {'kode': 'KAT-KSN', 'disematkan': 0},
        {'kode': 'PLU-sumatera', 'disematkan': 0},
        {'kode': 'PLU-jawa', 'disematkan': 0},
        {'kode': 'PLU-bali_nusa_tenggara', 'disematkan': 0},
        {'kode': 'PLU-sulawesi', 'disematkan': 0},
      ];

      for (final l in lencanaTerbuka) {
        await db.insert(
          'lencana',
          {
            'userId': userId,
            'userEmail': email,
            'kode': l['kode'],
            'dibukaPada': msKini - 86400000 * 5,
            'disematkan': l['disematkan'],
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (_) {}
  }
}

# Google Play Store Listing – Renjana (Online via Google Firebase)

Dokumen ini berisi seluruh materi teks yang siap digunakan untuk publikasi aplikasi **Renjana** di **Google Play Console** dengan integrasi backend **Google Firebase**.

---

## 1. Judul Aplikasi (App Title)
> **Batas Google Play: Maksimal 30 Karakter**

- **Pilihan Utama (28 Karakter):** `Renjana: Museum & Budaya ID`
- **Alternatif 1 (24 Karakter):** `Renjana - Budaya Indonesia`
- **Alternatif 2 (27 Karakter):** `Renjana: Sejarah & Budaya ID`

---

## 2. Deskripsi Singkat (Short Description)
> **Batas Google Play: Maksimal 80 Karakter**

- **Pilihan 1 (Rekomendasi - 79 Karakter):**
```text
Jelajahi museum, sejarah, dan kekayaan budaya Nusantara dalam satu genggaman!
```

- **Pilihan 2 (78 Karakter):**
```text
Platform digital budaya & sejarah Indonesia: peta, kuis, dan komunitas online.
```

- **Pilihan 3 (79 Karakter):**
```text
Eksplorasi ragam budaya, sejarah nusantara, peta 38 provinsi & kuis interaktif.
```

---

## 3. Deskripsi Lengkap (Full Description)
> **Batas Google Play: Maksimal 4.000 Karakter** *(Teks di bawah ini: ~3.050 Karakter)*

```text
🏛️ RENJANA — Museum Digital & Ensiklopedia Budaya Indonesia

Renjana adalah platform digital edukasi kebudayaan dan sejarah nusantara berbasis daring (online) yang dirancang interaktif, modern, dan informatif. Dari Sabang sampai Merauke, jelajahi ribuan warisan leluhur bangsa, peristiwa bersejarah, keunikan adat istiadat 38 provinsi, komunitas pegiat budaya, serta asah wawasan lewat kuis budaya interaktif!

Didukung sistem cloud yang cepat dan andal, seluruh progres belajar, koleksi artikel, skor kuis, dan keaktifan komunitas Anda tersinkronisasi secara aman di mana saja dan kapan saja.

✨ FITUR-FITUR UNGGULAN RENJANA:

📖 1. Sorotan Sejarah & Budaya Harian (Realtime Updates)
Dapatkan fakta unik, ulasan sejarah, dan artikel kebudayaan nusantara pilihan yang diperbarui setiap hari secara daring untuk menambah wawasan literasi kebangsaan Anda.

🎭 2. Katalog 8 Kategori Budaya Terlengkap
Temukan khazanah kekayaan Indonesia yang terstruktur rapi dan terus diperbarui:
• Rumah & Arsitektur Adat Nusantara
• Pakaian & Wastra Tradisional
• Seni Tari & Pertunjukan Daerah
• Senjata Tradisional & Pusaka Bersejarah
• Alat Musik Tradisional
• Upacara, Ritual & Tradisi Adat
• Kuliner Khas Daerah
• Kesenian Daerah & Kerajinan Tangan

📜 3. Garis Waktu Sejarah Nusantara (Interactive Timeline)
Pelajari rekaman jejak sejarah Indonesia secara kronologis, mulai dari masa kerajaan kuno, era kolonial, perjuangan kemerdekaan, hingga era modern yang disajikan dengan visual menarik dan narasi yang mudah dipahami.

🗺️ 4. Peta Budaya Digital 38 Provinsi
Jelajahi peta interaktif seluruh wilayah kepulauan Indonesia: Pulau Sumatera, Jawa, Kalimantan, Sulawesi, Bali, Nusa Tenggara, Maluku, hingga Papua. Temukan ciri khas adat dan kebudayaan di tiap daerah dengan satu sentuhan.

🎯 5. Kuis Budaya Online & Pembahasan Lengkap
Uji dan tingkatkan pemahaman Anda melalui kuis budaya bertingkat! Dilengkapi pembahasan jawaban komprehensif, penghitungan skor, dan pelacakan riwayat capaian belajar.

🔥 6. Sinkronisasi Akun, Runtun Belajar (Streak) & Lencana Prestasi
Bangun kebiasaan belajar setiap hari! Progres belajar, runtun kehadiran (streak), dan lencana penghargaan (achievements) Anda tersimpan aman dan tersinkronisasi otomatis di akun cloud Anda.

👥 7. Forum Komunitas & Ruang Kontribusi Budaya
Terhubung dengan sesama pelajar, mahasiswa, peneliti, dan pecinta budaya nusantara. Bagikan ulasan, ajukan diskusi menarik, dan berkontribusi melestarikan informasi budaya lokal Anda.

📌 8. Koleksi & Bookmark Tersinkronisasi
Simpan artikel dan materi budaya favorit Anda ke dalam akun agar dapat dibaca kembali kapan saja di berbagai perangkat.

📍 9. Direktori Destinasi Wisata & Cagar Budaya
Temukan panduan dan profil museum, candi, monumen, serta situs cagar budaya di seluruh penjuru Indonesia lengkap dengan latar belakang sejarahnya.

🌟 COCOK UNTUK:
• Pelajar SD, SMP, SMA/SMK & Mahasiswa untuk bahan belajar, referensi, dan tugas sekolah/kuliah.
• Guru & Pendidik sebagai sarana media pembelajaran interaktif di kelas.
• Komunitas & Pecinta Budaya yang ingin mendalami dan melestarikan kekayaan bangsa.
• Wisatawan yang ingin mengenal tradisi lokal daerah destinasi wisata Indonesia.

Mari bersama-sama merawat, mencintai, dan melestarikan warisan adiluhung nusantara melalui teknologi digital.

Unduh Renjana sekarang dan rasakan pengalaman menjelajahi museum nusantara dalam satu genggaman! 🇮🇩
```

---

## 4. Panduan Data Safety Google Play (Khusus Integrasi Firebase)

Panduan saat mengisi formulir **Data Safety** di Google Play Console:

| Pertanyaan Google Play | Jawaban yang Tepat |
|---|---|
| **Apakah aplikasi mengumpulkan data pengguna?** | **Ya** |
| **Apakah data ditransfer melalui koneksi terenkripsi?** | **Ya** (Enkripsi HTTPS/TLS oleh Google Firebase) |
| **Apakah pengguna dapat meminta penghapusan data?** | **Ya** (Melalui menu Profil aplikasi atau permohonan via email pengembang) |
| **Data Pribadi (Personal Info):** | • **Nama:** Untuk profil & tampilan akun.<br>• **Email:** Untuk login via Firebase Auth & pemulihan akun.<br>• **User IDs:** Pengenal Firebase User ID (UID). |
| **Aktivitas Aplikasi (App Activity):** | Riwayat kuis, bookmark tersimpan, runtun belajar harian, dan interaksi komunitas. |
| **Foto dan Video (Photos and Videos):** | Opsional, hanya jika pengguna mengunggah foto profil atau foto kontribusi budaya ke Cloud Storage. |
| **Info Diagnostik & Performa (Diagnostics):** | Crash logs & diagnostic data (Firebase Crashlytics / Performance). |
| **Tujuan Pengumpulan Data:** | • *App Functionality* (Fungsi Aplikasi)<br>• *Account Management* (Pengelolaan Akun Pengguna)<br>• *Analytics & Performance Improvement* |
| **Pelacakan Komersial / Iklan Pihak Ketiga:** | **Tidak Ada** (Data tidak dijual ke broker data atau pengiklan pihak ketiga). |

<div align="center">

  <img src="assets/images/Rlogos.png" alt="Renjana Logo" width="120" />
  
  # RENJANA
  ### *Indonesia Dalam Genggaman*

  **Platform Eksplorasi Digital, Ensiklopedia Budaya, Linimasa Sejarah, dan Komunitas Pelestari Warisan Nusantara.**

  ---

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
  [![Cloudinary](https://img.shields.io/badge/Cloudinary-3448C5?style=for-the-badge&logo=cloudinary&logoColor=white)](https://cloudinary.com/)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)]()

</div>

---

## 📌 Tentang Renjana

**Renjana** adalah aplikasi mobile inovatif yang didedikasikan untuk mendokumentasikan, merayakan, dan melestarikan kekayaan budaya serta sejarah bangsa Indonesia. Mengusung filosofi desain warisan nusantara yang dipadukan dengan standar estetika antarmuka modern, Renjana mengajak generasi muda menjelajahi 38 provinsi di Indonesia melalui pengalaman visual yang kaya, interaktif, dan tergamifikasi.

---

## ✨ Fitur Unggulan

### 🏛️ 1. Ensiklopedia Budaya & Sejarah Komprehensif
* **Warisan Budaya**: Dokumentasi mendalam tentang Rumah Adat, Senjata Tradisional, Tarian, Alat Musik, Kuliner Khas, hingga Destinasi Budaya dengan nilai spiritual dan filosofis.
* **Linimasa Sejarah Interaktif**: Kronologi peristiwa bersejarah Indonesia yang disusun runtut berdasarkan era (Pra-aksara, Kerajaan Hindu-Buddha, Kesultanan Islam, Kolonialisme, Kemerdekaan, hingga Era Modern).
* **Dukungan Multimedia**: Integrasi visual resolusi tinggi, video dokumenter, serta pemutaran langsung materi YouTube terkait.

### 🗺️ 2. Peta Vektor Interaktif Nusantara
* **Eksplorasi Gugus Kepulauan**: Navigasi visual pulau-pulau besar (Sumatera, Jawa, Kalimantan, Sulawesi, Bali & Nusa Tenggara, Maluku & Papua) menggunakan kanvas vektor kustom (*CustomPainter*).
* **Indikator Penuntasan Wilayah**: Pelacakan status eksplorasi provinsi (*Belum Dijelajahi*, *Tuntas*, hingga *Dikuasai*) berdasarkan keaktifan membaca arsip dari daerah terkait.

### 🏆 3. Gamifikasi & Sistem Literasi
* **Pencatat Durasi Baca (*Reading Tracker*)**: Validasi durasi membaca minimum (10 detik per arsip) sebelum arsip dinyatakan tuntas dibaca guna mendorong literasi nyata.
* **Runtun Harian (*Daily Streaks*)**: Menghitung konsistensi kunjungan harian pengguna yang diperkuat notifikasi pengingat malam hari (19:00 WIB).
* **Katalog Lencana & Gelar Pengguna**: Sistem pencapaian bertingkat (perunggu, perak, emas) untuk membuka gelar prestisius: *Pelajar*, *Penjelajah*, *Kurator*, hingga *Sejarawan*.

### 💬 4. Forum Komunitas Nusantara
* **Ruang Diskusi Terbuka**: Wadah tanya-jawab dan bertukar wawasan seputar kebudayaan dan sejarah lokal.
* **Fitur Modern**: Dukungan sistem *Upvoting*, balasan berantai (*threaded replies*), pelaporan pelanggaran konten (*reporting*), serta *smart mention* (@username).

### ✍️ 5. Partisipasi Publik (*Crowdsourcing & Koreksi*)
* **Pengajuan Usulan Baru**: Pengguna dapat mengusulkan arsip budaya atau sejarah baru dari daerah masing-masing.
* **Koreksi Data Arsip**: Pengguna dapat menyarankan pembaruan atau meluruskan informasi pada arsip yang sudah ada dengan fitur komparasi revisi (*diff view*).
* **Editor Blok Konten Dinamis**: Penyusunan konten fleksibel dengan paragraf, galeri foto, kutipan, dan butir informasi.

### 🛡️ 6. Panel Manajemen Administrator (Mobile CMS)
* Menu khusus admin (*Admin Drawer*) untuk mengelola arsip langsung dari aplikasi.
* Tinjauan dan moderasi usulan kontribusi publik (Setujui, Minta Revisi, Tolak).
* Moderasi laporan komunitas dan pengelolaan kategori serta foto wilayah.

---

## 🛠️ Tumpukan Teknologi (Tech Stack)

| Komponen | Teknologi | Keterangan |
| :--- | :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (v3.x / Dart v3.12+) | Cross-platform mobile development |
| **Backend & Database** | [Cloud Firestore](https://firebase.google.com/docs/firestore) | Basis data NoSQL realtime dengan offline persistence |
| **Autentikasi** | [Firebase Authentication](https://firebase.google.com/docs/auth) | Manajemen login, registrasi, sesi, & pemulihan sandi |
| **Media Hosting** | [Cloudinary REST API](https://cloudinary.com/) | Penyimpanan media dengan optimasi kompresi `f_auto,q_auto` & SHA-1 signature |
| **Local Storage** | [Shared Preferences](https://pub.dev/packages/shared_preferences) | Caching sesi lokal pengguna & preferensi aplikasi |
| **Notifikasi** | [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications) | Notifikasi pengingat eksplorasi harian berbasis zona waktu WIB |
| **Tipografi & Desain** | Google Fonts (*Plus Jakarta Sans*), Lottie | Tipografi humanis & animasi interaktif |

---

## 📐 Arsitektur & Struktur Direktori

Proyek ini menerapkan pendekatan **Feature-First Architecture** yang modular, memudahkan skalabilitas, pemeliharaan, serta pemisahan tanggung jawab (*Separation of Concerns*):

```text
lib/
├── app/                       # Konfigurasi routing global & navigasi arsip polimorfik
│   └── routes/                # Observer rute & dispatcher pembuka arsip
├── core/                      # Fondasi bersama lintas modul
│   ├── constants/             # Token warna (#C9362B terakota), tipografi, tema, & katalog
│   ├── extensions/            # Ekstensi navigasi & konteks
│   ├── services/              # Cloudinary, FirebaseAuth, Seeder latar belakang, & Notifikasi
│   ├── storage/               # PreferenceHandler & manajemen sesi lokal
│   ├── utils/                 # Image picker, map launcher, & share helper
│   └── widgets/               # Komponen UI umum (AppImage, MediaArsip, IndikatorBaca, dll.)
├── data/
│   └── local/seed/            # Data seed awal ensiklopedia lokal (Budaya & Sejarah)
├── features/                  # Modul-modul fitur mandiri (Data, Models, Presentation, Repositories)
│   ├── admin/                 # Panel CMS kelola konten, usulan, kategori, & laporan
│   ├── auth/                  # Login, register, ganti sandi, & lupa sandi
│   ├── bookmark/              # Penyimpanan arsip favorit pengguna
│   ├── budaya/                # Ensiklopedia warisan budaya & kategori
│   ├── capaian/               # Gamifikasi: Lencana, Gelar, Runtun (Streak), & Riwayat
│   ├── home/                  # Beranda: Sorotan harian, misi harian, & linimasa cepat
│   ├── jelajah/               # Mesin pencari & filter terpadu lintas arsip
│   ├── komunitas/             # Feed diskusi, balasan bertingkat, mention, & moderasi
│   ├── kontribusi/            # Pengajuan usulan arsip baru & koreksi data
│   ├── onboarding/            # Pengenalan awal bagi pengguna baru
│   ├── sejarah/               # Ensiklopedia linimasa sejarah & alur peristiwa
│   ├── shell/                 # Scaffold induk (BottomNavigationBar 5 Tab & Admin Drawer)
│   ├── splash/                # Layar pembuka & sinkronisasi sesi pengguna
│   └── wilayah/               # Peta vektor interaktif & penuntasan wilayah nusantara
├── firebase_options.dart      # Konfigurasi Firebase CLI
└── main.dart                  # Entry point aplikasi & inisialisasi layanan
```

---

## 🚀 Memulai (Getting Started)

### Prasyarat Sistem
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.22.0 atau lebih baru disarankan)
* [Dart SDK](https://dart.dev/get-dart) (^3.12.2)
* Akun [Firebase Console](https://console.firebase.google.com/) aktif
* Akun [Cloudinary](https://cloudinary.com/) aktif

### Langkah Instalasi

1. **Kloning Repositori**:
   ```bash
   git clone https://github.com/ShineyVamp/RenjanaApp.git
   cd RenjanaApp
   ```

2. **Pasang Dependensi**:
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**:
   Pastikan file `lib/firebase_options.dart` telah terkonfigurasi dengan proyek Firebase Anda:
   ```bash
   flutterfire configure
   ```

4. **Konfigurasi Cloudinary**:
   Pastikan parameter cloud name, preset, API key, dan API secret Anda telah disesuaikan pada:
   `lib/core/constants/cloudinary_keys.dart`

5. **Jalankan Aplikasi**:
   ```bash
   flutter run
   ```

---

## 🤝 Kontribusi

Aplikasi ini dibangun dengan semangat gotong royong pelestarian budaya. Kontribusi dalam bentuk *pull request*, pelaporan *bug*, maupun penambahan data arsip nusantara sangat dihargai:
1. *Fork* repositori ini
2. Buat branch fitur baru (`git checkout -b fitur/FiturKeren`)
3. *Commit* perubahan Anda (`git commit -m 'Menambahkan fitur keren'`)
4. *Push* ke branch (`git push origin fitur/FiturKeren`)
5. Ajukan *Pull Request*

---

<div align="center">
  <sub>Dibangun dengan ❤️ dan dedikasi untuk pelestarian kekayaan budaya Nusantara.</sub><br>
  <sub>© 2026 Renjana Team. All rights reserved.</sub>
</div>

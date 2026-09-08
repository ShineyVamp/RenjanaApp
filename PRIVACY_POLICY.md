# Kebijakan Privasi (Privacy Policy) – Renjana

**Terakhir Diperbarui:** 31 Agustus 2026

Selamat datang di **Renjana** ("Aplikasi"). Kebijakan Privasi ini menjelaskan bagaimana **Renjana** ("kami", "pengembang") mengumpulkan, menggunakan, memproses, menyimpan, dan melindungi informasi pribadi Anda saat Anda menggunakan aplikasi mobile daring (online) kami yang terintegrasi dengan layanan **Google Firebase** dan tersedia di Google Play Store.

Kami berkomitmen penuh untuk menjaga kerahasiaan dan keamanan data pribadi pengguna kami. Dengan menggunakan Aplikasi Renjana, Anda menyetujui praktik pengumpulan dan penggunaan informasi sebagaimana diuraikan dalam dokumen ini.

---

## 1. Ringkasan Singkat
- **Renjana** adalah platform digital edukasi kebudayaan, sejarah nusantara, dan komunitas budaya Indonesia yang beroperasi secara daring (*online*).
- Kami menggunakan infrastruktur cloud terpercaya dari **Google Firebase** (Google LLC) untuk autentikasi pengguna, penyimpanan basis data (*Cloud Firestore/Realtime Database*), penyimpanan media (*Cloud Storage*), dan pengiriman notifikasi (*Firebase Cloud Messaging*).
- Kami **tidak** menjual, menyewakan, atau memperdagangkan data pribadi Anda kepada pihak ketiga atau pihak pengiklan komersial.
- Seluruh transmisi data antara aplikasi, perangkat Anda, dan server Google Firebase dienkripsi menggunakan protokol standar industri (**HTTPS / TLS**).

---

## 2. Informasi dan Data yang Kami Kumpulkan

### a. Data Akun Pengguna (Firebase Authentication)
Saat Anda mendaftar atau masuk ke dalam aplikasi:
- **Nama Lengkap / Nama Tampilan (Display Name)**
- **Alamat Email**
- **Kata Sandi (Password):** Dikelola dan diamankan secara terenkripsi melalui sistem Firebase Authentication. Kami tidak pernah melihat atau menyimpan kata sandi Anda dalam bentuk teks terbuka (*plain text*).
- **Foto Profil (Opsional):** Disimpan secara aman di Firebase Cloud Storage jika Anda memilih untuk mengunggah avatar/foto profil.

### b. Data Aktivitas dan Konten Pengguna (Cloud Firestore)
Data interaksi Anda disinkronkan ke basis data cloud untuk mendukung pengalaman belajar lintas perangkat:
- **Progres Belajar & Kuis:** Nilai/skor kuis, riwayat jawaban, catatan runtun belajar harian (*daily streak*), dan lencana pencapaian (*achievements*).
- **Koleksi & Bookmark:** Daftar artikel budaya dan sejarah yang Anda simpan.
- **Forum Komunitas & Kontribusi:** Topik diskusi, ulasan, komentar, serta unggahan informasi kebudayaan lokal yang Anda bagikan.

### c. Informasi Teknis dan Diagnostik (Firebase SDK)
Layanan Google Firebase dapat mengumpulkan informasi teknis tertentu secara otomatis untuk memastikan stabilitas aplikasi:
- Jenis dan model perangkat keras, versi sistem operasi Android, serta pengenal unik instalasi (*Firebase Installation ID*).
- Laporan diagnostik kesalahan sistem (*crash logs*) dan performa jaringan untuk perbaikan bug dan pemeliharaan aplikasi.

### d. Data yang Tidak Kami Kumpulkan
Aplikasi ini **TIDAK** mengumpulkan:
- Lokasi GPS presisi secara realtime di latar belakang (*background GPS tracking*).
- Data finansial, nomor kartu kredit, atau rekening perbankan.
- Akses ke kontak telepon pribadi, riwayat panggilan, maupun SMS.

---

## 3. Layanan Pihak Ketiga (Google Firebase)

Aplikasi kami menggunakan layanan backend yang disediakan oleh **Google LLC** (Google Firebase):
1. **Firebase Authentication:** Untuk mengelola pendaftaran akun, verifikasi login yang aman, dan pemulihan akun.
2. **Cloud Firestore / Firebase Database:** Untuk menyimpan data katalog budaya terbaru, bank soal kuis, data komunitas, dan progres belajar pengguna.
3. **Firebase Cloud Storage:** Untuk menyimpan aset foto profil dan media kontribusi budaya secara aman.
4. **Firebase Cloud Messaging (FCM):** Untuk mengirimkan pengingat belajar harian, informasi fakta budaya baru, serta notifikasi interaksi akun.

Pengelolaan data oleh Google tunduk pada [Kebijakan Privasi Google](https://policies.google.com/privacy) dan [Ketentuan Keamanan Data Firebase](https://firebase.google.com/support/privacy).

---

## 4. Izin Perangkat (Android Permissions) yang Digunakan

Aplikasi Renjana dapat meminta izin perangkat berikut:

1. **Akses Jaringan Internet (`INTERNET`, `ACCESS_NETWORK_STATE`):**
   - *Tujuan:* Menghubungkan aplikasi ke server Google Firebase guna memuat data budaya, sinkronisasi akun, dan interaksi online.
2. **Penyimpanan / Foto & Media (`READ_MEDIA_IMAGES`, `READ_EXTERNAL_STORAGE`):**
   - *Tujuan:* Memungkinkan pengguna atau admin memilih foto dari galeri untuk foto profil atau unggahan materi artikel budaya.
3. **Kamera (`CAMERA`):**
   - *Tujuan:* Memungkinkan pengambilan foto secara langsung untuk pembaruan profil atau materi kontribusi budaya.
4. **Notifikasi (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`):**
   - *Tujuan:* Menerima pemberitahuan pengingat belajar harian (*daily streak reminder*) dan info budaya terbaru melalui Firebase Cloud Messaging.

---

## 5. Keamanan Data (Data Security)

- **Enkripsi dalam Transit:** Seluruh aliran data antara aplikasi Renjana dan layanan Google Firebase terlindungi enkripsi TLS/SSL.
- **Aturan Keamanan Cloud (Security Rules):** Akses data pada Firebase Firestore dan Cloud Storage diatur oleh aturan keamanan ketat (*Security Rules*), memastikan pengguna hanya dapat mengubah data miliknya sendiri.
- **Penyimpanan Lokal:** Token otentikasi sesi disimpan secara terisolasi pada memori lokal aplikasi (sandbox).

---

## 6. Penghapusan Akun dan Data Pengguna (Account & Data Deletion)

Sesuai ketentuan Google Play Console mengenai hak privasi dan penghapusan data:
1. **Penghapusan Mandiri:** Anda dapat mengajukan penghapusan akun beserta seluruh data pribadi (profil, skor kuis, bookmark, dan postingan) langsung melalui menu **Pengaturan Akun / Profil** di dalam aplikasi.
2. **Permintaan via Email:** Anda juga dapat mengajukan permohonan penghapusan akun dengan mengirimkan email ke kontak pengembang kami dengan subjek *"Permohonan Penghapusan Akun Renjana"*.
3. **Waktu Pemrosesan:** Setelah konfirmasi, akun Firebase Authentication dan dokumen terkait di Cloud Firestore/Storage akan dihapus secara permanen dari server kami.

---

## 7. Privasi Anak-Anak (Children’s Privacy)

Aplikasi Renjana merupakan aplikasi edukasi budaya yang aman untuk keluarga dan pelajar:
- Konten aplikasi berfokus pada edukasi sejarah, ensiklopedia budaya nusantara, dan kuis edukatif.
- Kami tidak mengumpulkan data pribadi di luar kebutuhan dasar akun. Jika orang tua atau wali mendapati bahwa anak di bawah umur memberikan data tanpa persetujuan, silakan hubungi kami untuk kami bantu proses penghapusan datanya.

---

## 8. Perubahan pada Kebijakan Privasi Ini

Kebijakan Privasi ini dapat diperbarui secara berkala sesuai perkembangan fitur aplikasi atau pembaruan kepatuhan hukum. Pembaruan akan ditandai dengan perubahan tanggal "Terakhir Diperbarui" di bagian awal dokumen.

---

## 9. Hubungi Kami

Jika Anda memiliki pertanyaan mengenai Kebijakan Privasi ini atau pengelolaan data di aplikasi Renjana, silakan hubungi kami:

- **Pengembang:** Tim Pengembang Renjana
- **Email:** renjana.app@gmail.com
- **Layanan Cloud Backend:** Google Firebase
- **Lokasi:** DKI Jakarta, Indonesia
